// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.19;

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

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IQuickSwapOracle {
    function metadata(
        address tokenA, 
        address tokenB
    ) 
    external view 
    returns (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint,
        uint
    );
    function price(
        address tokenA, 
        address tokenB, 
        uint amount
    ) 
    external view 
    returns (
        uint, 
        uint, 
        uint
    );
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address to
    )
    external;
    function grantRoleVault(
        address account
    )
    external;
    function revokeRoleVault(
        address account
    )
    external;
}

contract QuickSwapOracle is IQuickSwapOracle, Ownable, Pausable {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum Gate {
        WMATIC,
        WBTC,
        WETH,
        USDC,
        USDT,
        DAI
    }

    enum Order {
        UNRECOGNIZED,
        REVERSE,
        SAME
    }

    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

    IUniswapV2Factory constant FACTORY = IUniswapV2Factory(0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32);
    IUniswapV2Router02 constant ROUTER = IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    EnumerableSet.AddressSet vaults;

    modifier onlyVault() {
        //_onlyVault();
        _;
    }

    event SWAP(
        address indexed tokenIn,
        address indexed tokenOut,
        uint indexed amountIn,
        uint amountOutMin,
        address to
    );

    error PAIR_NOT_FOUND();
    error UNAUTHORIZED();
    error INVALID_GATE();
    error FAILED_TO_APPROVE();

    constructor()
    Ownable(msg.sender) {}

    function metadata(
        address tokenA,
        address tokenB
    )
    public view
    returns (
        address,
        address,
        address,
        string memory,
        string memory,
        string memory,
        string memory,
        uint,
        uint
    ) {
        address addrPair = FACTORY.getPair(tokenA, tokenB);
        if (addrPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addrPair);
        IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());
        return (
            addrPair,
            interface_.token0(),
            interface_.token1(),
            tokenA_.name(),
            tokenB_.name(),
            tokenA_.symbol(),
            tokenB_.symbol(),
            tokenA_.decimals(),
            tokenB_.decimals()
        );
    }

    function price(
        address tokenA,
        address tokenB,
        uint amount
    )
    public view
    returns (
        uint,
        uint,
        uint
    ) {
        Order order = _isSameOrder(tokenA, tokenB);
        if (order == Order.SAME) {
            (uint cost, uint divisor, uint lastTimestamp) = _priceOfTokenBInTokenA(tokenA, tokenB, amount);
            return (cost, divisor, lastTimestamp);
        }
        else if (order == Order.REVERSE) {
            (uint cost, uint divisor, uint lastTimestamp) = _priceOfTokenAInTokenB(tokenA, tokenB, amount);
            return (cost, divisor, lastTimestamp);
        }
        else { revert PAIR_NOT_FOUND(); }
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint slippage,
        uint gate,
        address to
    )
    public
    onlyVault
    whenNotPaused {
        if (gate > 5) { revert INVALID_GATE(); }
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(ROUTER), amountIn);
        (uint amountOutMin, ,) = price(tokenIn, tokenOut, amountIn);
        amountOutMin = (amountOutMin * (10000 - slippage)) / 10000;
        address[] memory path;
        path = new address[](3);
        path[0] = tokenIn;
        if (Gate(gate) == Gate.WMATIC) { path[1] = WMATIC; }
        else if (Gate(gate) == Gate.WBTC) { path[1] = WBTC; }
        else if (Gate(gate) == Gate.WETH) { path[1] = WETH; }
        else if (Gate(gate) == Gate.USDC) { path[1] = USDC; }
        else if (Gate(gate) == Gate.USDT) { path[1] = USDT; }
        else if (Gate(gate) == Gate.DAI) { path[1] = DAI; }
        path[2] = tokenOut;
        ROUTER.swapExactTokensForTokens(amountIn, amountOutMin, path, to, block.timestamp);
        emit SWAP(tokenIn, tokenOut, amountIn, amountOutMin, to);
    }

    function grantRoleVault(address account)
    public 
    onlyOwner {
        vaults.add(account);
    }

    function revokeRoleVault(address account)
    public 
    onlyOwner {
        vaults.remove(account);
    }

    function _isSameString(
        string memory stringA,
        string memory stringB
    )
    private pure
    returns (
        bool
    ) {
        return keccak256(abi.encode(stringA)) == keccak256(abi.encode(stringB));
    }

    function _priceOfTokenBInTokenA(
        address tokenA,
        address tokenB,
        uint amount
    )
    private view
    returns (
        uint,
        uint,
        uint
    ) {
        address addrPair = FACTORY.getPair(tokenA, tokenB);
        if (addrPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addrPair);
        IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());
        (
            uint reserveA,
            uint reserveB,
            uint lastTimestamp
        ) = interface_.getReserves();
        return (
            (amount * (reserveA * (10**tokenB_.decimals()))) / reserveB,
            10**tokenA_.decimals(),
            lastTimestamp
        );
    }

    function _priceOfTokenAInTokenB(
        address tokenA,
        address tokenB,
        uint amount
    )
    private view
    returns (
        uint,
        uint,
        uint
    ) {
        address addrPair = FACTORY.getPair(tokenA, tokenB);
        if (addrPair == address(0)) { revert PAIR_NOT_FOUND(); }
        IUniswapV2Pair interface_ = IUniswapV2Pair(addrPair);
        IERC20Metadata tokenA_ = IERC20Metadata(interface_.token0());
        IERC20Metadata tokenB_ = IERC20Metadata(interface_.token1());
        (
            uint reserveA,
            uint reserveB,
            uint lastTimestamp
        ) = interface_.getReserves();
        return (
            (amount * (reserveB * (10**tokenA_.decimals()))) / reserveA,
            10**tokenB_.decimals(),
            lastTimestamp
        );
    }

    function _isSameOrder(
        address tokenA,
        address tokenB
    )
    private view
    returns (
        Order
    ) {
        (
            ,
            address addressA,
            address addressB,
            string memory nameA,
            string memory nameB,
            string memory symbolA,
            string memory symbolB,
            uint decimalsA,
            uint decimalsB 
        ) = metadata(tokenA, tokenB);
        IERC20Metadata tokenA_ = IERC20Metadata(tokenA);
        IERC20Metadata tokenB_ = IERC20Metadata(tokenB);
        if (
            tokenA == addressA
            && tokenB == addressB
            && _isSameString(tokenA_.name(), nameA)
            && _isSameString(tokenB_.name(), nameB)
            && _isSameString(tokenA_.symbol(), symbolA)
            && _isSameString(tokenB_.symbol(), symbolB)
            && tokenA_.decimals() == decimalsA
            && tokenB_.decimals() == decimalsB
        ) {
            return Order.SAME;
        }
        else if (
            tokenA == addressB
            && tokenB == addressA
            && _isSameString(tokenA_.name(), nameB)
            && _isSameString(tokenB_.name(), nameA)
            && _isSameString(tokenA_.symbol(), symbolB)
            && _isSameString(tokenB_.symbol(), symbolA)
            && tokenA_.decimals() == decimalsB
            && tokenB_.decimals() == decimalsA
        ) {
            return Order.REVERSE;
        }
        else {
            return Order.UNRECOGNIZED;
        }
    }

    function _onlyVault()
    private view {
        if (!vaults.contains(msg.sender)) { revert UNAUTHORIZED(); }
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

/**

contract Solstice {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Fee {
        uint streaming;
        uint in_;
        uint out;
    }

    struct Deposit {
        uint min;
        uint max;
        bool enabled;
    }

    struct Withdrawal {
        uint min;
        uint max;
        bool enabled;
    }

    struct Role {
        EnumerableSet
            .AddressSet
                admins;
        EnumerableSet
            .AddressSet
                managers;
    }

    struct Time {
        uint launch;
    }

    struct Reserve {
        IERC20Metadata denominator;
        EnumerableSet
            .AddressSet
                contracts;
        EnumerableSet
            .AddressSet
                authorizedIn;
        EnumerableSet
            .AddressSet
                authorizedOut;
    }

    struct Recipient {
        EnumerableSet
            .AddressSet
                streaming;
        EnumerableSet
            .AddressSet
                in_;
        EnumerableSet
            .AddressSet
                out;
    }

    struct Metadata {
        string name;
        string description;
    }

    struct Vault {
        uint index;
        Fee fee;
        Deposit deposit;
        Withdrawal withdrawal;
        Role role;
        Time time;
        Reserve reserve;
        Recipient recipient;
        Metadata metadata;
    }

    IOracle oracle;
    Vault vault;

    error UNAUTHORIZED_TOKEN_IN();
    error UNAUTHORIZED_TOKEN_OUT();
    error PAIR_NOT_FOUND();
    error INSUFFICIENT_MATH();

    function _amountToMint(
        uint value,
        uint supply,
        uint balance
    )
    internal pure
    returns (uint) {
        if (value == 0) { revert INSUFFICIENT_MATH(); }
        if (supply == 0) { revert INSUFFICIENT_MATH(); }
        if (balance == 0) { revert INSUFFICIENT_MATH(); }
        return ((value * balance) / supply);
    }

    function _amountToSend(
        uint amount,
        uint supply,
        uint balance
    )
    internal pure
    returns (uint) {
        if (amount == 0) { revert INSUFFICIENT_MATH(); }
        if (supply == 0) { revert INSUFFICIENT_MATH(); }
        if (balance == 0) { revert INSUFFICIENT_MATH(); }
        return ((amount * balance) / supply);
    }
}

*/