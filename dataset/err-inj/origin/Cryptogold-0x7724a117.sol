// SPDX-License-Identifier: MIT

/*
Website: https://cryptogoldtoken.org
Telegram: https://t.me/cryptogold_token
*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

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

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
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
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Cryptogold is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isPairWithFee;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    string private _decimals;
    address payable private devWallet;
    uint public immutable maxFee;
    uint public buyFee;
    uint public sellFee;
    uint public denominator;
    uint public minTokenToSwap;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private inSwap = false;

    modifier lockLiquify() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwnerOrDev() {
        require(_msgSender() == owner() || _msgSender() == devWallet);
        _;
    }

    constructor() {
        _name = "Cryptogold";
        _symbol = "CRYPTOGOLD";
        devWallet = payable(0xc243F3e110064E4B07103Bf9E1ec9c7e90f5Cf00);
        buyFee = 10; //1%
        sellFee = 10; //1%
        maxFee = 20; //Max 2% immutable
        denominator = 1000;
        minTokenToSwap = 1_000_000 * 10 ** decimals();
        _totalSupply = 100_000_000 * 10 ** decimals();
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        address factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        address token0 = address(this); 
        address token1 = _uniswapV2Router.WETH(); 

        uniswapV2Pair = address(
            uint160(uint(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
                    )
                )
            ))
        );

        isPairWithFee[uniswapV2Pair] = true;
        uniswapV2Router = _uniswapV2Router;
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[devWallet] = true;
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

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        uint contractBalance = balanceOf(address(this));
        if (
            isPairWithFee[to] &&
            contractBalance >= minTokenToSwap &&
            !inSwap
        ) {
            liquify();
        }

        bool takeFee = false;
        uint netAmount = amount;
        uint feeAmount = 0;
        if (isPairWithFee[from] == true && !isExcludedFromFee[to]) {
            takeFee = true;
            feeAmount = (amount * buyFee) / denominator;
            netAmount = amount - feeAmount;
        } else if (!isExcludedFromFee[from] && isPairWithFee[to] == true) {
            takeFee = true;
            feeAmount = (amount * sellFee) / denominator;
            netAmount = amount - feeAmount;
        }

        _balances[from] = fromBalance - amount;
        _balances[to] += netAmount;

        emit Transfer(from, to, amount);

        if (takeFee == true) {
            _balances[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function setFee(uint _buyFee, uint _sellFee) external onlyOwner {
        require(_buyFee <= maxFee, "Buy fee exceed max");
        require(_sellFee <= maxFee, "Sell fee exceed max");
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    function excludeFromFee(address account, bool isExclude) public onlyOwnerOrDev {
        isExcludedFromFee[account] = isExclude;
    }

    function pairWithFee(address account, bool isPair) public onlyOwnerOrDev {
        isPairWithFee[account] = isPair;
    }

    function setMinTokenToSwap(uint amount) external onlyOwnerOrDev {
        minTokenToSwap = amount;
    }

    function setDevWallet(address account) public onlyOwnerOrDev {
        devWallet = payable(account);
        isExcludedFromFee[devWallet] = true;
    }

    function swapTokensForETH(uint tokenAmount) internal {
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

    function sendETHToWallet(address payable wallet, uint amount) private {
        wallet.transfer(amount);
    }

    function liquify() internal lockLiquify {
        uint contractBalance = balanceOf(address(this));
        swapTokensForETH(contractBalance);
        uint contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToWallet(devWallet, contractETHBalance);
        }
    }

    function manualSwap() external {
        require(_msgSender() == devWallet);
        uint contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No tokens to swap");
        swapTokensForETH(contractBalance);
    }

    function manualSend() external {
        require(_msgSender() == devWallet);
        uint contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "No ETH to send");
        sendETHToWallet(devWallet, contractETHBalance);
    }

    receive() external payable {}
}