// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

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
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
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

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IRepository {
    function getAdmins() external view returns (address[] memory);
    function getLogics() external view returns (address[] memory);

    function getString(bytes32 key) external view returns (string memory);
    function getBytes(bytes32 key) external view returns (bytes memory);
    function getUint(bytes32 key) external view returns (uint);
    function getInt(bytes32 key) external view returns (int);
    function getAddress(bytes32 key) external view returns (address);
    function getBool(bytes32 key) external view returns (bool);
    function getBytes32(bytes32 key) external view returns (bytes32);

    function getStringArray(bytes32 key) external view returns (string[] memory);
    function getBytesArray(bytes32 key) external view returns (bytes[] memory);
    function getUintArray(bytes32 key) external view returns (uint[] memory);
    function getIntArray(bytes32 key) external view returns (int[] memory);
    function getAddressArray(bytes32 key) external view returns (address[] memory);
    function getBoolArray(bytes32 key) external view returns (bool[] memory);
    function getBytes32Array(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedStringArray(bytes32 key, uint index) external view returns (string memory);
    function getIndexedBytesArray(bytes32 key, uint index) external view returns (bytes memory);
    function getIndexedUintArray(bytes32 key, uint index) external view returns (uint);
    function getIndexedIntArray(bytes32 key, uint index) external view returns (int);
    function getIndexedAddressArray(bytes32 key, uint index) external view returns (address);
    function getIndexedBoolArray(bytes32 key, uint index) external view returns (bool);
    function getIndexedBytes32Array(bytes32 key, uint index) external view returns (bytes32);
    
    function getLengthStringArray(bytes32 key) external view returns (uint);
    function getLengthBytesArray(bytes32 key) external view returns (uint);
    function getLengthUintArray(bytes32 key) external view returns (uint);
    function getLengthIntArray(bytes32 key) external view returns (uint);
    function getLengthAddressArray(bytes32 key) external view returns (uint);
    function getLengthBoolArray(bytes32 key) external view returns (uint);
    function getLengthBytes32Array(bytes32 key) external view returns (uint);

    function getAddressSet(bytes32 key) external view returns (address[] memory);
    function getUintSet(bytes32 key) external view returns (uint[] memory);
    function getBytes32Set(bytes32 key) external view returns (bytes32[] memory);

    function getIndexedAddressSet(bytes32 key, uint index) external view returns (address);
    function getIndexedUintSet(bytes32 key, uint index) external view returns (uint);
    function getIndexedBytes32Set(bytes32 key, uint index) external view returns (bytes32);

    function getLengthAddressSet(bytes32 key) external view returns (uint);
    function getLengthUintSet(bytes32 key) external view returns (uint);
    function getLengthBytes32Set(bytes32 key) external view returns (uint);
    
    function addressSetContains(bytes32 key, address value) external view returns (bool);
    function uintSetContains(bytes32 key, uint value) external view returns (bool);
    function bytes32SetContains(bytes32 key, bytes32 value) external view returns (bool);

    function addAdmin(address account) external;
    function addLogic(address account) external;
    
    function removeAdmin(address account) external;
    function removeLogic(address account) external;

    function setString(bytes32 key, string memory value) external;
    function setBytes(bytes32 key, bytes memory value) external;
    function setUint(bytes32 key, uint value) external;
    function setInt(bytes32 key, int value) external;
    function setAddress(bytes32 key, address value) external;
    function setBool(bytes32 key, bool value) external;
    function setBytes32(bytes32 key, bytes32 value) external;

    function setStringArray(bytes32 key, uint index, string memory value) external;
    function setBytesArray(bytes32 key, uint index, bytes memory value) external;
    function setUintArray(bytes32 key, uint index, uint value) external;
    function setIntArray(bytes32 key, uint index, int value) external;
    function setAddressArray(bytes32 key, uint index, address value) external;
    function setBoolArray(bytes32 key, uint index, bool value) external;
    function setBytes32Array(bytes32 key, uint index, bytes32 value) external;

    function pushStringArray(bytes32 key, string memory value) external;
    function pushBytesArray(bytes32 key, bytes memory value) external;
    function pushUintArray(bytes32 key, uint value) external;
    function pushIntArray(bytes32 key, int value) external;
    function pushAddressArray(bytes32 key, address value) external;
    function pushBoolArray(bytes32 key, bool value) external;
    function pushBytes32Array(bytes32 key, bytes32 value) external;

    function deleteStringArray(bytes32 key) external;
    function deleteBytesArray(bytes32 key) external;
    function deleteUintArray(bytes32 key) external;
    function deleteIntArray(bytes32 key) external;
    function deleteAddressArray(bytes32 key) external;
    function deleteBoolArray(bytes32 key) external;
    function deleteBytes32Array(bytes32 key) external;
    
    function addAddressSet(bytes32 key, address value) external;
    function addUintSet(bytes32 key, uint value) external;
    function addBytes32Set(bytes32 key, bytes32 value) external;

    function removeAddressSet(bytes32 key, address value) external;
    function removeUintSet(bytes32 key, uint value) external;
    function removeBytes32Set(bytes32 key, bytes32 value) external;
}

interface ISolsticeSafeguardBeta {
    /** anyone */
    function getImplementations() external view returns (address[] memory);

    /** only implementations */
    function getAdmins() external view returns (address[] memory);
    function isAdmin(address account) external view returns (bool);
    function getManagers() external view returns (address[] memory);
    function isManager(address account) external view returns (bool);
    function getTokenContract(uint index) external view returns (address);
    function getTokenAmount(uint index) external view returns (uint);
    function getDenominator() external view returns (address);
    function willRejectAllDeposits() external view returns (bool);
    function getMinimumDeposit() external view returns (uint);
    function getMaximumDeposit() external view returns (uint);
    function getLockUpPeriod() external view returns (uint);
    function getCumulativeSlippageTolerance() external view returns (uint);
    function getManagementFee() external view returns (uint);
    function isWhitelistedAccount(address account) external view returns (bool);
    function isAssetForRedemption(address contract_) external view returns (bool);

    function addAdmin(address admin) external;
    function removeAdmin(address admin) external;
    function addManager(address manager) external;
    function removeManager(address manager) external;
    function setName(string memory newName) external;
    function setDescription(string memory newDescription) external;
    function setBalance(uint newBalance) external;
    function pushTokenContract(address newContract) external;
    function setTokenContract(uint index, address newContract) external;
    function pushTokenAmount(uint newAmount) external;
    function setTokenAmount(uint index, uint newAmount) external;
    function setDenominator(address newDenominator) external;
    function setRejectAllDeposits(bool enabled) external;
    function setMinimumDeposit(uint newMinimumDeposit) external;
    function setMaximumDeposit(uint newMaximumDeposit) external;
    function setLockUpPeriod(uint newLockUpPeriod) external;
    function setCumulativeSlippageTolerance(uint newCumulativeSlippageTolerance) external;
    function setManagementFee(uint newManagementFee) external;
    function addWhitelistedAccount(address account) external;
    function removeWhitelistedAccount(address account) external;
    function addAssetForRedemption(address contract_) external;
    function removeAssetForRedemption(address contract_) external;
    function setTokenName(string memory newTokenName) external;
    function setTokenSymbol(string memory newTokenSymbol) external;
    function setTokenDecimals(uint newTokenDecimals) external;
    function setTokenTotalSupply(uint newTokenTotalSupply) external;
    function setBalance(address account, uint newBalance) external;

    /** only factory */
    function addImplementation(address implementation) external;
    function removeImplementation(address implementation) external;
    function incrementImplementationCount() external returns (uint);
    
    /** owner */
    function setFactory(address factory_) external;
}

/** 
    _addressSet     "solsticeBeta", "implementations"
    _uint           "solsticeBeta", "implementationsCount"

    ** main
    _addressSet     "solsticeBeta", <addr/msg.sender>, "admins"
    _addressSet     "solsticeBeta", <addr/msg.sender>, "managers"
    _string         "solsticeBeta", <addr/msg.sender>, "name"
    _string         "solsticeBeta", <addr/msg.sender>, "description"
    _uint           "solsticeBeta", <addr/msg.sender>, "balance"
    _addressArray   "solsticeBeta", <addr/msg.sender>, "tokensContracts"
    _uintArray      "solsticeBeta", <addr/msg.sender>, "tokensAmounts"
    _address        "solsticeBeta", <addr/msg.sender>, "denominator"

    ** settings
    _bool           "solsticeBeta", <addr/msg.sender>, "rejectAllDeposits"
    _uint           "solsticeBeta", <addr/msg.sender>, "minimumDeposit"
    _uint           "solsticeBeta", <addr/msg.sender>, "maximumDeposit"
    _uint           "solsticeBeta", <addr/msg.sender>, "lockUpPeriod"
    _uint           "solsticeBeta", <addr/msg.sender>, "cumulativeSlippageTolerance"
    _uint           "solsticeBeta", <addr/msg.sender>, "managementFee"
    _addressSet     "solsticeBeta", <addr/msg.sender>, "whitelistedAccounts"
    _addressSet     "solsticeBeta", <addr/msg.sender>, "assetsForRedemption"

    ** token
    _string         "solsticeBeta", <addr/msg.sender>, "nameToken"
    _string         "solsticeBeta", <addr/msg.sender>, "symbolToken"
    _uint           "solsticeBeta", <addr/msg.sender>, "decimalsToken"
    _uint           "solsticeBeta", <addr/msg.sender>, "totalSupplyToken"

    ** accounts
    _uint           "solsticeBeta", <addr/msg.sender>, <addr/account>, "balance"
 */
contract SolsticeSafeguardBeta is ISolsticeSafeguardBeta, Ownable, Pausable {

    address public factory;
    IRepository public repository;
    
    modifier onlyImplementation() {
        _onlyImplementation();
        _;
    }

    modifier onlyFactory() {
        _onlyFactory();
        _;
    }

    constructor() 
    Ownable(msg.sender) {
        repository = IRepository(0xE2578e92fB2Ba228b37eD2dFDb1F4444918b64Aa);
        /** assign factory address */
    }

    function getImplementations()
    public view
    returns (address[] memory) {
        bytes32 implementations = keccak256(abi.encode("solsticeBeta", "implementations"));
        return repository.getAddressSet(implementations);
    }

    function getAdmins()
    public view
    onlyImplementation
    returns (address[] memory) {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        return repository.getAddressSet(admins);
    }

    function isAdmin(address account)
    public view
    onlyImplementation
    returns (bool) {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        return repository.addressSetContains(admins, account);
    }

    function getManagers()
    public view
    onlyImplementation
    returns (address[] memory) {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        return repository.getAddressSet(managers);
    }

    function isManager(address account)
    public view
    onlyImplementation
    returns (bool) {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        return repository.addressSetContains(managers, account);
    }

    function getTokenContract(uint index)
    public view
    onlyImplementation
    returns (address) {
        bytes32 tokensContracts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensContracts"));
        return repository.getIndexedAddressArray(tokensContracts, index);
    }

    function getTokenAmount(uint index)
    public view
    onlyImplementation
    returns (uint) {
        bytes32 tokensAmounts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensAmounts"));
        return repository.getIndexedUintArray(tokensAmounts, index);
    }

    function getDenominator()
    public view
    onlyImplementation
    returns (address) {
        bytes32 denominator = keccak256(abi.encode("solsticeBeta", msg.sender, "denominator"));
        return repository.getAddress(denominator);
    }

    function willRejectAllDeposits()
    public view
    onlyImplementation 
    returns (bool) {
        bytes32 rejectAllDeposits = keccak256(abi.encode("solsticeBeta", msg.sender, "rejectAllDeposits"));
        return repository.getBool(rejectAllDeposits);
    }

    function getMinimumDeposit()
    public view
    onlyImplementation
    returns (uint) {
        bytes32 minimumDeposit = keccak256(abi.encode("solsticeBeta", msg.sender, "minimumDeposit"));
        return repository.getUint(minimumDeposit);
    }

    function getMaximumDeposit()
    public view
    onlyImplementation
    returns (uint) {
        bytes32 maximumDeposit = keccak256(abi.encode("solsticeBeta", msg.sender, "maximumDeposit"));
        return repository.getUint(maximumDeposit);
    }

    function getLockUpPeriod()
    public view
    onlyImplementation 
    returns (uint) {
        bytes32 lockUpPeriod = keccak256(abi.encode("solsticeBeta", msg.sender, "lockUpPeriod"));
        return repository.getUint(lockUpPeriod);
    }

    function getCumulativeSlippageTolerance()
    public view
    onlyImplementation 
    returns (uint) {
        bytes32 cumulativeSlippageTolerance = keccak256(abi.encode("solsticeBeta", msg.sender, "cumulativeSlippageTolerance"));
        return repository.getUint(cumulativeSlippageTolerance);
    }

    function getManagementFee()
    public view
    onlyImplementation
    returns (uint) {
        bytes32 managementFee = keccak256(abi.encode("solsticeBeta", msg.sender, "managementFee"));
        return repository.getUint(managementFee);
    }

    function isWhitelistedAccount(address account)
    public view
    onlyImplementation 
    returns (bool) {
        bytes32 whitelistedAccounts = keccak256(abi.encode("solsticeBeta", msg.sender, "whitelistedAccounts"));
        return repository.addressSetContains(whitelistedAccounts, account);
    }

    function isAssetForRedemption(address contract_)
    public view
    onlyImplementation
    returns (bool) {
        bytes32 assetsForRedemption = keccak256(abi.encode("solsticeBeta", msg.sender, "assetsForRedemption"));
        return repository.addressSetContains(assetsForRedemption, contract_);
    }

    function addImplementation(address implementation)
    public 
    onlyFactory {
        bytes32 implementations = keccak256(abi.encode("solsticeBeta", "implementations"));
        require(
            !repository.addressSetContains(implementations, implementation),
            "SolsticeSafeguardBeta: cannot add implementation because implementation has already been added"
        );
        repository.addAddressSet(implementations, implementation);
    }

    function removeImplementation(address implementation)
    public 
    onlyFactory {
        bytes32 implementations = keccak256(abi.encode("solsticeBeta", "implementations"));
        require(
            repository.addressSetContains(implementations, implementation),
            "SolsticeSafeguardBeta: cannot remove implementation because implementation does not exist"
        );
        repository.removeAddressSet(implementations, implementation);
    }

    function incrementImplementationCount()
    public
    onlyFactory 
    returns (uint) {
        bytes32 implementationsCount = keccak256(abi.encode("solsticeBeta", "implementationsCount"));
        uint count = repository.getUint(implementationsCount);
        repository.setUint(implementationsCount, count + 1);
        return count++;
    }

    function setFactory(address factory_)
    public
    onlyOwner {
        factory = factory_;
    }

    function addAdmin(address admin)
    public
    onlyImplementation {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        require(
            !repository.addressSetContains(admins, admin),
            "SolsticeSafeguardBeta: cannot add admin because admin has already been added"
        );
        repository.addAddressSet(admins, admin);
    }

    function removeAdmin(address admin)
    public
    onlyImplementation {
        bytes32 admins = keccak256(abi.encode("solsticeBeta", msg.sender, "admins"));
        require(
            repository.addressSetContains(admins, admin),
            "SolsticeSafeguardBeta: cannot remove admin because admin does not exist"
        );
        repository.removeAddressSet(admins, admin);
    }

    function addManager(address manager)
    public
    onlyImplementation {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        require(
            !repository.addressSetContains(managers, manager),
            "SolsticeSafeguardBeta: cannot add manager because manager has already been added"
        );
        repository.addAddressSet(managers, manager);
    }

    function removeManager(address manager)
    public
    onlyImplementation {
        bytes32 managers = keccak256(abi.encode("solsticeBeta", msg.sender, "managers"));
        require(
            repository.addressSetContains(managers, manager),
            "SolsticeSafeguardBeta: cannot remove manager because manager does not exist"
        );
        repository.removeAddressSet(managers, manager);
    }

    function setName(string memory newName)
    public
    onlyImplementation {
        bytes32 name = keccak256(abi.encode("solsticeBeta", msg.sender, "name"));
        repository.setString(name, newName);
    }

    function setDescription(string memory newDescription)
    public
    onlyImplementation {
        bytes32 description = keccak256(abi.encode("solsticeBeta", msg.sender, "description"));
        repository.setString(description, newDescription);
    }

    function setBalance(uint newBalance)
    public
    onlyImplementation {
        bytes32 balance = keccak256(abi.encode("solsticeBeta", msg.sender, "balance"));
        repository.setUint(balance, newBalance);
    }

    function pushTokenContract(address newContract)
    public
    onlyImplementation {
        bytes32 tokensContracts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensContracts"));
        repository.pushAddressArray(tokensContracts, newContract);
    }

    function setTokenContract(uint index, address newContract)
    public
    onlyImplementation {
        bytes32 tokensContracts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensContracts"));
        repository.setAddressArray(tokensContracts, index, newContract);
    }

    function pushTokenAmount(uint newAmount)
    public
    onlyImplementation {
        bytes32 tokensAmounts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensAmounts"));
        repository.pushUintArray(tokensAmounts, newAmount);
    }

    function setTokenAmount(uint index, uint newAmount)
    public
    onlyImplementation {
        bytes32 tokensAmounts = keccak256(abi.encode("solsticeBeta", msg.sender, "tokensAmounts"));
        repository.setUintArray(tokensAmounts, index, newAmount);
    }

    function setDenominator(address newDenominator)
    public
    onlyImplementation {
        bytes32 denominator = keccak256(abi.encode("solsticeBeta", msg.sender, "denominator"));
        repository.setAddress(denominator, newDenominator);
    }

    function setRejectAllDeposits(bool enabled)
    public
    onlyImplementation {
        bytes32 rejectAllDeposits = keccak256(abi.encode("solsticeBeta", msg.sender, "rejectAllDeposits"));
        repository.setBool(rejectAllDeposits, enabled);
    }

    function setMinimumDeposit(uint newMinimumDeposit)
    public
    onlyImplementation {
        bytes32 minimumDeposit = keccak256(abi.encode("solsticeBeta", msg.sender, "minimumDeposit"));
        repository.setUint(minimumDeposit, newMinimumDeposit);
    }

    function setMaximumDeposit(uint newMaximumDeposit)
    public
    onlyImplementation {
        bytes32 maximumDeposit = keccak256(abi.encode("solsticeBeta", msg.sender, "maximumDeposit"));
        repository.setUint(maximumDeposit, newMaximumDeposit);
    }

    function setLockUpPeriod(uint newLockUpPeriod)
    public
    onlyImplementation {
        bytes32 lockUpPeriod = keccak256(abi.encode("solsticeBeta", msg.sender, "lockUpPeriod"));
        repository.setUint(lockUpPeriod, newLockUpPeriod);
    }

    function setCumulativeSlippageTolerance(uint newCumulativeSlippageTolerance)
    public
    onlyImplementation {
        bytes32 cumulativeSlippageTolerance = keccak256(abi.encode("solsticeBeta", msg.sender, "cumulativeSlippageTolerance"));
        repository.setUint(cumulativeSlippageTolerance, newCumulativeSlippageTolerance);
    }

    function setManagementFee(uint newManagementFee)
    public
    onlyImplementation {
        bytes32 managementFee = keccak256(abi.encode("solsticeBeta", msg.sender, "managementFee"));
        repository.setUint(managementFee, newManagementFee);
    }

    function addWhitelistedAccount(address account)
    public
    onlyImplementation {
        bytes32 whitelistedAccounts = keccak256(abi.encode("solsticeBeta", msg.sender, "whitelistedAccounts"));
        repository.addAddressSet(whitelistedAccounts, account);
    }

    function removeWhitelistedAccount(address account)
    public
    onlyImplementation {
        bytes32 whitelistedAccounts = keccak256(abi.encode("solsticeBeta", msg.sender, "whitelistedAccounts"));
        repository.removeAddressSet(whitelistedAccounts, account);
    }

    function addAssetForRedemption(address contract_)
    public
    onlyImplementation {
        bytes32 assetsForRedemption = keccak256(abi.encode("solsticeBeta", msg.sender, "assetsForRedemption"));
        repository.addAddressSet(assetsForRedemption, contract_);
    }

    function removeAssetForRedemption(address contract_)
    public
    onlyImplementation {
        bytes32 assetsForRedemption = keccak256(abi.encode("solsticeBeta", msg.sender, "assetsForRedemption"));
        repository.removeAddressSet(assetsForRedemption, contract_);
    }

    function setTokenName(string memory newTokenName)
    public
    onlyImplementation {
        bytes32 nameToken = keccak256(abi.encode("solsticeBeta", msg.sender, "nameToken"));
        repository.setString(nameToken, newTokenName);
    }

    function setTokenSymbol(string memory newTokenSymbol)
    public
    onlyImplementation {
        bytes32 symbolToken = keccak256(abi.encode("solsticeBeta", msg.sender, "symbolToken"));
        repository.setString(symbolToken, newTokenSymbol);
    }

    function setTokenDecimals(uint newTokenDecimals)
    public
    onlyImplementation {
        bytes32 decimalsToken = keccak256(abi.encode("solsticeBeta", msg.sender, "decimalsToken"));
        repository.setUint(decimalsToken, newTokenDecimals);
    }

    function setTokenTotalSupply(uint newTokenTotalSupply)
    public
    onlyImplementation {
        bytes32 totalSupplyToken = keccak256(abi.encode("solsticeBeta", msg.sender, "totalSupplyToken"));
        repository.setUint(totalSupplyToken, newTokenTotalSupply);
    }

    function setBalance(address account, uint newBalance)
    public
    onlyImplementation {
        bytes32 balance = keccak256(abi.encode("solsticeBeta", msg.sender, account, "balance"));
        repository.setUint(balance, newBalance);
    }

    function _onlyImplementation()
    private view {
        bytes32 implementations = keccak256(abi.encode("solsticeBeta", "implementations"));
        require(
            repository.addressSetContains(implementations, msg.sender),
            "SolsticeSafeguardBeta: caller is not an implementation"
        );
    }

    function _onlyFactory()
    private view {
        require(msg.sender == factory, "SolsticeSafeguardBeta: caller is not factory");
    }
}