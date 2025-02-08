// SPDX-License-Identifier: MIT

/*
https://t.me/GG_portal
    __          __       _                                 _______        
    \ \        / /      | |                               |__   __|       
     \ \  /\  / /   ___ | |  ___   ___   _ __ ___    ___     | |     ___  
      \ \/  \/ /   / _ \| | / __| / _ \ | '_ ` _ \  / _ \    | |    / _ \ 
       \  /\  /   |  __/| || (__ | (_) || | | | | ||  __/    | |   | (_) |
        \/  \/     \___||_| \___| \___/ |_| |_| |_| \___|    |_|    \___/ 
                                                                      
                              _______  _           
                             |__   __|| |          
                                | |   | |__    ___ 
                                | |   | '_ \  / _ \
                                | |   | | | ||  __/
                                |_|   |_| |_| \___|

  _____                         _                  _____                         
 / ____|                       (_)                / ____|                        
| |  __  _   _   ___  ___  ___  _  _ __    __ _  | |  __   __ _  _ __ ___    ___ 
| | |_ || | | | / _ \/ __|/ __|| || '_ \  / _` | | | |_ | / _` || '_ ` _ \  / _ \
| |__| || |_| ||  __/\__ \\__ \| || | | || (_| | | |__| || (_| || | | | | ||  __/
 \_____| \__,_| \___||___/|___/|_||_| |_| \__, |  \_____| \__,_||_| |_| |_| \___|
                                           __/ |                                 
                                          |___/                                  
            
Welcome to the 🎲 Guessing Game 🎲 - Where Fortune Favors the Bold!

🔐 To embark on this thrilling journey, you must first prove your commitment by holding at least 0.1% of our token supply.
    Only the true hodlers are worthy! 
    How to Guess:
    └─1 - Go to The "Write" tab here on etherscan
    └─2 - Connect your wallet
    └─3 - Go to the function named "guess" and enter a number according to the current level
          If your number is too high (for example, the current level is 1. thus the max guess is 10)
          It will come up as red in metamask, so don't send the transaction. To check the current level
          go to "Read" tab and check the row named currentLevel and check below the maximum guess for that level
          A guess must be greater than 1 and lower than the level's max guess.
          lvl - max guess
          1   - 10    
          2   - 50   
          3   - 100  
          4   - 300   
          5   - 500   
          6   - 800  
          7   - 1000 
          8   - 1500
          9   - 3000
          10  - 15000
    └─4 If you win, you will see your balance go up, according to the rewards for that level!
        The cost of a guess is about 1.5x of a normal ETH transfer. So if gas fees are low and transfering ETH is 2$,
        a guess will cost about 3$.
    ‼️ VERY IMPORTANT - RAISE THE GAS LIMIT IN METAMASK WHEN SENDING THE GUESS TO 150,000!! If you win and use the default
    etherscan gas limit estimation your transcation could FAIL!!!

🏆 Now, onto the main event - the 10 Levels of heart-pounding excitement! 🏆

1️⃣ Level 1: The journey begins!
└─Guess a number between 1-10. The first to guess right in a block wins 0.05% of the total supply!

2️⃣ Level 2: The stakes are rising!
└─Try your luck with numbers between 1-50, and if you're the first, you'll snatch a 0.2% reward!

3️⃣ Level 3: The game intensifies!
└─Guess between 1-100, and you could claim a handsome 0.45% of the total supply.

4️⃣ Level 4: The challenge escalates!
└─Pick a number between 1-300, and if you're swift enough, you'll grab a full 1% of the total supply!

5️⃣ Level 5: The tension builds!
└─Numbers between 1-500 are your playground, and you can seize a generous 1.3% reward!

6️⃣ Level 6: The excitement never stops!
└─Aim for numbers between 1-800, and be the first to enjoy a 1.5% token reward!

7️⃣ Level 7: The adventure continues!
└─Choose from numbers between 1-1000, and if luck favors you, claim a fabulous 1.7% of the total supply!

8️⃣ Level 8: Bronze Jackpot awaits!
└─Guess between 1-1500, and the first winner will take home a dazzling 2% of the total supply!

9️⃣ Level 9: Silver Jackpot beckons!
└─Attempt numbers between 1-3000, and if you succeed, revel in a splendid 2.5% token reward!

🔟 Level 10: Golden Jackpot, the ultimate prize!
└─Venture boldly with numbers between 1-10000 and, if fortune smiles upon you, seize an astonishing 6% of the total supply!
└─And if you thought that's all... you were wrong. The 🏆champion🏆 will also receive 1% of the tax we generate... FOREVER!

With each level, the excitement and rewards grow, and only the quickest and luckiest will prevail!
Remember: The first correct guess in each block wins, and the game continues through all 10 levels until it's conquered by the luckiest of all!
The ultimate winner's address will be forever engraved into the blockchain in this contract and he will keep receiving ETH from taxes!

🤞 May the odds be ever in your favor! Best of luck in the Guessing Game - $GG! 🤞

*/
pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}

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

interface Guesser {
    function guess(uint n, uint high) external view returns (bool);
}

contract GuessingGame is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public isExcludedFromFees;

    mapping (uint8 => uint256) public levelRewards; // rewards for the level
    mapping (uint8 => uint16) public levelUpperBounds; // max guess on the level
    mapping (uint256 => bool) public blockHasWinner; // only 1 winner per block!
    mapping (address => mapping (uint => bool)) private alreadyGuessed; // 1 guess / block
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100e6 * 10**_decimals;
    
    address public marketingWalletAddress;
    address public champion;

    string private constant _name = unicode"Guessing Game";
    string private constant _symbol = unicode"GG";
    
    bool public tradingEnabled;
    bool private inSwap;

    uint256 public maxWallet = _tTotal * 2 / 100;

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair;

    uint256 public buyFees = 25;
    uint256 public sellFees = 25;

    uint public finalBuyFees = 3;
    uint public finalSellFees = 3;

    uint256 public swapTokensAtAmount = 250;

    address guesserContract;


    uint8 public currentLevel;
    uint256 public minHoldingToParticipate = _tTotal / 1000; // 0.1% of total supply

    event Congratulations(address winner);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        marketingWalletAddress = payable(msg.sender);
        _balances[_msgSender()] = _tTotal;
        isExcludedFromFees[owner()] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[address(uniswapV2Router)] = true;
        _approve(msg.sender, address(this), type(uint256).max);
        _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
        _approve(address(this), address(uniswapV2Router), type(uint256).max);
        emit Transfer(address(0), _msgSender(), _tTotal);
        levelRewards[1] = _tTotal * 5 / 10000;
        levelRewards[2] = _tTotal * 20 / 10000;
        levelRewards[3] = _tTotal * 45 / 10000;
        levelRewards[4] = _tTotal * 100 / 10000;
        levelRewards[5] = _tTotal * 130 / 10000;
        levelRewards[6] = _tTotal * 150 / 10000;
        levelRewards[7] = _tTotal * 170 / 10000;
        levelRewards[8] = _tTotal * 200 / 10000;
        levelRewards[9] = _tTotal * 250 / 10000;
        levelRewards[10] = _tTotal * 600 / 10000;

        levelUpperBounds[1] = 10;
        levelUpperBounds[2] = 50;
        levelUpperBounds[3] = 100;
        levelUpperBounds[4] = 300;
        levelUpperBounds[5] = 500;
        levelUpperBounds[6] = 800;
        levelUpperBounds[7] = 1000;
        levelUpperBounds[8] = 1500;
        levelUpperBounds[9] = 3000;
        levelUpperBounds[10] = 15000;
        // total = 5+20+45+100+130+150+170+200+250+600 = 1670 = 16.7%
    }
    
    function guess(uint _guess) external {
        require(!alreadyGuessed[msg.sender][block.number], "Already guessed this block");
        alreadyGuessed[msg.sender][block.number] = true;
        require(currentLevel > 0, "Game not started");
        require(currentLevel <= 10, "Game ended");
        require(_balances[msg.sender] >= minHoldingToParticipate, "Not enough tokens to guess");
        uint16 upperBound = levelUpperBounds[currentLevel];
        require(upperBound >= _guess, "Guess is too high for this level");
        require(_guess > 0, "Guess must be greater than 0");
        bool result = Guesser(guesserContract).guess(_guess, upperBound);
        if (result) {
            require(!blockHasWinner[block.number], "Block already has a winner, try again next block");
            blockHasWinner[block.number] = true;
            uint reward = levelRewards[currentLevel];
            _balances[guesserContract] -= reward;
            _balances[msg.sender] += reward;
            emit Transfer(address(this), msg.sender, reward);
            currentLevel++;
            if (currentLevel == 11) {
                champion = msg.sender;
                emit Congratulations(msg.sender);
            }
        } 

    }

    function setGuesserContract(address _guesserContract) external onlyOwner {
        require(guesserContract == address(0), "Guesser contract already set");
        guesserContract = _guesserContract;
        isExcludedFromFees[guesserContract] = true;
        uint rewardSupply = _tTotal * 1670 / 10000;
        _balances[msg.sender] -= rewardSupply;
        _balances[guesserContract] += rewardSupply;
        currentLevel = 1;
        emit Transfer(msg.sender, guesserContract, rewardSupply);
    }

    function isGameStarted() external view returns (bool) {
        return currentLevel > 0;
    }



    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0, "Transfer amount must be greater than zero.");
        uint256 taxAmount;
        if (!isExcludedFromFees[from] && !isExcludedFromFees[to]) {
            require(tradingEnabled, "Trade is not open");

            if (from == uniswapV2Pair) {
                taxAmount = amount * buyFees / 100;
                require(balanceOf(to) + amount <= maxWallet, "Max wallet reached");
            }

            if(to == uniswapV2Pair){
                taxAmount = amount * sellFees / 100;
                uint balance = _balances[uniswapV2Pair];
                uint threshold = balance * swapTokensAtAmount / 10000;
                if (!inSwap && _balances[address(this)] > threshold) {
                    swapBack(balance > threshold * 3 ? threshold * 3 : balance);
                }
            }
        }

        if(taxAmount > 0){
          _balances[address(this)] += taxAmount;
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from] -= amount;
        _balances[to] += amount - taxAmount;
        emit Transfer(from, to, amount - taxAmount);
    }

    // can be called only once
    function addLiquidity(uint tokenAmount) external payable onlyOwner {
        _transfer(msg.sender, address(this), tokenAmount);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: msg.value}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance > 0){
          swapBack(tokenBalance);
        }
    }

    function openTrading() external onlyOwner {
        require(uniswapV2Pair != address(0), "Add liquidity first!");
        tradingEnabled = true;
    }

    function removeLimits() external onlyOwner{
        maxWallet =_tTotal;
        buyFees = finalBuyFees;
        sellFees = finalSellFees;
    }

    function swapBack(uint256 amount) private {        
        bool success;
        swapTokensForEth(amount);
        if (champion == address(0)) {
            (success, ) = address(marketingWalletAddress).call{value: address(this).balance}("");
        } else {
            uint forWinner = address(this).balance / 3;
            (success, ) = address(champion).call{value: forWinner}("");
            (success, ) = address(marketingWalletAddress).call{value: address(this).balance}("");
        }
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

    function setBuyTaxes(uint newBuyTax) external onlyOwner {
        buyFees = newBuyTax;
    }

    function setSellTaxes(uint newSellTax) external onlyOwner {
        sellFees = newSellTax;
    }

    function setSwapTokensAtAmount(uint amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function excludeFromFees(address account) external onlyOwner {
        isExcludedFromFees[account] = true;
    }

    function includeInFees(address account) external onlyOwner {
        isExcludedFromFees[account] = false;
    }

    function rescueETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}