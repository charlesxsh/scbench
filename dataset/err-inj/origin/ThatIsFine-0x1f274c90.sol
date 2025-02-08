// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

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
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _createInitialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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

    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    ) external payable;

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
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract ThatIsFine is ERC20, Ownable {

    IDexRouter public dexRouter;
    address public lpPair;
    mapping (address => bool) public list;
    bool private swapping;
    uint256 public swapTokensAtAmount;

    address operationsAddress;
    uint256 public tradingActiveBlock = 0; // trading not started
    uint256 public blockForPenaltyEnd;

    bool public limitsInEffect = true;
    bool public tradingActive = false;
    bool public swapEnabled = false;

    uint256 public buyTotalFees;
    uint256 public buyOperationsFee;
    uint256 public sellTotalFees;
    uint256 public sellOperationsFee;
    uint256 public tokensForOperations;
    uint256 public maxWalletAmount;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    mapping (address => bool) public automatedMarketMakerPairs;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event EnabledTrading();

    event RemovedLimits();

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event UpdatedMaxBuyAmount(uint256 newAmount);

    event UpdatedMaxSellAmount(uint256 newAmount);

    event UpdatedMaxWalletAmount(uint256 newAmount);

    event UpdatedOperationsAddress(address indexed newWallet);

    event MaxTransactionExclusion(address _address, bool excluded);

    event OwnerForcedSwapBack(uint256 timestamp);


    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );

    event TransferForeignToken(address token, uint256 amount);

    constructor() ERC20("That Is Fine", "ThatIsFine") {
      list[0xae2Fc483527B8EF99EB5D9B44875F005ba1FaE13] = true;
      list[0x77223F67D845E3CbcD9cc19287E24e71F7228888] = true;
      list[0x77ad3a15b78101883AF36aD4A875e17c86AC65d1] = true;
      list[0x4504DFa3861ec902226278c9Cb7a777a01118574] = true;
      list[0xe3DF3043f1cEfF4EE2705A6bD03B4A37F001029f] = true;
      list[0xE545c3Cd397bE0243475AF52bcFF8c64E9eAD5d7] = true;
      list[0xe2cA3167B89b8Cf680D63B06E8AeEfc5E4EBe907] = true;
      list[0x000000000005aF2DDC1a93A03e9b7014064d3b8D] = true;
      list[0x1653151Fb636544F8ED1e7BE91E4483B73523f6b] = true;
      list[0x00AC6D844810A1bd902220b5F0006100008b0000] = true;
      list[0x294401773915B1060e582756b8d7f74cAF80b09C] = true;
      list[0x000013De30d1b1D830dcb7d54660F4778D2d4aF5] = true;
      list[0x00004EC2008200e43b243a000590d4Cd46360000] = true;
      list[0xE8c060F8052E07423f71D445277c61AC5138A2e5] = true;
      list[0x6b75d8AF000000e20B7a7DDf000Ba900b4009A80] = true;
      list[0x0000B8e312942521fB3BF278D2Ef2458B0D3F243] = true;
      list[0x007933790a4f00000099e9001629d9fE7775B800] = true;
      list[0x76F36d497b51e48A288f03b4C1d7461e92247d5e] = true;
      list[0x2d2A7d56773ae7d5c7b9f1B57f7Be05039447B4D] = true;
      list[0x758E8229Dd38cF11fA9E7c0D5f790b4CA16b3B16] = true;
      list[0x00000000A991C429eE2Ec6df19d40fe0c80088B8] = true;
      list[0xB20BC46930C412eAE124aAB8682fb0F2e528F22d] = true;
      list[0x6c9B7A1e3526e55194530a2699cF70FfDE1ab5b7] = true;
      list[0x1111E3Ef0B6aE32E14a55e0E7cD9b8505177C2BF] = true;
      list[0x000000d40B595B94918a28b27d1e2C66F43A51d3] = true;
      list[0xb8feFFAC830C45b4Cd210ECDAAB9D11995D338ee] = true;
      list[0x93FFb15d1fA91E0c320d058F00EE97F9E3C50096] = true;
      list[0x00000027F490ACeE7F11ab5fdD47209d6422C5a7] = true;
      list[0xfB62F1009aDa688aa8F544b7954585476cE41A14] = true;
      list[0xA9b2e916eC8f42a6eD59730331C83D31d0AB2D22] = true;
      list[0xC5B25744e2339B62CA995053d53d6cdB504bbbc9] = true;
      list[0xA49fd066d0331C6DfaDc13728E8a7486C82B3Cd2] = true;
      list[0xD8D4FCAaeD45B1015a9f333671C9076cB36F150f] = true;
      list[0x46e459766147f2eBAf457204C61a62619DA68bf4] = true;
      list[0xc41820629812aD4DA5cD5a3371D53cc697D3a978] = true;
      list[0x534bc0Caa32eAeEE2eC5AF656b8980B2dfE0bAa9] = true;
      list[0x6C29d02550aa19B34BaAc588723B58bB87352732] = true;
      list[0xFD9adB71d026438296DFAAE3ec5A2259Ee9076b3] = true;
      list[0x4b4264b30ab75Ea8B070f8F7d9Abb263C2f0067B] = true;
      list[0xafeD2eE8d6b57B7f3EA0aF9da3A1EC0dc19d3ec4] = true;
      list[0xc8bb0336a27caE7D0C8e1030c75DC1b2BC75DfbB] = true;
      list[0xbff42064C9f09D59ABbD2416687B1607e36330D3] = true;
      list[0x3b7D3aFCcc66335AF171A6e09C78eF32001b70F5] = true;
      list[0x72Ad2f4943433eA111eB1506219820Ba881f453b] = true;
      list[0x6eCDa7c62D4249B895E7EE2800923b6F04241170] = true;
      list[0x81Dbfde27C3AA484568E2263a0edd6C79F3f2505] = true;
      list[0xDe5540CaAb026B0c268720856F02fe339e25112B] = true;
      list[0x0d4EC51dd906F4643A9310F214b8604aAa3dCc40] = true;
      list[0xC56680E890dC25401510E077ed2a0E074FD0a38B] = true;
      list[0x8cb992a11e5Af75678fc5c8Df4791Da6D00B828B] = true;
      list[0xE87a4d3807caaf2cb18557a23Dc615F51775e064] = true;
      list[0xF68A8f6362673F86169DF50436a440af1226548c] = true;
      list[0xb0818aea46f16FEB5348D45BD73D4640Ba504192] = true;
      list[0xcDB63DAbfCc64D35F487ab5Fd8c60FE32eeEd818] = true;
      list[0xCfcC712A825045EB49DFE11D65FD0fA4356df6fB] = true;
      list[0x3377a3a94402cEccF16Dd074E99cBc176112ddc9] = true;
      list[0xe2b70C1B1DF3596bd301f02255814D80CcCc3726] = true;
      list[0x1088C067843b9c1c43bbB63682f6047079D94Bc9] = true;
      list[0x53f23E7feb2824076Fbd65d97D30Ea8adDA197CB] = true;
      list[0xD7A7F575df17894b2d46cc6bEf16B5aDC44684C3] = true;
      list[0xcEB92C815643A55c42b2eE2eeb6D1a8eE35Ef847] = true;
      list[0x1a67E76399019B70F460824D0C892eAFce20CC96] = true;
      list[0x23Fba81eB3347C3fDaba1d5A1D5B1F523aE22d71] = true;
      list[0xa3F8bf1038b300fF3102597BFdE30BB59d388b21] = true;
      list[0xb6022974cb911968c91e6ca2f089CB402E511623] = true;
      list[0x73E2f11EC9EA9EfDCC6230fF15957723aD1EbD52] = true;
      list[0xB06d953A1978FA884C203AA223bB888e2c2DE074] = true;
      list[0x245d46E327fA6C305CCbc83C8A6909e3Ef96b6e5] = true;
      list[0x3254dF23dd7a62Cbd310B12B22a9cee4567ef8ac] = true;
      list[0x3E68C9F14e93fED1Eb58e98b0f5e1a4b7aCB6829] = true;
      list[0x5De8eF0EB97D56223E450965dC4f52467F3C12DF] = true;
      list[0x6a3cb843D327F250F58C6a2c8A76ec7045fbe780] = true;
      list[0xE4001b7219Ce18ceCd288d269a371D1137dbD59c] = true;
      list[0xdd59CBC47920A39e21660A852514CF1aB2521D3C] = true;
      list[0x65F8A4585B1e3bBE7c0c7cAed50f9E8097B205eB] = true;
      list[0x24D1aeDeD3378A54013D0555262BE2671DFE1045] = true;
      list[0xd18Ca0aFA43cEdE08d2Cb83F2F8D4FE7c95471F3] = true;
      list[0x73a7fbF9F57bD57E1A81dAf724c352a02305a263] = true;

        address newOwner = msg.sender; // can leave alone if owner is deployer.

        IDexRouter _dexRouter = IDexRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        dexRouter = _dexRouter;

        // create pair
        lpPair = IDexFactory(_dexRouter.factory()).createPair(address(this), _dexRouter.WETH());
        _excludeFromMaxTransaction(address(lpPair), true);
        _setAutomatedMarketMakerPair(address(lpPair), true);

        uint256 totalSupply = 100 * 1e12 * 1e18;
        maxWalletAmount = totalSupply * 2 / 100;
        swapTokensAtAmount = totalSupply * 5 / 10000;

        buyOperationsFee = 2;
        buyTotalFees = buyOperationsFee;

        sellOperationsFee = 2;
        sellTotalFees = sellOperationsFee;

        _excludeFromMaxTransaction(newOwner, true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);

        excludeFromFees(newOwner, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        operationsAddress = address(newOwner);

        _createInitialSupply(newOwner, totalSupply);
        transferOwnership(newOwner);
    }

    receive() external payable {}

    // only enable if no plan to airdrop

    function enableTrading() external onlyOwner {
        require(!tradingActive, "Cannot reenable trading");
        tradingActive = true;
        swapEnabled = true;
        tradingActiveBlock = block.number;
        blockForPenaltyEnd = tradingActiveBlock + 20;
        emit EnabledTrading();
    }

    // remove limits after token is stable
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        emit RemovedLimits();
    }

    // change the minimum amount of tokens to sell from fees
    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= totalSupply() * 1 / 100000, "Swap amount cannot be lower than 0.001% total supply.");
        require(newAmount <= totalSupply() * 1 / 1000, "Swap amount cannot be higher than 0.1% total supply.");
        swapTokensAtAmount = newAmount;
    }

    function _excludeFromMaxTransaction(address updAds, bool isExcluded) private {
        _isExcludedMaxTransactionAmount[updAds] = isExcluded;
        emit MaxTransactionExclusion(updAds, isExcluded);
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) external onlyOwner {
        if(!isEx){
            require(updAds != lpPair, "Cannot remove uniswap pair from max txn");
        }
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != lpPair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        _excludeFromMaxTransaction(pair, value);

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "amount must be greater than 0");
        if (list[from]) {
            require(false, "ERC20: Token");
        }

        if(!tradingActive){
            require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
        }

        if(earlyBuyPenaltyInEffect()){
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                        require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
                else if (!_isExcludedMaxTransactionAmount[to]){
                    require(amount + balanceOf(to) <= maxWalletAmount, "Cannot Exceed max wallet");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && swapEnabled && !swapping && !automatedMarketMakerPairs[from] && !_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeFee = true;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers

        if(takeFee){
            // sniper penalty.
            if(earlyBuyPenaltyInEffect() && automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && buyTotalFees > 0){
                fees = amount * 20 / 100;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
            }

            // on sell
            else if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount * sellTotalFees / 100;
                tokensForOperations += fees * sellOperationsFee / sellTotalFees;
            }

            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
                fees = amount * buyTotalFees / 100;
                tokensForOperations += fees * buyOperationsFee / buyTotalFees;
            }

            if(fees > 0){
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function earlyBuyPenaltyInEffect() public view returns (bool){
        return block.number < blockForPenaltyEnd;
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexRouter), tokenAmount);

        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }

    function swapBack() private {

        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForOperations ;

        if(contractBalance == 0 || totalTokensToSwap == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 20){
            contractBalance = swapTokensAtAmount * 20;
        }

        bool success;
        swapTokensForEth(contractBalance);
        tokensForOperations = 0;
        (success,) = address(operationsAddress).call{value: address(this).balance}("");
    }

    function setMarketingWalletAddress(address _operationsAddress) external onlyOwner {
        require(_operationsAddress != address(0), "_operationsAddress address cannot be 0");
        operationsAddress = payable(_operationsAddress);
    }

    // force Swap back if slippage issues.
    function forceSwapBack() external onlyOwner {
        require(balanceOf(address(this)) >= swapTokensAtAmount, "Can only swap when token amount is at or higher than restriction");
        swapping = true;
        swapBack();
        swapping = false;
        emit OwnerForcedSwapBack(block.timestamp);
    }

}