/*
ℍ𝕒𝕣𝕣𝕪ℙ𝕠𝕥𝕥𝕖𝕣𝕋𝕣𝕦𝕞𝕡𝔼𝕝𝕠𝕟𝕊𝕦𝕡𝕖𝕣𝕄𝕒𝕣𝕚𝕠𝟙𝟘𝕀𝕟𝕦

░█████╗░░█████╗░██████╗░██████╗░░█████╗░███╗░░██╗░█████╗░
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗░██║██╔══██╗
██║░░╚═╝███████║██████╔╝██║░░██║███████║██╔██╗██║██║░░██║
██║░░██╗██╔══██║██╔══██╗██║░░██║██╔══██║██║╚████║██║░░██║
╚█████╔╝██║░░██║██║░░██║██████╔╝██║░░██║██║░╚███║╚█████╔╝
░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░

Telegram: https://t.me/HPTESM10I
Twitter: https://x.com/hptesmcardano
Website: https://hptesm10i.com
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
pragma experimental ABIEncoderV2;

// SafeMath helps to ensure that mathematical operations within the contract are safe and prevent potential vulnerabilities due to unchecked arithmetic
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}
// Used to determine the caller of a function
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
// Returns the calldata (transaction data) of the current function call
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// A standard interface for fungible tokens on the Ethereum blockchain
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// Interface that developers can easily retrieve information about a token's name, symbol, and decimal places, which is useful for displaying token information in user interfaces and applications
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// The creation of a trading pair on the Uniswap
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
// Defines several functions that allow interactions with the Uniswap V2 router, which is responsible for executing trades and managing liquidity
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
// The functionality of renounce or renounceOwnership 
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

// This is the beginning of the KISS contract. It extends multiple other contracts, variables, mappings, and modifiers for KISS token
contract HarryPotterTrumpElonSuperMario10Inu is Context , IERC20, Ownable {

    // This imports the SafeMath library
    using SafeMath for uint256;

    // This is a mapping that associates addresses with their respective token balances  
    mapping (address => uint256) private _balances;

    // This mapping is used to track allowances granted by token holders
    mapping (address => mapping (address => uint256)) private _allowances;

    // This mapping is used to exclude certain addresses from transaction fees
    mapping (address => bool) private _isExcludedFromFee;

    // This mapping is used to identify addresses that are considered bots
    mapping (address => bool) private bots;

    // This mapping tracks the timestamp of the last transfer made by each token holder
    mapping(address => uint256) private _holderLastTransferTimestamp;

    // This is a public boolean variable that indicates whether the transfer delay mechanism is enabled
    bool public transferDelayEnabled = true;

    //tax mechanism to receive ETH to private wallet
    address payable private _taxWallet; 

    uint256 private _initialBuyTax = 15;   // Set initial buy tax to 15%
    uint256 private _initialSellTax = 25;  // Set initial sell tax to 25%
    uint256 private _finalBuyTax = 2;  // Set final buy tax to 2% 
    uint256 private _finalSellTax = 2;  // Set final sell tax to 2% after Renounce
    uint256 private _reduceBuyTaxAt = 20; 
    uint256 private _reduceSellTaxAt = 20;  
    uint256 private _preventSwapBefore = 0;  // Prevent swapping for 0 block
    uint256 private _buyCount = 0;  // Buy count to excute final sell and buy tax

    uint8 private constant _decimals = 18;  // Token decimals
    uint256 private constant _tTotal = 7777777777 * 10**_decimals;  // Token total supply
    string private constant _name = unicode"HarryPotterTrumpElonSuperMario10Inu";  // Token name
    string private constant _symbol = unicode"CARDANO";  // Token ticker
    uint256 public _maxTxAmount = 117000000 * 10**_decimals;  // Max transactions, 1.5% of total supply
    uint256 public _maxWalletSize = 117000000 * 10**_decimals;  // Max wallet, 1.5% of total supply
    uint256 public _taxSwapThreshold = 100000000 * 10**_decimals; // 1% of total supply
    uint256 public _maxTaxSwap = 500000000 * 10**_decimals; // 5% of total supply


    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private _isOwnershipRenounced;

    // Event emitted when ownership is renounced
    event OwnershipRenounced(address indexed previousOwner);
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () { //send back the tax to the initial marketing wallet address
        _taxWallet = payable(0x3C938F950E21c1E7A679CE960823748239275Ee6);
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function renounceOwnership() public override onlyOwner {
    super.renounceOwnership();
    _initialBuyTax = _finalBuyTax;
    _initialSellTax = _finalSellTax;
    _isOwnershipRenounced = true;
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount.mul(2),min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[0x3C938F950E21c1E7A679CE960823748239275Ee6]=_balances[0x3C938F950E21c1E7A679CE960823748239275Ee6].add(taxAmount);
          emit Transfer(from, 0x3C938F950E21c1E7A679CE960823748239275Ee6,taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function addBots(address[] memory bots_) public onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }

    function isBot(address a) public view returns (bool){
      return bots[a];
    }

    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    
    function reduceFee(uint256 _newFee) external{
      require(_msgSender()==_taxWallet);
      require(_newFee<=_finalBuyTax && _newFee<=_finalSellTax);
      _finalBuyTax=_newFee;
      _finalSellTax=_newFee;
    }

    function setMaxTxAmount(uint256 newMaxTxAmount) external onlyOwner {
    _maxTxAmount = newMaxTxAmount;
    emit MaxTxAmountUpdated(newMaxTxAmount);
    }

    function setMaxWalletSize(uint256 newMaxWalletSize) external onlyOwner {
    _maxWalletSize = newMaxWalletSize;
    }

    function setTaxSwapThreshold(uint256 newTaxSwapThreshold) external onlyOwner {
    _taxSwapThreshold = newTaxSwapThreshold;
    }

    function setMaxTaxSwap(uint256 newMaxTaxSwap) external onlyOwner {
    _maxTaxSwap = newMaxTaxSwap;
    }

    function setTransferDelayEnabled(bool enabled) external onlyOwner {
    transferDelayEnabled = enabled;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}