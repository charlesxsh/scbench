// SPDX-License-Identifier: MIT
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

// File: @openzeppelin\contracts\access\Ownable.sol

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: contracts\SigilTGA.sol

pragma solidity ^0.8.0;

interface SigilStaking {
    function getUserStakingAmount(address user) external view returns (uint256);
}

struct stake {
    uint256 stakedAmount;
    uint256 dateAtStake;
    uint256 totalFeesAtEntry;
}

interface OldSigilStaking {
    function _accountStakingInfo(
        address,
        uint256
    ) external view returns (stake memory);

    function _amountOfStakes(address) external view returns (uint256);
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address _owner) external view returns (uint256 balance);
}

contract SigilTGA is Ownable {
    address public sigilTokenAddress;
    address public oldSigilStakingAddress;

    bool isOldStakes = true;
    address[] public sigilStakingAddress;

    constructor(address _oldStakingAddress, address _sigilTokenAddress) {
        oldSigilStakingAddress = _oldStakingAddress;
        sigilTokenAddress = _sigilTokenAddress;
    }

    function changeOldStakingContract(bool _status) public onlyOwner {
        isOldStakes = _status;
    }

    function changeTokenAddress(address newAddress) public onlyOwner {
        sigilTokenAddress = newAddress;
    }

    function addNewStakingContract(address _newStakeContract) public onlyOwner {
        sigilStakingAddress.push(_newStakeContract);
    }

    function removeStakingContract(
        address _removeStakeContract
    ) public onlyOwner {
        uint256 beforeLen = sigilStakingAddress.length;
        for (uint256 i = 0; i < sigilStakingAddress.length; i++) {
            if (sigilStakingAddress[i] == _removeStakeContract) {
                sigilStakingAddress[i] = sigilStakingAddress[
                    sigilStakingAddress.length - 1
                ];
                sigilStakingAddress.pop();
                break;
            }
        }
        require(
            beforeLen - 1 == sigilStakingAddress.length,
            "Nothing is removed"
        );
    }

    function decimals() public view returns (uint8) {
        return IERC20(sigilTokenAddress).decimals();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        uint256 walletBalance = IERC20(sigilTokenAddress).balanceOf(_owner);
        balance += walletBalance;

        if (sigilStakingAddress.length > 0) {
            uint256 newStakes = 0;
            for (uint256 i = 0; i < sigilStakingAddress.length; i++) {
                newStakes += SigilStaking(sigilStakingAddress[i])
                    .getUserStakingAmount(_owner);
            }
            balance += walletBalance;
        }

        if (isOldStakes) {
            uint256 oldStakes = 0;
            uint256 amountOfStakes = OldSigilStaking(oldSigilStakingAddress)
                ._amountOfStakes(_owner);
            if (amountOfStakes > 0) {
                for (uint256 i = 0; i < amountOfStakes; i++) {
                    stake memory stakes = OldSigilStaking(
                        oldSigilStakingAddress
                    )._accountStakingInfo(_owner, i);
                    oldStakes += stakes.stakedAmount;
                }
            }

            balance += oldStakes;
        }

        return balance;
    }
}