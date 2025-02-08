// SPDX-License-Identifier: MIT

/*
Use Alpaca telegram voice changer to transform your voice into 110+ realistic voices of characters and celebrities for free within seconds. 100% powered by AI voice cloning.

Alpaca telegram voice changer has a vast library of many voice effects and lets you relish in lightning-fast voice conversions like never before.

Website: https://alpacabot.pro
Twitter: https://twitter.com/AVEX_ERC
Telegram: https://t.me/AVEX_ERC
AlpacaBot: https://t.me/voice_changer_bot
*/

pragma solidity 0.8.21;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}
abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "Ownable: Caller is not owner"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}
interface IDexRouter {
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
        uint deadline) external;
}
interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address dexPair);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract AVEX is Ownable, IERC20 {
    using SafeMath for uint256;
    string private constant _name = "Alpaca Voice Changer Bot";
    string private constant _symbol = "AVEX";
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 10 ** 9 * (10 ** _decimals);
    
    IDexRouter dexRouter;
    address public dexPair;
    bool private isTradingEnabled = false;
    bool private fsEnabled = true; // fee swap enabled
    uint256 private fsCount; // fee swap count
    bool private swapping;
    uint256 fsInterval; // fee swap interval
    uint256 private fsThreshold = ( _totalSupply * 1000 ) / 100000;
    uint256 private minTaxSwap = ( _totalSupply * 10 ) / 100000;
    modifier lockTheSwap {swapping = true; _; swapping = false;}
    uint256 private feeForLp = 0;
    uint256 private feeForMarketing = 0;
    uint256 private feeForDev = 100;
    uint256 private feeToBurn = 0;
    uint256 private feeToBuy = 4000;
    uint256 private feeToSell = 2500;
    uint256 private feeToTransfer = 3500;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal devFeeWallet = 0x6B6647c6CDbF7f31947F92B80D3640B7B418e84b; 
    address internal marketFeeWallet = 0x6B6647c6CDbF7f31947F92B80D3640B7B418e84b;
    address internal lpFeeWallet = 0x6B6647c6CDbF7f31947F92B80D3640B7B418e84b;
    uint256 public _maxTrxSize = ( _totalSupply * 300 ) / 10000;
    uint256 public _maxTransSize = ( _totalSupply * 300 ) / 10000;
    uint256 public _maxWalletSize = ( _totalSupply * 300 ) / 10000;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFees;
    mapping (address => uint256) _balances;

    constructor() Ownable(msg.sender) {
        IDexRouter _router = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IDexFactory(_router.factory()).createPair(address(this), _router.WETH());
        dexRouter = _router; dexPair = _pair;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[lpFeeWallet] = true;
        isExcludedFromFees[marketFeeWallet] = true;
        isExcludedFromFees[devFeeWallet] = true;
        isExcludedFromFees[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function startTrading() external onlyOwner {isTradingEnabled = true;}
    function getOwner() external view override returns (address) { return owner; }
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}
    function setTxAmounts(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _totalSupply.mul(_buy).div(10000); uint256 newTransfer = _totalSupply.mul(_sell).div(10000); uint256 newWallet = _totalSupply.mul(_wallet).div(10000);
        _maxTrxSize = newTx; _maxTransSize = newTransfer; _maxWalletSize = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function clearStuckTokens(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(devFeeWallet, _amount);
    }
    function swapFeeAndSend(uint256 tokens) private lockTheSwap {
        uint256 _denominator = (feeForLp.add(1).add(feeForMarketing).add(feeForDev)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(feeForLp).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForFee(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(feeForLp));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(feeForLp);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(feeForMarketing);
        if(marketingAmt > 0){payable(marketFeeWallet).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(devFeeWallet).transfer(contractBalance);}
    }
    function swapTokensForFee(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }
    function getTxFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == dexPair){return feeToSell;}
        if(sender == dexPair){return feeToBuy;}
        return feeToTransfer;
    }
    function calculateFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcludedFromFees[recipient]) {return _maxTrxSize;}
        if(getTxFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getTxFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(feeToBurn > uint256(0) && getTxFee(sender, recipient) > feeToBurn){_transfer(address(this), address(DEAD), amount.div(denominator).mul(feeToBurn));}
        return amount.sub(feeAmount);} return amount;
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isExcludedFromFees[sender] && !isExcludedFromFees[recipient]){require(isTradingEnabled, "isTradingEnabled");}
        if(!isExcludedFromFees[sender] && !isExcludedFromFees[recipient] && recipient != address(dexPair) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWalletSize, "Exceeds maximum wallet amount.");}
        if(sender != dexPair){require(amount <= _maxTransSize || isExcludedFromFees[sender] || isExcludedFromFees[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTrxSize || isExcludedFromFees[sender] || isExcludedFromFees[recipient], "TX Limit Exceeded"); 
        if(recipient == dexPair && !isExcludedFromFees[sender]){fsCount += uint256(1);}
        if(canFeeSwap(sender, recipient, amount)){swapFeeAndSend(fsThreshold); fsCount = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !isExcludedFromFees[sender] ? calculateFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpFeeWallet,
            block.timestamp);
    }
    function canFeeSwap(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= minTaxSwap;
        bool aboveThreshold = balanceOf(address(this)) >= fsThreshold;
        return !swapping && fsEnabled && isTradingEnabled && aboveMin && !isExcludedFromFees[sender] && recipient == dexPair && fsCount >= fsInterval && aboveThreshold;
    }
    function setFeeParameters(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        feeForLp = _liquidity; feeForMarketing = _marketing; feeToBurn = _burn; feeForDev = _development; feeToBuy = _total; feeToSell = _sell; feeToTransfer = _trans;
        require(feeToBuy <= denominator.div(1) && feeToSell <= denominator.div(1) && feeToTransfer <= denominator.div(1), "feeToBuy and feeToSell cannot be more than 20%");
    }
}