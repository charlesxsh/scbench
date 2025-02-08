/**

TG: https://t.me/warshippvp
Twotter_ https://twitter.com/WarshipPvP
Website: https://warshippvp.com

**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external payable;

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
}

interface IUniswapV2Pair {
    function sync() external;
}

contract WarshipBattleToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswap02Pair;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    string private constant _name = "Warship Battle PVP Bot";
    string private constant _symbol = "WSPVP";
    uint8 private constant _decimals = 18;

    uint256 private _tTotal = 1000000000 * 10 ** _decimals;

    uint256 public _amountMaxPerWallet = 20000000 * 10 ** _decimals;
    uint256 public _amountMaxPerTransaction = 20000000 * 10 ** _decimals;
    uint256 public thresholdForSwap = 10000000 * 10 ** _decimals;
    uint256 public forceSwapCount;

    address public liquidityWallet;
    address public marketingWallet;
    bool public isTradingActive = false;

    struct StructBuyFee {
        uint256 liquidity;
        uint256 marketing;
    }

    struct StructSellFee {
        uint256 liquidity;
        uint256 marketing;
    }

    StructBuyFee public buyFeeSettings;
    StructSellFee public sellFeeSettings;

    uint256 private feeLiquidity;
    uint256 private feeMarketing;

    bool private isInSwapMode;

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

    constructor (address markAddress, address liqAddress) {
        marketingWallet = markAddress;
        liquidityWallet = liqAddress;

        balances[_msgSender()] = _tTotal;

        buyFeeSettings.liquidity = 1;
        buyFeeSettings.marketing = 1;

        sellFeeSettings.liquidity = 1;
        sellFeeSettings.marketing = 1;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswap02Pair = _uniPair;

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(0x00)] = true;
        _isExcludedFromFee[address(0xdead)] = true;


    }

    function openTrading() external onlyOwner {
        isTradingActive = true;
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

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
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
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[address(account)] = excluded;
    }

    receive() external payable {}

    function takeBuyFeesFromTransaction(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * buyFeeSettings.liquidity / 100;
        uint256 marketingFeeTokens = amount * buyFeeSettings.marketing / 100;

        balances[address(this)] += liquidityFeeToken + marketingFeeTokens;
        emit Transfer(from, address(this), marketingFeeTokens + liquidityFeeToken);
        return (amount - liquidityFeeToken - marketingFeeTokens);
    }

    function takeSellFeesFromTransaction(uint256 amount, address from) private returns (uint256) {
        uint256 liquidityFeeToken = amount * sellFeeSettings.liquidity / 100;
        uint256 marketingFeeTokens = amount * sellFeeSettings.marketing / 100;

        balances[address(this)] += liquidityFeeToken + marketingFeeTokens;
        emit Transfer(from, address(this), marketingFeeTokens + liquidityFeeToken);
        return (amount - liquidityFeeToken - marketingFeeTokens);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function setTransactionFees(uint256 _buyMarketingFee, uint256 _buyLiquidityFee, uint256 _sellMarketingFee, uint256 _sellLiquidityFee) public onlyOwner {
        require(_buyMarketingFee + _buyLiquidityFee < 500 || _sellLiquidityFee + _sellMarketingFee < 500, "Can't change fee higher than 24%");

        buyFeeSettings.liquidity = _buyLiquidityFee;
        buyFeeSettings.marketing = _buyMarketingFee;

        sellFeeSettings.liquidity = _sellLiquidityFee;
        sellFeeSettings.marketing = _sellMarketingFee;
    }

    function setMaximumTxValue(uint256 _maxTx, uint256 _maxWallet) public onlyOwner {
        require(_maxTx + _maxWallet > _tTotal / 1000, "Should be bigger than 0,1%");
        _amountMaxPerTransaction = _maxTx;
        _amountMaxPerWallet = _maxWallet;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        balances[from] -= amount;
        uint256 transferAmount = amount;

        bool takeFee;

        if (!isTradingActive) {
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            takeFee = true;
        }

        if (takeFee) {
            if (to != uniswap02Pair) {
                require(amount <= _amountMaxPerTransaction, "Transfer Amount exceeds the maxTxnsAmount");
                require(balanceOf(to) + amount <= _amountMaxPerWallet, "Transfer amount exceeds the maxWalletAmount.");
                transferAmount = takeBuyFeesFromTransaction(amount, to);
            }

            if (from != uniswap02Pair) {
                require(amount <= _amountMaxPerTransaction, "Transfer Amount exceeds the maxTxnsAmount");
                transferAmount = takeSellFeesFromTransaction(amount, from);
                forceSwapCount += 1;

                if (balanceOf(address(this)) >= thresholdForSwap && !isInSwapMode) {
                    isInSwapMode = true;
                    runSwap(thresholdForSwap);
                    isInSwapMode = false;
                    forceSwapCount = 0;
                }

                if (forceSwapCount > 5 && !isInSwapMode) {
                    isInSwapMode = true;
                    runSwap(balanceOf(address(this)));
                    isInSwapMode = false;
                    forceSwapCount = 0;
                }
            }

            if (to != uniswap02Pair && from != uniswap02Pair) {
                require(amount <= _amountMaxPerTransaction, "Transfer Amount exceeds the maxTxnsAmount");
                require(balanceOf(to) + amount <= _amountMaxPerWallet, "Transfer amount exceeds the maxWalletAmount.");
            }
        }

        balances[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }

    function runSwap(uint256 amount) private {
        uint256 contractBalance = amount;
        uint256 liquidityTokens = contractBalance * (buyFeeSettings.liquidity + sellFeeSettings.liquidity) / (buyFeeSettings.marketing + buyFeeSettings.liquidity + sellFeeSettings.marketing + sellFeeSettings.liquidity);
        uint256 marketingTokens = contractBalance * (buyFeeSettings.marketing + sellFeeSettings.marketing) / (buyFeeSettings.marketing + buyFeeSettings.liquidity + sellFeeSettings.marketing + sellFeeSettings.liquidity);
        uint256 totalTokensToSwap = liquidityTokens + marketingTokens;

        uint256 tokensForLiquidity = liquidityTokens.div(2);
        uint256 amountToSwapForETH = contractBalance.sub(tokensForLiquidity);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH);
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForLiquidity = ethBalance.mul(liquidityTokens).div(totalTokensToSwap);
        addLiquidity(tokensForLiquidity, ethForLiquidity);
        payable(marketingWallet).transfer(address(this).balance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount} (
            address(this),
            tokenAmount,
            0,
            0,
            liquidityWallet,
            block.timestamp
        );
    }
}