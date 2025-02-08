// SPDX-License-Identifier: MIT

/*
IT IS TIME TO EMBARK!

Aqua Farm is the lovely ocean adventure RPG based on blockchain technology with a Play-to-Earn (P2E) structure and Non-Fungible Token (NFT) assets. Players take a journey together with Aree, the ocean fairy, by boarding the Guardian to take back the PODO (Power of Deep Ocean), the source of peace that was stolen by the invaders who threatened the peace of Aqua World.

Website: https://www.aquafarm.space
Telegram: https://t.me/aquafarm_eth
Twitter: https://twitter.com/aquafarm_erc
*/

pragma solidity 0.8.21;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
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
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
abstract contract Ownable {
    address internal owner;
    constructor(address _owner) {owner = _owner;}
    modifier onlyOwner() {require(isOwner(msg.sender), "!OWNER"); _;}
    function isOwner(address account) public view returns (bool) {return account == owner;}
    function transferOwnership(address payable adr) public onlyOwner {owner = adr; emit OwnershipTransferred(adr);}
    event OwnershipTransferred(address owner);
}
interface IUniswapRouter {
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
interface IUniswapFactory{
    function createPair(address tokenA, address tokenB) external returns (address pairAddress);
}
contract AQUA is IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"AQUA FARM";
    string private constant _symbol = unicode"AQUA";
    uint8 private constant _decimals = 9;
    uint256 private _tSupply = 10 ** 9 * (10 ** _decimals);
    
    IUniswapRouter uniRouter;
    address public pairAddress;
    bool private openedTrading = false;
    bool private swapActivated = true;
    uint256 private numSwaps;
    bool private swapping;
    uint256 swapAfter;
    uint256 private swapInterval = ( _tSupply * 1000 ) / 100000;
    uint256 private swapAt = ( _tSupply * 10 ) / 100000;
    modifier lockSwap {swapping = true; _; swapping = false;}
    uint256 private dynamicLpFee = 0;
    uint256 private marketingFee = 0;
    uint256 private developFee = 100;
    uint256 private burningFee = 0;
    uint256 private buyTax = 3500;
    uint256 private sellTax = 3500;
    uint256 private transferTax = 3500;
    uint256 private denominator = 10000;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address internal devWallet = 0x4DC82D3E37ac74B422fbB1b9877c894aDeb6E356; 
    address internal marketWallet = 0x4DC82D3E37ac74B422fbB1b9877c894aDeb6E356;
    address internal lpWallet = 0x4DC82D3E37ac74B422fbB1b9877c894aDeb6E356;
    uint256 public _maxTransaction = ( _tSupply * 300 ) / 10000;
    uint256 public _maxTransfer = ( _tSupply * 300 ) / 10000;
    uint256 public _maxWallet = ( _tSupply * 300 ) / 10000;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromTax;

    constructor() Ownable(msg.sender) {
        IUniswapRouter _router = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IUniswapFactory(_router.factory()).createPair(address(this), _router.WETH());
        uniRouter = _router; pairAddress = _pair;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[lpWallet] = true;
        isExcludedFromTax[marketWallet] = true;
        isExcludedFromTax[devWallet] = true;
        isExcludedFromTax[msg.sender] = true;
        _balances[msg.sender] = _tSupply;
        emit Transfer(address(0), msg.sender, _tSupply);
    }

    receive() external payable {}
    function name() public pure returns (string memory) {return _name;}
    function symbol() public pure returns (string memory) {return _symbol;}
    function decimals() public pure returns (uint8) {return _decimals;}
    function startTrading() external onlyOwner {openedTrading = true;}
    function getOwner() external view override returns (address) { return owner; }
    function transfer(address recipient, uint256 amount) public override returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function totalSupply() public view override returns (uint256) {return _tSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));}

    function shouldCASwap(address sender, address recipient, uint256 amount) internal view returns (bool) {
        bool aboveMin = amount >= swapAt;
        bool aboveThreshold = balanceOf(address(this)) >= swapInterval;
        return !swapping && swapActivated && openedTrading && aboveMin && !isExcludedFromTax[sender] && recipient == pairAddress && numSwaps >= swapAfter && aboveThreshold;
    }
    function setFees(uint256 _liquidity, uint256 _marketing, uint256 _burn, uint256 _development, uint256 _total, uint256 _sell, uint256 _trans) external onlyOwner {
        dynamicLpFee = _liquidity; marketingFee = _marketing; burningFee = _burn; developFee = _development; buyTax = _total; sellTax = _sell; transferTax = _trans;
        require(buyTax <= denominator.div(1) && sellTax <= denominator.div(1) && transferTax <= denominator.div(1), "buyTax and sellTax cannot be more than 20%");
    }
    function setTxLimits(uint256 _buy, uint256 _sell, uint256 _wallet) external onlyOwner {
        uint256 newTx = _tSupply.mul(_buy).div(10000); uint256 newTransfer = _tSupply.mul(_sell).div(10000); uint256 newWallet = _tSupply.mul(_wallet).div(10000);
        _maxTransaction = newTx; _maxTransfer = newTransfer; _maxWallet = newWallet;
        uint256 limit = totalSupply().mul(5).div(1000);
        require(newTx >= limit && newTransfer >= limit && newWallet >= limit, "Max TXs and Max Wallet cannot be less than .5%");
    }
    function shouldChargeFee(address sender, address recipient) internal view returns (bool) {
        return !isExcludedFromTax[sender];
    }
    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(sender),"You are trying to transfer more than your balance");
        if(!isExcludedFromTax[sender] && !isExcludedFromTax[recipient]){require(openedTrading, "openedTrading");}
        if(!isExcludedFromTax[sender] && !isExcludedFromTax[recipient] && recipient != address(pairAddress) && recipient != address(DEAD)){
        require((_balances[recipient].add(amount)) <= _maxWallet, "Exceeds maximum wallet amount.");}
        if(sender != pairAddress){require(amount <= _maxTransfer || isExcludedFromTax[sender] || isExcludedFromTax[recipient], "TX Limit Exceeded");}
        require(amount <= _maxTransaction || isExcludedFromTax[sender] || isExcludedFromTax[recipient], "TX Limit Exceeded"); 
        if(recipient == pairAddress && !isExcludedFromTax[sender]){numSwaps += uint256(1);}
        if(shouldCASwap(sender, recipient, amount)){caSwap(swapInterval); numSwaps = uint256(0);}
        _balances[sender] = _balances[sender].sub(amount);
        uint256 amountReceived = shouldChargeFee(sender, recipient) ? getAmountAfterFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);
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
    function withdrawDustETH(address _address, uint256 percent) external onlyOwner {
        uint256 _amount = IERC20(_address).balanceOf(address(this)).mul(percent).div(100);
        IERC20(_address).transfer(devWallet, _amount);
    }
    function caSwap(uint256 tokens) private lockSwap {
        uint256 _denominator = (dynamicLpFee.add(1).add(marketingFee).add(developFee)).mul(2);
        uint256 tokensToAddLiquidityWith = tokens.mul(dynamicLpFee).div(_denominator);
        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance= deltaBalance.div(_denominator.sub(dynamicLpFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(dynamicLpFee);
        if(ETHToAddLiquidityWith > uint256(0)){addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith); }
        uint256 marketingAmt = unitBalance.mul(2).mul(marketingFee);
        if(marketingAmt > 0){payable(marketWallet).transfer(marketingAmt);}
        uint256 contractBalance = address(this).balance;
        if(contractBalance > uint256(0)){payable(devWallet).transfer(contractBalance);}
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            lpWallet,
            block.timestamp);
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniRouter.WETH();
        _approve(address(this), address(uniRouter), tokenAmount);
        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp);
    }
    function getExactFee(address sender, address recipient) internal view returns (uint256) {
        if(recipient == pairAddress){return sellTax;}
        if(sender == pairAddress){return buyTax;}
        return transferTax;
    }
    function getAmountAfterFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        if (isExcludedFromTax[recipient]) {return _maxTransaction;}
        if(getExactFee(sender, recipient) > 0){
        uint256 feeAmount = amount.div(denominator).mul(getExactFee(sender, recipient));
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        if(burningFee > uint256(0) && getExactFee(sender, recipient) > burningFee){_transfer(address(this), address(DEAD), amount.div(denominator).mul(burningFee));}
        return amount.sub(feeAmount);} return amount;
    }
}