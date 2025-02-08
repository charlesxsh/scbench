// SPDX-License-Identifier: MIT
// Contract published on behalf of Nova DAO LLC for NovaDAO.
// This contract is provided as-is without any warranties or guarantees.

/*
 * Nova DAO
 * https://nova-dao.com / https://novadao.io
 * X/Twitter: https://x.com/0xNovaDAO
 */
 
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: DogiraTokenDeposit.sol


pragma solidity 0.8.16;



contract DogiraTokenDeposit is Ownable {
    
    IERC20 public dogiraToken;
    
    address constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    mapping(address => User) public users;
    mapping(address => bool) public suspendList;
    address[] public depositors;
    
    struct User {
        uint256 total_tokens_deposited;
        uint256 total_tokens_claimed;
        uint256 nova_tokens_conv;
    }
    
    event TokensDeposited(address indexed user, uint256 tokens_sent, uint256 tokens_due);
    uint256 public deployTime;
    
    modifier contractActive() {
        require(block.timestamp <= deployTime + 90 days, "Contract functionality has been disabled");
        _;
    }
    
    constructor(address _dogiraToken) {
        dogiraToken = IERC20(_dogiraToken);
        deployTime = block.timestamp;
    }

    function addToSuspendList(address user) external onlyOwner {
        suspendList[user] = true;
    }

    function removeFromSuspendList(address user) external onlyOwner {
        suspendList[user] = false;
    }
    
    function deposit(uint256 amount) external contractActive {
        require(!suspendList[msg.sender], "Your address is suspended from deposits: please contact a member of the Nova Council at t.me/NovaDAOPortal.");
        require(amount >= 10000 * (10 ** 9), "Deposit amount too low");
        
        uint256 tokens_due = amount * (10 ** 9); // Conversion from 9 decimals to 18 decimals
        users[msg.sender].total_tokens_deposited += amount;
        users[msg.sender].nova_tokens_conv += tokens_due;
        
        require(dogiraToken.transferFrom(msg.sender, DEAD_ADDRESS, amount), "Token transfer failed");
        
        // Add the user to the depositors array if they're not already awaiting a deposit
        if(users[msg.sender].total_tokens_deposited == amount) {
            depositors.push(msg.sender);
        }

        emit TokensDeposited(msg.sender, amount, tokens_due);
    }
    
    function process_claims(address[] calldata addresses, uint256[] calldata amounts) external onlyOwner {
        require(addresses.length == amounts.length, "Mismatched array lengths");
        
        for(uint256 i = 0; i < addresses.length; i++) {
            users[addresses[i]].total_tokens_claimed += amounts[i];
            
            for(uint256 j = 0; j < depositors.length; j++) {
                if(depositors[j] == addresses[i]) {
                    depositors[j] = depositors[depositors.length - 1];
                    depositors.pop();
                    break;
                }
            }
        }
    }
    
    function getDepositors() external view returns(address[] memory) {
        return depositors;
    }
}