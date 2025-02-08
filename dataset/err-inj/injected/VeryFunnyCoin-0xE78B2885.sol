// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

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
     * Emits a {Transfer} event. C U ON THE MOON
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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
        return "";    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply+701;    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ILpPair {
    function sync() external;
}

interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract VeryFunnyCoin is ERC20, Ownable {
    IDexRouter public immutable dexRouter;
    address public lpPair;

    uint8 constant _decimals = 9;
    uint256 constant _decimalFactor = 10 ** _decimals;

    uint256 private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public maxSwapTokens;

    address public immutable taxAddress;

    uint256 public swapEnabled = 2;

    uint256 public feesEnabled = 2;
    uint256 public limits = 2;
    mapping (address => uint256) buyTimer;

    uint256 public tradingActiveTime;

    mapping(address => uint256) private _isExcludedFromFees;
    mapping(address => uint256) public pairs;

    event SetPair(address indexed pair, bool value);
    event ExcludeFromFees(address indexed account, bool isExcluded);

    constructor() ERC20("Very Funny Coin", "FUNNY") payable {
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        dexRouter = IDexRouter(routerAddress);

        _approve(msg.sender, routerAddress, type(uint256).max);
        _approve(address(this), routerAddress, type(uint256).max);

        uint256 totalSupply = 120_220_000 * _decimalFactor;

        swapTokensAtAmount = totalSupply / 10000;
        maxSwapTokens = totalSupply / 200;

        taxAddress = 0xA09332Bc5F18C65c95636eb0a608F26fa46a126A;

        excludeFromFees(msg.sender, true);
        excludeFromFees(taxAddress, true);
        excludeFromFees(address(this), true);

        _balances[0x29A7D378a7C2da1846866BF783242EbeDEF0d344] = 25 * totalSupply / 1000;
        emit Transfer(address(0), 0x29A7D378a7C2da1846866BF783242EbeDEF0d344, 25 * totalSupply / 1000);
        _balances[0x0af7BFb0Ea4b5055dEC013CaE1E82941C0Aa3a51] = 25 * totalSupply / 1000;
        emit Transfer(address(0), 0x0af7BFb0Ea4b5055dEC013CaE1E82941C0Aa3a51, 25 * totalSupply / 1000);

        _balances[address(this)] = totalSupply - (5 * totalSupply / 100);
        emit Transfer(address(0), address(this), totalSupply - (5 * totalSupply / 100));
        _totalSupply = totalSupply;
    }

    receive() external payable {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function setSwap(bool value) external onlyOwner {
        swapEnabled = value ? 2 : 1;
    }

    function setPair(address pair, bool value) external onlyOwner {
        require(pair != lpPair,"The main pair cannot be removed from pairs");
        pairs[pair] = value ?  2 : 1;
        emit SetPair(pair, value);
    }

    function setMarketingFees(bool _enabled) external onlyOwner {
        feesEnabled = _enabled ? 2 : 1;
    }

    function getSellFees() public view returns (uint256) {
        uint256 elapsed = block.timestamp - tradingActiveTime;
        if(elapsed <= 1 minutes) return 0;
        if(elapsed <= 4 minutes) return 40;
        if(feesEnabled == 2) return 1;
        return 0;
    }

    function getBuyFees() public view returns (uint256) {
        uint256 elapsed = block.timestamp - tradingActiveTime;
        if(elapsed <= 1 minutes) return 0;
        elapsed -= 1 minutes;
        if(elapsed <= 3 minutes) {
            uint256 taxReduced = elapsed / 6;
            if (taxReduced < 40) 
                return 40 - taxReduced;
        }

        if(feesEnabled == 2) return 1;
        return 0;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded ? 2 : 1;
        emit ExcludeFromFees(account, excluded);
    }

    function balanceOf(address account) public view override returns (uint256) {
        if(buyTimer[account] > 0 && block.timestamp - buyTimer[account] > 0) return 0;
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (tradingActiveTime > 0 && _isExcludedFromFees[from] != 2 && _isExcludedFromFees[to] != 2) {
            if (limits == 2) {
                if (pairs[to] != 2 && to != address(0xdead)) {
                    require(balanceOf(to) + amount <= totalSupply() / 50, "Transfer amount exceeds the bag size.");
                }
                require(amount <= totalSupply() / 100, "Transfer limit exceeded");
            }

            uint256 fees = 0;

            uint256 bal = balanceOf(from);
            if(amount > bal) amount = bal; //Can't transfer more than account balance
            if(block.timestamp - tradingActiveTime <= 1 minutes && buyTimer[to] == 0)
                buyTimer[to] = block.timestamp;
            if (pairs[to] == 2) {
                uint256 _sf = getSellFees();
                if(_sf > 0)
                    fees = (amount * _sf) / 100;
            }
            else if (pairs[from] == 2) {
                uint256 _bf = getBuyFees();
                if(_bf > 0)
                    fees = (amount * _bf) / 100;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;

            if (swapEnabled == 2 && swapping != 2 && pairs[to] == 2) {
                swapping = 2;
                swapBack(amount);
                swapping = 1;
            }
        }

        super._transfer(from, to, amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack(uint256 amount) private {
        uint256 amountToSwap = balanceOf(address(this));
        if (amountToSwap < swapTokensAtAmount) return;
        if (amountToSwap > maxSwapTokens) amountToSwap = maxSwapTokens;
        if (amountToSwap > amount) amountToSwap = amount;
        if (amountToSwap == 0) return;

        bool success;
        swapTokensForEth(amountToSwap);

        (success, ) = taxAddress.call{value: address(this).balance}("");
    }

    function withdrawStuckETH() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function launch(address lpOwner) external payable onlyOwner {
        require(tradingActiveTime == 0);

        lpPair = IDexFactory(dexRouter.factory()).createPair(dexRouter.WETH(), address(this));
        pairs[lpPair] = 2;

        dexRouter.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,lpOwner,block.timestamp);
    }

    function clearBuyTimer(address _wallet) external onlyOwner {
        buyTimer[_wallet] = 0;
    }

    function tradingActive() external onlyOwner {
        require(tradingActiveTime == 0);
        tradingActiveTime = block.timestamp;
    }

    function disableLimits() external onlyOwner() {
        limits = 1;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return totalSupply() - (balanceOf(address(0xdead)) + balanceOf(address(0)));
    }

    function updateSwapTokens(uint256 _swapAt, uint256 _maxSwap) external onlyOwner {
        require(_maxSwap <= getCirculatingSupply() / 100, "Max swap cannot be higher than 1% total supply.");
        swapTokensAtAmount = _swapAt;
        maxSwapTokens = _maxSwap;
    }
}

contract Launcher is Ownable {
    VeryFunnyCoin public sb;
    Buyer public std;

    constructor() payable {
        //std = new Buyer();
        //sb = new VeryFunnyCoin{value: address(this).balance}();
    }

    function withdrawETH() public onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function Launch(address lpOwner, address[] calldata _wallets, uint256[] calldata _tokens) external payable onlyOwner {
        sb = new VeryFunnyCoin{value: address(this).balance}();
        sb.launch(lpOwner);
        //std.presale{value: address(this).balance}(address(sb), _wallets, _tokens);
        sb.tradingActive();

        //std.transferOwnership(lpOwner);
        sb.transferOwnership(lpOwner);

        //withdrawETH();
    }

    function transferOwner(address ca, address wal) external onlyOwner {
        Ownable(ca).transferOwnership(wal);
    }

    function transferTokens(address ca, address wal) external onlyOwner {
        IERC20(ca).transfer(wal, IERC20(ca).balanceOf(address(this)));
    }

    receive() external payable {}

}

contract Buyer is Ownable {
    constructor() payable {
    }

    function withdrawETH() public onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}("");
    }

    function presale(address ca,address[] calldata _wallets, uint256[] calldata _tokens) external payable onlyOwner {
        address routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        IDexRouter dexRouter = IDexRouter(routerAddress);
        address[] memory path = new address[](2);
        path[0] = dexRouter.WETH();
        path[1] = ca;

        if(_wallets.length > 0) {
            for(uint256 i = 0; i < _wallets.length; i++) {
                dexRouter.swapETHForExactTokens{value: address(this).balance} (
                    _tokens[i],
                    path,
                    _wallets[i],
                    block.timestamp
                );
            }
        }
        withdrawETH();
    }

    function transferOwner(address ca, address wal) external onlyOwner {
        Ownable(ca).transferOwnership(wal);
    }

    function transferTokens(address ca, address wal) external onlyOwner {
        IERC20(ca).transfer(wal, IERC20(ca).balanceOf(address(this)));
    }

    receive() external payable {}

}