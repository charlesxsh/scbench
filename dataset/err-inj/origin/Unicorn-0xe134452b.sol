/**

██╗░░░██╗███╗░░██╗██╗░█████╗░░█████╗░██████╗░███╗░░██╗
██║░░░██║████╗░██║██║██╔══██╗██╔══██╗██╔══██╗████╗░██║
██║░░░██║██╔██╗██║██║██║░░╚═╝██║░░██║██████╔╝██╔██╗██║
██║░░░██║██║╚████║██║██║░░██╗██║░░██║██╔══██╗██║╚████║
╚██████╔╝██║░╚███║██║╚█████╔╝╚█████╔╝██║░░██║██║░╚███║
░╚═════╝░╚═╝░░╚══╝╚═╝░╚════╝░░╚════╝░╚═╝░░╚═╝╚═╝░░╚══╝

Telegram: https://t.me/unicorn_portal

Website:  https://unicorneth.org

**/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) 
    internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);

    function token0() external view returns (address);
    function token1() external view returns (address);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function initialize(address, address) external;
}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA, address tokenB,
        uint256 amountADesired, uint256 amountBDesired,
        uint256 amountAMin, uint256 amountBMin,
        address to, uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token, uint256 amountTokenDesired,
        uint256 amountTokenMin, uint256 amountETHMin,
        address to, uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint256 liquidity,
        uint256 amountAMin, uint256 amountBMin,
        address to, uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token, uint256 liquidity,
        uint256 amountTokenMin, uint256 amountETHMin,
        address to, uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint256 liquidity,
        uint256 amountAMin, uint256 amountBMin,
        address to, uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token, uint256 liquidity,
        uint256 amountTokenMin, uint256 amountETHMin,
        address to, uint256 deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

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
    address private _owner;
    bool public ownershipRenounced = false;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// Remember to change "MyToken" name to your token name
contract Unicorn is Context, IERC20, Ownable {

    // TOKENOMICS START ==========================================================>

    using Address for address;
    address public constant deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint8 public constant decimals = 18;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    event Log(string, uint256);
    event AuditLog(string, address);
    event RewardLiquidityProviders(uint256 tokenAmount);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    event MaxTxAmountUpdated(uint256 newMaxTxAmount);
    event MaxWalletAmountUpdated(uint256 newMaxWalletAmount);

    // EDIT FROM HERE ================>

    address payable public marketingWallet = payable(0x121259519b182Bd4230611499A8d05C82AEB6F4f);
    uint256 private _tTotal = 150_000_000_000_000 ether;  // Total Supply 150000000000000
    string public constant name = "Unicorn";  // Token Name  
    string public constant symbol = "UNICORN";  // Token Symbol
    uint256 public initialBuyFee = 1;  // Initial Buy Fee (up to 15%)
    uint256 public initialSellFee = 1;  // Initial Sell Fee (up to 15%)
    uint256 public finalBuyFee = 1;  // 2% Final Fee (during renounce)
    uint256 public finalSellFee = 1;  // 2% Final Fee (during renounce)
    uint256 public maxTxAmount = 0 ether;  // 1% default
    uint256 public maxWalletAmount = 0 ether;  // 1% default
    uint256 public minimumTokensBeforeSwap = 15_000_000_000 ether;  // 0.01% default (Sets a threshold of tokens that must be collected in the contract before a swap operation is triggered)

    // EDIT ENDS HERE ================>

    uint256 public marketingTokensCollected = 0 ether; // Keeps track of the number of tokens collected for marketing
    uint256 public totalMarketingTokensCollected = 0 ether;  // Total of tokens collected for marketing purposes over the lifetime of the contract
    uint256 public swapOutput = 0 ether;  // To store the result or output of a swap operation
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private immutable WETH;
    uint256 private _tFeeTotal;
    bool private tradingOpen;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    // TOKENOMICS END ============================================================>

constructor() {
    address currentRouter;

    if (block.chainid == 56) {
        currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS
        _isExcludedFromFee[0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE] = true;
    } else if (block.chainid == 97) {
        currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PCST
        _isExcludedFromFee[0x5E5b9bE5fd939c578ABE5800a90C566eeEbA44a5] = true;
    } else if (block.chainid == 43114) {
        currentRouter = 0x60aE616a2155Ee3d9A68541Ba4544862310933d4; // Avax
        _isExcludedFromFee[0x9479C6484a392113bB829A15E7c9E033C9e70D30] = true;
    } else if (block.chainid == 42161) {
        currentRouter = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506; // Arbitrum
        _isExcludedFromFee[0xeBb415084Ce323338CFD3174162964CC23753dFD] = true;
    } else if (block.chainid == 1 || block.chainid == 5) {
        currentRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Mainnet
        _isExcludedFromFee[0x71B5759d73262FBb223956913ecF4ecC51057641] = true;
    } else {
        revert("You're not Blade");
    }

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
    WETH = _uniswapV2Router.WETH();
    uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), WETH);
    uniswapV2Router = _uniswapV2Router;

    _approve(msg.sender, address(uniswapV2Router), type(uint256).max);
    _approve(address(this), address(uniswapV2Router), type(uint256).max);

    _isExcludedFromFee[owner()] = true;
    _isExcludedFromFee[address(this)] = true;
    _isExcludedFromFee[marketingWallet] = true;

    _tOwned[owner()] = _tTotal;
    emit Transfer(address(0), owner(), _tTotal);
    _transferOwnership(owner());

}
    // FUNCTIONS ============================================================>

    function renounceOwnership() public virtual onlyOwner {
        initialSellFee = finalSellFee;
        initialBuyFee = finalBuyFee; 
        ownershipRenounced = true; 
        _transferOwnership(address(0)); 
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function isExcludedFromFee(address account) external view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function setMaxTxAmount(uint256 newMaxTxAmount) external onlyOwner {
        maxTxAmount = newMaxTxAmount;
        emit MaxTxAmountUpdated(newMaxTxAmount);
    }

    function setMaxWalletAmount(uint256 newMaxWalletAmount) external onlyOwner {
        maxWalletAmount = newMaxWalletAmount;
        emit MaxWalletAmountUpdated(newMaxWalletAmount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            _tOwned[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        require(tradingOpen || _isExcludedFromFee[from] || _isExcludedFromFee[to], "Trading not yet enabled!");
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;
        uint fee = 0;

        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            overMinimumTokenBalance &&
            swapAndLiquifyEnabled
        ) {
            swapAndLiquify();
        }
        if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
            fee = (initialSellFee * amount) / 100;
        }
        if (from == uniswapV2Pair && !_isExcludedFromFee[to]) {
            fee = (initialBuyFee * amount) / 100;
        }
        amount -= fee;
        if (fee > 0) {
            _tokenTransfer(from, address(this), fee);
            marketingTokensCollected += fee;
            totalMarketingTokensCollected += fee;
        }
        _tokenTransfer(from, to, amount);
    }

    function swapAndLiquify() public lockTheSwap {
        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        uint ethBalance = address(this).balance;
        transferToAddressETH(marketingWallet, ethBalance);
        marketingTokensCollected = 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _tOwned[sender] -= amount;
        _tOwned[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function excludeFromFee(address account) external onlyOwner {
        require(_isExcludedFromFee[account] != true, "The wallet is already excluded!");
        _isExcludedFromFee[account] = true;
        emit AuditLog(
            "We have excluded the following walled in fees:",
            account
        );
    }

    function includeInFee(address account) external onlyOwner {
        require(_isExcludedFromFee[account] != false, "The wallet is already included!");
        _isExcludedFromFee[account] = false;
        emit AuditLog(
            "We have including the following walled in fees:",
            account
        );
    }

    function setTokensToSwap(
        uint256 _minimumTokensBeforeSwap
    ) external onlyOwner {
        require(
            _minimumTokensBeforeSwap >= 100 ether,
            "You need to enter more than 100 tokens."
        );
        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit Log(
            "We have updated minimunTokensBeforeSwap to:",
            minimumTokensBeforeSwap
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        require(swapAndLiquifyEnabled != _enabled, "Value already set");
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != address(0), "setmarketingWallet: ZERO");
        marketingWallet = payable(_marketingWallet);
        emit AuditLog("We have Updated the MarketingWallet:", marketingWallet);
    }

    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        (bool succ, ) = recipient.call{value: amount}("");
        require(succ, "Transfer failed.");
    }

    receive() external payable {}

    event SwapETHForTokens(uint256 amountIn, address[] path);

    function swapETHForTokens(uint256 amount) private {

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            swapOutput,
            path,
            deadWallet,
            block.timestamp + 300
        );
        emit SwapETHForTokens(amount, path);
    }

    function recoverETHfromContract() external onlyOwner {
        uint ethBalance = address(this).balance;
        (bool succ, ) = payable(marketingWallet).call{value: ethBalance}("");
        require(succ, "Transfer failed");
        emit AuditLog(
            "We have recover the stuck eth from contract.",
            marketingWallet
        );
    }

    function recoverTokensFromContract(
        address _tokenAddress,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        bool succ = IERC20(_tokenAddress).transfer(marketingWallet, _amount);
        require(succ, "Transfer failed");
        emit Log("We have recovered tokens from contract:", _amount);
    }

        function enableTrading() external onlyOwner{
        require(!tradingOpen, "Trading already enabled.");
        tradingOpen = true;
        swapAndLiquifyEnabled = true;
        emit AuditLog("We have Enable Trading and Automatic Swaps:", msg.sender);
    }
}