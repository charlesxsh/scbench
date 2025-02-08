// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/IRYAPresale.sol


pragma solidity ^0.8.19;

// Import the IERC20 interface


contract IRYAPresale {
    // Presale parameters
    address private __admin;
    address private __owner;
    uint256 private __startTime;
    uint256 private __endTime;
    uint256 private __rate;
    uint256 private __hardCap;
    uint256 private __totalSupply;
    uint256 private __weiRaised;
    address private __token;
    uint256 private __presaleStarted;

    // Mapping to track token balances of investors
    mapping(address => uint256) private _holders;

    // Events
    event TokensPurchased(address indexed buyer, uint256 weiAmount, uint256 tokenAmount);
    event PresaleStarted(address indexed admin);
    event PresaleStopped(address indexed admin);

    // Modifier to restrict access to the admin
    modifier onlyAdmin() {
        require(msg.sender == __admin, "Only admin can call this function!");
        _;
    }

    // Modifier to check if presale is active
    modifier isPresaleActive() {
        require(__presaleStarted == 1, "Presale is not active");
        require(block.timestamp >= __startTime && block.timestamp <= __endTime, "Presale is not within the valid timeframe");
        require(__weiRaised < __hardCap, "Hard cap reached, presale is closed");
        _;
    }

    constructor() {
        __admin = msg.sender;
        __owner = address(this); // Set contract address as the owner initially
    }

    function startPresale(
        address tokenAddress,
        uint256 startTime,
        uint256 endTime,
        uint256 rate,
        uint256 hardCap,
        uint256 totalSupply
    ) external onlyAdmin {
        require(__presaleStarted == 0, "Presale is already started");
        require(tokenAddress != address(0), "Token address must not be zero address");
        require(startTime > block.timestamp, "Start time must be in the future");
        require(endTime > startTime, "End time must be later than start time");
        require(rate > 0, "Rate must be greater than zero");
        require(totalSupply > 0, "Total supply must be greater than zero");
        require(hardCap > 0, "Hard cap must be greater than zero");

        __token = tokenAddress;
        __startTime = startTime;
        __endTime = endTime;
        __rate = rate;
        __hardCap = hardCap;
        __totalSupply = totalSupply;
        __presaleStarted = 1;
        _holders[address(this)] = totalSupply;

        emit PresaleStarted(__admin);
    }

    function stopPresale() external onlyAdmin {
        require(__presaleStarted == 1, "Presale is not started");
        __presaleStarted = 0;
        emit PresaleStopped(__admin);
    }

    function buyTokens() external payable isPresaleActive {
        uint256 weiAmount = msg.value;
        require(weiAmount >= __rate, "Wei amount must be greater than or equal to the rate");

        // Calculate the token amount to be sent to the buyer
        uint256 tokensToTransfer = weiAmount * __rate;
        require(tokensToTransfer <= _holders[address(this)], "Insufficient tokens in the presale contract");

        // Transfer tokens to the buyer
        _holders[address(this)] -= tokensToTransfer;
        _holders[msg.sender] += tokensToTransfer;

        // Update total wei raised
        __weiRaised += weiAmount;

        // Emit an event for the token purchase
        emit TokensPurchased(msg.sender, weiAmount, tokensToTransfer);
    }

    // Other getter functions to retrieve presale parameters and token details
    // ... (implement these functions based on your needs)

    // Function to withdraw remaining tokens after presale ends
    function withdrawRemainingTokens() external onlyAdmin {
        require(__presaleStarted == 0, "Presale is still active");
        require(__weiRaised == __hardCap, "Presale is not fully funded");
        require(__token != address(0), "Invalid token address");

        uint256 remainingTokens = _holders[address(this)];
        _holders[address(this)] = 0;

        // Transfer remaining tokens to the contract admin
        require(IERC20(__token).transfer(__admin, remainingTokens), "Token transfer failed");
    }
}