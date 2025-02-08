// File: @openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol


// OpenZeppelin Contracts (last updated v4.8.1) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// File: @openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol


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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
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
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (metatx/ERC2771Context.sol)

pragma solidity ^0.8.9;


/**
 * @dev Context variant with ERC2771 support.
 */
abstract contract ERC2771ContextUpgradeable is Initializable, ContextUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address private immutable _trustedForwarder;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// File: contracts/interfaces/otcWrapperInterfaces/UtilsWrapperInterface.sol


pragma solidity 0.8.10;

interface UtilsWrapperInterface {
    struct Vault {
        // addresses of oTokens a user has shorted (i.e. written) against this vault
        address[] shortOtokens;
        // addresses of oTokens a user has bought and deposited in this vault
        // user can be long oTokens without opening a vault (e.g. by buying on a DEX)
        // generally, long oTokens will be 'deposited' in vaults to act as collateral in order to write oTokens against (i.e. in spreads)
        address[] longOtokens;
        // addresses of other ERC-20s a user has deposited as collateral in this vault
        address[] collateralAssets;
        // quantity of oTokens minted/written for each oToken address in shortOtokens
        uint256[] shortAmounts;
        // quantity of oTokens owned and held in the vault for each oToken address in longOtokens
        uint256[] longAmounts;
        // quantity of ERC-20 deposited as collateral in the vault for each ERC-20 address in collateralAssets
        uint256[] collateralAmounts;
    }

    // possible actions that can be performed
    enum ActionType {
        OpenVault,
        MintShortOption,
        BurnShortOption,
        DepositLongOption,
        WithdrawLongOption,
        DepositCollateral,
        WithdrawCollateral,
        SettleVault,
        Redeem,
        Call,
        Liquidate
    }

    struct ActionArgs {
        // type of action that is being performed on the system
        ActionType actionType;
        // address of the account owner
        address owner;
        // address which we move assets from or to (depending on the action type)
        address secondAddress;
        // asset that is to be transfered
        address asset;
        // index of the vault that is to be modified (if any)
        uint256 vaultId;
        // amount of asset that is to be transfered
        uint256 amount;
        // each vault can hold multiple short / long / collateral assets but we are restricting the scope to only 1 of each in this version
        // in future versions this would be the index of the short / long / collateral asset that needs to be modified
        uint256 index;
        // any other data that needs to be passed in for arbitrary function calls
        bytes data;
    }
}

// File: contracts/interfaces/otcWrapperInterfaces/MarginRequirementsWrapperInterface.sol


pragma solidity 0.8.10;

interface MarginRequirementsWrapperInterface {
    function checkWithdrawCollateral(
        address _account,
        uint256 _notional,
        uint256 _withdrawAmount,
        address _otokenAddress,
        uint256 _vaultID,
        UtilsWrapperInterface.Vault memory _vault
    ) external view returns (bool);

    function checkMintCollateral(
        address _account,
        uint256 _notional,
        address _underlyingAsset,
        bool isPut,
        uint256 _collateralAmount,
        address _collateralAsset
    ) external view returns (bool);
}

// File: contracts/interfaces/otcWrapperInterfaces/ControllerWrapperInterface.sol


pragma solidity 0.8.10;

interface ControllerWrapperInterface {
    /* Getters */
    function getAccountVaultCounter(address _accountOwner) external view returns (uint256);

    function getVaultWithDetails(address _owner, uint256 _vaultId)
        external
        view
        returns (
            UtilsWrapperInterface.Vault memory,
            uint256,
            uint256
        );

    /* Admin-only functions */
    function operate(UtilsWrapperInterface.ActionArgs[] memory _actions) external;
}

// File: contracts/interfaces/otcWrapperInterfaces/AddressBookWrapperInterface.sol


pragma solidity 0.8.10;

interface AddressBookWrapperInterface {
    /* Getters */

    function getOtokenImpl() external view returns (address);

    function getOtokenFactory() external view returns (address);

    function getWhitelist() external view returns (address);

    function getController() external view returns (address);

    function getOracle() external view returns (address);

    function getMarginPool() external view returns (address);

    function getMarginCalculator() external view returns (address);

    function getMarginRequirements() external view returns (address);

    function getLiquidationManager() external view returns (address);

    function getKeeper() external view returns (address);

    function getOTCWrapper() external view returns (address);

    function getAddress(bytes32 _id) external view returns (address);

    /* Setters */

    function setOtokenImpl(address _otokenImpl) external;

    function setOtokenFactory(address _factory) external;

    function setOracleImpl(address _otokenImpl) external;

    function setWhitelist(address _whitelist) external;

    function setController(address _controller) external;

    function setMarginPool(address _marginPool) external;

    function setMarginCalculator(address _calculator) external;

    function setLiquidationManager(address _liquidationManager) external;

    function setAddress(bytes32 _id, address _newImpl) external;
}

// File: contracts/interfaces/otcWrapperInterfaces/WhitelistWrapperInterface.sol


pragma solidity 0.8.10;

interface WhitelistWrapperInterface {
    /* View functions */

    function addressBook() external view returns (address);

    function isWhitelistedProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external view returns (bool);

    function isWhitelistedCollateral(address _collateral) external view returns (bool);

    function isCoveredWhitelistedCollateral(
        address _collateral,
        address _underlying,
        bool _isPut
    ) external view returns (bool);

    function isNakedWhitelistedCollateral(
        address _collateral,
        address _underlying,
        bool _isPut
    ) external view returns (bool);

    function isWhitelistedOtoken(address _otoken) external view returns (bool);

    function isWhitelistedCallee(address _callee) external view returns (bool);

    /* Admin / factory only functions */
    function whitelistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external;

    function blacklistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external;

    function whitelistCollateral(address _collateral) external;

    function blacklistCollateral(address _collateral) external;

    function whitelistCoveredCollateral(
        address _collateral,
        address _underlying,
        bool _isPut
    ) external;

    function whitelistNakedCollateral(
        address _collateral,
        address _underlying,
        bool _isPut
    ) external;

    function whitelistOtoken(address _otoken) external;

    function blacklistOtoken(address _otoken) external;

    function whitelistCallee(address _callee) external;

    function blacklistCallee(address _callee) external;
}

// File: contracts/interfaces/otcWrapperInterfaces/OracleWrapperInterface.sol


pragma solidity 0.8.10;

interface OracleWrapperInterface {
    function isLockingPeriodOver(address _asset, uint256 _expiryTimestamp) external view returns (bool);

    function isDisputePeriodOver(address _asset, uint256 _expiryTimestamp) external view returns (bool);

    function getExpiryPrice(address _asset, uint256 _expiryTimestamp) external view returns (uint256, bool);

    function getDisputer() external view returns (address);

    function getPricer(address _asset) external view returns (address);

    function getPrice(address _asset) external view returns (uint256);

    function getPricerLockingPeriod(address _pricer) external view returns (uint256);

    function getPricerDisputePeriod(address _pricer) external view returns (uint256);

    function getChainlinkRoundData(address _asset, uint80 _roundId) external view returns (uint256, uint256);

    // Non-view function

    function setAssetPricer(address _asset, address _pricer) external;

    function setLockingPeriod(address _pricer, uint256 _lockingPeriod) external;

    function setDisputePeriod(address _pricer, uint256 _disputePeriod) external;

    function setExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;

    function disputeExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;

    function setDisputer(address _disputer) external;
}

// File: contracts/interfaces/otcWrapperInterfaces/IOtokenFactoryWrapperInterface.sol


pragma solidity 0.8.10;

interface IOtokenFactoryWrapperInterface {
    function createOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external returns (address);

    function getOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address);
}

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin/contracts/utils/cryptography/ECDSA.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// File: @openzeppelin/contracts/utils/cryptography/EIP712.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/EIP712.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// File: @openzeppelin/contracts/metatx/MinimalForwarder.sol


// OpenZeppelin Contracts (last updated v4.8.0) (metatx/MinimalForwarder.sol)

pragma solidity ^0.8.0;


/**
 * @dev Simple minimal forwarder to be used together with an ERC2771 compatible contract. See {ERC2771Context}.
 *
 * MinimalForwarder is mainly meant for testing, as it is missing features to be a good production-ready forwarder. This
 * contract does not intend to have all the properties that are needed for a sound forwarding system. A fully
 * functioning forwarding system with good properties requires more complexity. We suggest you look at other projects
 * such as the GSN which do have the goal of building a system like that.
 */
contract MinimalForwarder is EIP712 {
    using ECDSA for bytes32;

    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    bytes32 private constant _TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");

    mapping(address => uint256) private _nonces;

    constructor() EIP712("MinimalForwarder", "0.0.1") {}

    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        address signer = _hashTypedDataV4(
            keccak256(abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data)))
        ).recover(signature);
        return _nonces[req.from] == req.nonce && signer == req.from;
    }

    function execute(ForwardRequest calldata req, bytes calldata signature)
        public
        payable
        returns (bool, bytes memory)
    {
        require(verify(req, signature), "MinimalForwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;

        (bool success, bytes memory returndata) = req.to.call{gas: req.gas, value: req.value}(
            abi.encodePacked(req.data, req.from)
        );

        // Validate that the relayer has sent enough gas for the call.
        // See https://ronan.eth.limo/blog/ethereum-gas-dangers/
        if (gasleft() <= req.gas / 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            /// @solidity memory-safe-assembly
            assembly {
                invalid()
            }
        }

        return (success, returndata);
    }
}

// File: contracts/libs/SupportsNonCompliantERC20.sol


pragma solidity 0.8.10;


/**
 * This library supports ERC20s that have quirks in their behavior.
 * One such ERC20 is USDT, which requires allowance to be 0 before calling approve.
 * We plan to update this library with ERC20s that display such idiosyncratic behavior.
 */
library SupportsNonCompliantERC20 {
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // ETH Mainnet

    function safeApproveNonCompliant(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {
        if (address(token) == USDT) {
            SafeERC20.safeApprove(token, spender, 0);
        }
        SafeERC20.safeApprove(token, spender, amount);
    }
}

// File: contracts/interfaces/otcWrapperInterfaces/MarginCalculatorWrapperInterface.sol


pragma solidity 0.8.10;

interface MarginCalculatorWrapperInterface {
    function getExcessCollateral(UtilsWrapperInterface.Vault calldata _vault, uint256 _vaultType)
        external
        view
        returns (uint256 netValue, bool isExcess);
}

// File: contracts/interfaces/otcWrapperInterfaces/UnwindPermitInterface.sol

pragma solidity 0.8.10;

interface UnwindPermitInterface {
    function checkOrderPermit(
        address owner,
        uint256 orderID,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts/core/OTCWrapperV2.sol

/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity 0.8.10;



















/**
 * @title OTC Wrapper
 * @author Ribbon Team
 * @notice Contract that overlays Gamma Protocol for the OTC related interactions
 */
contract OTCWrapperV2 is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC2771ContextUpgradeable {
    using SafeERC20 for IERC20;
    using SupportsNonCompliantERC20 for IERC20;

    AddressBookWrapperInterface public addressbook;
    MarginRequirementsWrapperInterface public marginRequirements;
    ControllerWrapperInterface public controller;
    OracleWrapperInterface public oracle;
    WhitelistWrapperInterface public whitelist;
    IOtokenFactoryWrapperInterface public OTokenFactory;
    MarginCalculatorWrapperInterface public calculator;

    /************************************************
     *  EVENTS
     ***********************************************/

    /// @notice emits an event when an order is placed
    event OrderPlaced(
        uint256 indexed orderID,
        address indexed underlyingAsset,
        bool isPut,
        uint256 strikePrice,
        uint256 expiry,
        uint256 premium,
        address indexed buyer,
        uint256 size,
        uint256 notional
    );

    /// @notice emits an event when an order is canceled
    event OrderCancelled(uint256 orderID);

    /// @notice emits an event when an order is executed
    event OrderExecuted(
        uint256 indexed orderID,
        address collateralAsset,
        uint256 premium,
        address indexed seller,
        uint256 indexed vaultID,
        address oToken,
        uint256 initialMargin
    );

    /// @notice emits an event when collateral is deposited
    event CollateralDeposited(uint256 indexed orderID, uint256 amount, address indexed acct);

    /// @notice emits an event when collateral is withdrawn
    event CollateralWithdrawn(uint256 indexed orderID, uint256 amount, address indexed acct);

    /// @notice emits an event when a vault is settled
    event VaultSettled(uint256 indexed orderID);

    /// @notice emits an event when redeem occurs
    event Reedem(uint256 indexed orderID, uint256 size);

    /// @notice emits an event when there is an order unwind
    event RedeemRightsSold(uint256 indexed orderID, address seller, address bidder, uint256 bidValue);

    /// @notice emits an event when fees are claimed
    event FeesClaimed(uint256 amountClaimed, address asset);

    /************************************************
     *  STORAGE
     ***********************************************/

    ///@notice order counter
    uint256 public latestOrder;

    ///@notice fill deadline duration in seconds
    uint256 public fillDeadline;

    ///@notice address that will receive the product fees
    address public beneficiary;

    /// @notice USDC 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    address public immutable USDC;

    // order status
    enum OrderStatus {
        Failed,
        Pending,
        Succeeded
    }

    // struct defining order details
    struct Order {
        // underlying asset address (with its respective token decimals)
        address underlying;
        // collateral asset address (with its respective token decimals)
        address collateral;
        // option type the vault is selling
        bool isPut;
        // option strike price
        uint256 strikePrice;
        // option expiry timestamp
        uint256 expiry;
        // order premium amount in USDC (with USDC decimals)
        uint256 premium;
        // order notional in USD (with 6 decimals)
        uint256 notional;
        // buyer address
        address buyer;
        // seller address
        address seller;
        // id of the vault
        uint256 vaultID;
        // otoken address (with 8 decimals)
        address oToken;
        // timestamp of when the order was opened
        uint256 openedAt;
        // order size (with 8 decimals)
        uint256 size;
    }

    // struct defining permit signature details
    struct Permit {
        // permit amount (with its respective token decimals)
        uint256 amount;
        // permit deadline
        uint256 deadline;
        // permit account
        address acct;
        // v component of permit signature
        uint8 v;
        // r component of permit signature
        bytes32 r;
        // s component of permit signature
        bytes32 s;
    }

    // struct defining the upper and lower boundaries of USD notional for an asset
    struct MinMaxNotional {
        // minimum USD notional value allowed (with 6 decimals)
        uint256 min;
        // maximum USD notional value allowed (with 6 decimals)
        uint256 max;
    }

    ///@dev mapping between an asset address to a struct consisting of uint256 min and a uint256 max which will be its notional floor and cap allowed
    mapping(address => MinMaxNotional) public minMaxNotional;

    ///@notice mapping between order id and order details
    mapping(uint256 => Order) public orders;

    ///@notice mapping between order id and order status
    mapping(uint256 => OrderStatus) public orderStatus;

    ///@notice mapping between a Market Maker address and its whitelist status
    mapping(address => bool) public isWhitelistedMarketMaker;

    ///@notice mapping between an asset address and its corresponding fee
    mapping(address => uint256) public fee;

    ///@notice mapping between acct and list of all successful orders
    mapping(address => uint256[]) public ordersByAcct;

    ///@notice mapping between asset and their allowed maximum price deviation between place order and execute time (percentage with 2 decimals)
    mapping(address => uint256) public maxDeviation;

    ///@notice mapping between an asset address and its corresponding unwind fee
    mapping(address => uint256) public unwindFee;

    ///@notice buffer time between last allowed unwind moment and expiry
    uint256 public unwindBufferDuration;

    ///@notice value that represents 100% for fees
    uint256 public immutable FEE_PERCENT_MULTIPLIER;

    /// @notice Unwind Permit interface
    UnwindPermitInterface public immutable UNWIND_PERMIT;

    // struct defining unwind permit signature details
    struct UnwindPermit {
        // permit account
        address acct;
        // permit order id
        uint256 orderID;
        // permit bid value (with its USDC token decimals)
        uint256 bidValue;
        // permit deadline
        uint256 deadline;
        // v component of permit signature
        uint8 v;
        // r component of permit signature
        bytes32 r;
        // s component of permit signature
        bytes32 s;
    }

    /************************************************
     *  CONSTRUCTOR & INITIALIZATION
     ***********************************************/

    /**
     * @notice constructor related to ERC2771
     * @param _trustedForwarder trusted forwarder address
     * @param _usdc USDC address
     * @param _unwindPermit unwind permit address
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        MinimalForwarder _trustedForwarder,
        address _usdc,
        address _unwindPermit
    ) ERC2771ContextUpgradeable(address(_trustedForwarder)) {
        require(_usdc != address(0), "OTCWrapper: usdc address cannot be 0");
        require(_unwindPermit != address(0), "OTCWrapper: unwind permit address cannot be 0");

        USDC = _usdc;
        UNWIND_PERMIT = UnwindPermitInterface(_unwindPermit);
        FEE_PERCENT_MULTIPLIER = 1e6;
    }

    /**
     * @notice initialize the deployed contract
     * @param _beneficiary beneficiary address
     * @param _addressBook AddressBook address
     * @param _fillDeadline fill deadline duration in seconds
     */
    function initialize(
        address _addressBook,
        address _beneficiary,
        uint256 _fillDeadline
    ) external initializer {
        require(_addressBook != address(0), "OTCWrapper: addressbook address cannot be 0");
        require(_beneficiary != address(0), "OTCWrapper: beneficiary address cannot be 0");
        require(_fillDeadline > 0, "OTCWrapper: fill deadline cannot be 0");

        __Ownable_init();
        __ReentrancyGuard_init();

        addressbook = AddressBookWrapperInterface(_addressBook);
        marginRequirements = MarginRequirementsWrapperInterface(addressbook.getMarginRequirements());
        controller = ControllerWrapperInterface(addressbook.getController());
        oracle = OracleWrapperInterface(addressbook.getOracle());
        whitelist = WhitelistWrapperInterface(addressbook.getWhitelist());
        OTokenFactory = IOtokenFactoryWrapperInterface(addressbook.getOtokenFactory());
        calculator = MarginCalculatorWrapperInterface(addressbook.getMarginCalculator());

        beneficiary = _beneficiary;
        fillDeadline = _fillDeadline;
    }

    /************************************************
     *  SETTERS
     ***********************************************/

    /**
     * @notice sets the floor and cap of a particular asset notional
     * @dev can only be called by owner
     * @param _underlying underlying asset address
     * @param _min minimum USD notional value allowed (with 6 decimals)
     * @param _max maximum USD notional value allowed (with 6 decimals)
     */
    function setMinMaxNotional(
        address _underlying,
        uint256 _min,
        uint256 _max
    ) external onlyOwner {
        require(_underlying != address(0), "OTCWrapper: asset address cannot be 0");
        require(_min > 0, "OTCWrapper: minimum notional cannot be 0");
        require(_max > 0, "OTCWrapper: maximum notional cannot be 0");

        minMaxNotional[_underlying] = MinMaxNotional(_min, _max);
    }

    /**
     * @notice sets the whitelist status of market maker addresses
     * @dev can only be called by owner
     * @param _marketMakerAddress address of the market maker
     * @param _isWhitelisted bool with whitelist status
     */
    function setWhitelistMarketMaker(address _marketMakerAddress, bool _isWhitelisted) external onlyOwner {
        require(_marketMakerAddress != address(0), "OTCWrapper: market maker address cannot be 0");

        isWhitelistedMarketMaker[_marketMakerAddress] = _isWhitelisted;
    }

    /**
     * @notice sets the fee for a given underlying asset
     * @dev can only be called by owner
     * @param _underlying underlying asset address
     * @param _fee fee amount in bps with 2 decimals (400 = 4bps = 0.04%)
     */
    function setFee(address _underlying, uint256 _fee) external onlyOwner {
        require(_underlying != address(0), "OTCWrapper: asset address cannot be 0");
        require(_fee <= FEE_PERCENT_MULTIPLIER, "OTCWrapper: fee cannot be higher than 100%");

        fee[_underlying] = _fee;
    }

    /**
     * @notice sets the unwind fee for a given underlying asset
     * @dev can only be called by owner
     * @param _underlying underlying asset address
     * @param _unwindFee fee amount in bps with 2 decimals (400 = 4bps = 0.04%)
     */
    function setUnwindFee(address _underlying, uint256 _unwindFee) external onlyOwner {
        require(_underlying != address(0), "OTCWrapper: asset address cannot be 0");
        require(_unwindFee <= FEE_PERCENT_MULTIPLIER, "OTCWrapper: fee cannot be higher than 100%");

        unwindFee[_underlying] = _unwindFee;
    }

    /**
     * @notice sets the beneficiary address
     * @dev can only be called by owner
     * @param _beneficiary beneficiary address
     */
    function setBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "OTCWrapper: beneficiary address cannot be 0");

        beneficiary = _beneficiary;
    }

    /**
     * @notice sets the fill deadline duration
     * @dev can only be called by owner
     * @param _fillDeadline fill deadline duration in seconds
     */
    function setFillDeadline(uint256 _fillDeadline) external onlyOwner {
        require(_fillDeadline > 0, "OTCWrapper: fill deadline cannot be 0");

        fillDeadline = _fillDeadline;
    }

    /**
     * @notice sets the maximum price deviation by asset between place order and execute time (percentage with 2 decimals)
     * @dev can only be called by owner
     * @param _underlying underlying asset address
     * @param _maxDeviation max price deviation (percentage with 2 decimals - eg. 2% = 200)
     */
    function setMaxDeviation(address _underlying, uint256 _maxDeviation) external onlyOwner {
        require(_underlying != address(0), "OTCWrapper: underlying address cannot be 0");
        require(_maxDeviation <= 100e2, "OTCWrapper: max deviation should not be higher than 100%"); // 100e2 is equivalent to 100%

        maxDeviation[_underlying] = _maxDeviation;
    }

    /**
     * @notice sets the unwind buffer duration
     * @dev can only be called by owner
     * @param _unwindBufferDuration buffer time between last allowed unwind moment and expiry
     */
    function setUnwindBufferDuration(uint256 _unwindBufferDuration) external onlyOwner {
        require(_unwindBufferDuration >= fillDeadline + 60, "OTCWrapper: insufficient buffer time");
        unwindBufferDuration = _unwindBufferDuration;
    }

    /**
     * @dev updates the configuration of the OTC wrapper. can only be called by the owner
     */
    function refreshConfiguration() external onlyOwner {
        marginRequirements = MarginRequirementsWrapperInterface(addressbook.getMarginRequirements());
        controller = ControllerWrapperInterface(addressbook.getController());
        oracle = OracleWrapperInterface(addressbook.getOracle());
        whitelist = WhitelistWrapperInterface(addressbook.getWhitelist());
        OTokenFactory = IOtokenFactoryWrapperInterface(addressbook.getOtokenFactory());
        calculator = MarginCalculatorWrapperInterface(addressbook.getMarginCalculator());
    }

    /************************************************
     *  DEPOSIT & WITHDRAWALS
     ***********************************************/

    /**
     * @notice allows market maker to deposit collateral
     * @dev can only be called by the market maker who is the order seller
     * @param _orderID id of the order
     * @param _amount amount to deposit (with its respective token decimals)
     * @param _mmSignature market maker permit signature
     */
    function depositCollateral(
        uint256 _orderID,
        uint256 _amount,
        Permit calldata _mmSignature
    ) external nonReentrant {
        require(orderStatus[_orderID] == OrderStatus.Succeeded, "OTCWrapper: inexistent or unsuccessful order");
        require(_mmSignature.acct == _msgSender(), "OTCWrapper: signer is not the market maker");

        Order memory order = orders[_orderID];

        require(order.seller == _msgSender(), "OTCWrapper: sender is not the order seller");

        _deposit(order.collateral, _amount, _mmSignature);

        // approve margin pool to deposit collateral
        IERC20(order.collateral).safeApproveNonCompliant(addressbook.getMarginPool(), _amount);

        UtilsWrapperInterface.ActionArgs[] memory actions = new UtilsWrapperInterface.ActionArgs[](1);

        actions[0] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.DepositCollateral,
            address(this), // owner
            address(this), // address to transfer from
            order.collateral, // deposited asset
            order.vaultID, // vaultId
            _amount, // amount
            0, // index
            "" // data
        );

        // execute actions
        controller.operate(actions);

        emit CollateralDeposited(_orderID, _amount, order.seller);
    }

    /**
     * @notice allows market maker to withdraw collateral
     * @dev can only be called by the market maker who is the order seller
     * @param _orderID id of the order
     * @param _amount amount to withdraw (with its respective token decimals)
     */
    function withdrawCollateral(uint256 _orderID, uint256 _amount) external nonReentrant {
        require(orderStatus[_orderID] == OrderStatus.Succeeded, "OTCWrapper: inexistent or unsuccessful order");

        Order memory order = orders[_orderID];

        require(order.seller == _msgSender(), "OTCWrapper: sender is not the order seller");

        (UtilsWrapperInterface.Vault memory vault, , ) = controller.getVaultWithDetails(address(this), order.vaultID);

        UtilsWrapperInterface.ActionArgs[] memory actions = new UtilsWrapperInterface.ActionArgs[](1);

        uint256 amountToWithdraw;

        if (order.buyer != order.seller) {
            require(
                marginRequirements.checkWithdrawCollateral(
                    order.seller,
                    order.notional,
                    _amount,
                    order.oToken,
                    order.vaultID,
                    vault
                ),
                "OTCWrapper: insufficient collateral"
            );

            amountToWithdraw = _amount;
        } else {
            // seller transfers otokens to burn - requires approve() by the seller
            IERC20(order.oToken).safeTransferFrom(_msgSender(), address(this), order.size);

            // burn otokens
            actions[0] = UtilsWrapperInterface.ActionArgs(
                UtilsWrapperInterface.ActionType.BurnShortOption,
                address(this), // owner
                address(this), // address from which we transfer the oTokens
                order.oToken, // otoken address
                order.vaultID, // vaultId
                order.size, // amount to burn
                0, //index
                "" //data
            );

            // execute burn
            controller.operate(actions);

            // ensure the vault is no longer redeemable
            orders[_orderID].size = 0;

            amountToWithdraw = vault.collateralAmounts[0];
        }

        actions[0] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.WithdrawCollateral,
            address(this), // owner
            order.seller, // address to transfer to
            order.collateral, // withdrawn asset
            order.vaultID, // vaultId
            amountToWithdraw, // amount
            0, // index
            "" // data
        );

        // execute withdraw
        controller.operate(actions);

        emit CollateralWithdrawn(_orderID, amountToWithdraw, order.seller);
    }

    /**
     * @notice Deposits the `asset` from _msgSender() without an approve
     * `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments
     * @param _asset is the asset address to deposit
     * @param _depositAmount is the amount to deposit (with its respective token decimals)
     * @param _signature account permit signature
     */
    function _deposit(
        address _asset,
        uint256 _depositAmount,
        Permit calldata _signature
    ) private {
        require(_depositAmount > 0, "OTCWrapper: amount cannot be 0");

        if (_asset == USDC && IERC20(USDC).allowance(_signature.acct, address(this)) < _depositAmount) {
            // Sign for transfer approval
            IERC20Permit(USDC).permit(
                _signature.acct,
                address(this),
                _signature.amount,
                _signature.deadline,
                _signature.v,
                _signature.r,
                _signature.s
            );
        }

        // An approve() or permit() by the _msgSender() is required beforehand
        IERC20(_asset).safeTransferFrom(_signature.acct, address(this), _depositAmount);
    }

    /************************************************
     *  OTC OPERATIONS
     ***********************************************/

    /**
     * @notice places an order
     * @param _underlying underlying asset address
     * @param _isPut option type the vault is selling
     * @param _strikePrice option strike price (underlying USDC denominated price with 8 decimals)
     * @param _expiry option expiry timestamp
     * @param _premium order premium amount (USDC value with USDC decimals)
     * @param _size order size (with 8 decimals)
     */
    function placeOrder(
        address _underlying,
        bool _isPut,
        uint256 _strikePrice,
        uint256 _expiry,
        uint256 _premium,
        uint256 _size
    ) external {
        require(_size > 0, "OTCWrapper: size cannot be 0");

        // notional is expected to have 6 decimals
        // size and oracle price are expected to have 8 decimals
        // in aggregate we get 1e16 and therefore divide by 1e10 to obtain 6 decimals
        uint256 notional = (_size * oracle.getPrice(_underlying)) / (1e10);
        require(
            notional >= minMaxNotional[_underlying].min && notional <= minMaxNotional[_underlying].max,
            "OTCWrapper: invalid notional value"
        );
        require(_expiry > block.timestamp, "OTCWrapper: expiry must be in the future");

        latestOrder += 1;

        orders[latestOrder] = Order(
            _underlying,
            address(0),
            _isPut,
            _strikePrice,
            _expiry,
            _premium,
            notional,
            _msgSender(),
            address(0),
            0,
            address(0),
            block.timestamp,
            _size
        );

        ordersByAcct[_msgSender()].push(latestOrder);

        orderStatus[latestOrder] = OrderStatus.Pending;

        emit OrderPlaced(
            latestOrder,
            _underlying,
            _isPut,
            _strikePrice,
            _expiry,
            _premium,
            _msgSender(),
            _size,
            notional
        );
    }

    /**
     * @notice cancels an order
     * @param _orderID order id
     */
    function undoOrder(uint256 _orderID) external {
        require(orderStatus[_orderID] == OrderStatus.Pending, "OTCWrapper: inexistent or unsuccessful order");
        require(orders[_orderID].buyer == _msgSender(), "OTCWrapper: only buyer can undo the order");

        orderStatus[_orderID] = OrderStatus.Failed;

        emit OrderCancelled(_orderID);
    }

    /**
     * @notice executes an order
     * @dev can only be called by whitelisted market makers
     *      requires that product and collateral have already been whitelisted beforehand
     *      ensure that initial margin has been set up beforehand
     *      ensure collateral naked cap from Controller.sol is high enough for the additional collateral
     *      ensure setUpperBoundValues and setSpotShock from MarginCalculator.sol have been set up
     * @param _orderID id of the order
     * @param _userSignature user permit signature
     * @param _mmSignature market maker permit signature
     * @param _premium order premium amount (USDC value with USDC decimals)
     * @param _collateralAsset collateral asset address
     * @param _collateralAmount collateral amount (with its respective token decimals)
     */
    function executeOrder(
        uint256 _orderID,
        Permit calldata _userSignature,
        Permit calldata _mmSignature,
        uint256 _premium,
        address _collateralAsset,
        uint256 _collateralAmount
    ) external nonReentrant {
        require(orderStatus[_orderID] == OrderStatus.Pending, "OTCWrapper: inexistent or unsuccessful order");
        require(isWhitelistedMarketMaker[_msgSender()], "OTCWrapper: address not whitelisted marketmaker");
        require(_userSignature.amount >= _premium, "OTCWrapper: insufficient amount");

        Order memory order = orders[_orderID];

        require(_userSignature.acct == order.buyer, "OTCWrapper: signer is not the buyer");
        require(_userSignature.amount == order.premium, "OTCWrapper: invalid signature amount");
        require(_mmSignature.acct == _msgSender(), "OTCWrapper: signer is not the market maker");
        require(block.timestamp <= (order.openedAt + fillDeadline), "OTCWrapper: deadline has passed");
        require(whitelist.isWhitelistedCollateral(_collateralAsset), "OTCWrapper: collateral is not whitelisted");

        // notional is expected to have 6 decimals
        // size and oracle price are expected to have 8 decimals
        // in aggregate we get 1e16 and therefore divide by 1e10 to obtain 6 decimals
        uint256 notional = (order.size * oracle.getPrice(order.underlying)) / (1e10);

        uint256 deviation = maxDeviation[order.underlying];

        // Example: if max deviation is 2% then
        // (notional at execute time) * 100% < (notional at place order time) * (100% + 2%)
        // (notional at execute time) * 100% > (notional at place order time) * (100% - 2%)
        // 100e2 is equivalent to 100% by which notional is multiplied
        require(
            notional * 100e2 <= order.notional * (100e2 + deviation) &&
                notional * 100e2 >= order.notional * (100e2 - deviation),
            "OTCWrapper: notional beyond allowed deviation"
        );

        require(
            marginRequirements.checkMintCollateral(
                _msgSender(),
                notional,
                order.underlying,
                order.isPut,
                _collateralAmount,
                _collateralAsset
            ),
            "OTCWrapper: insufficient collateral"
        );

        // settle funds
        _settleFunds(order, _userSignature, _mmSignature, _premium, _collateralAsset, _collateralAmount, notional);

        // deposit collateral and mint otokens
        (uint256 vaultID, address oToken) = _depositCollateralAndMint(order, _collateralAsset, _collateralAmount);

        // order accounting
        orders[_orderID].premium = _premium;
        orders[_orderID].collateral = _collateralAsset;
        orders[_orderID].seller = _msgSender();
        orders[_orderID].vaultID = vaultID;
        orders[_orderID].oToken = oToken;
        orders[_orderID].notional = notional;
        orderStatus[_orderID] = OrderStatus.Succeeded;
        ordersByAcct[_msgSender()].push(_orderID);

        emit OrderExecuted(_orderID, _collateralAsset, _premium, _msgSender(), vaultID, oToken, _collateralAmount);
    }

    /**
     * @notice both parties deposit, the fee is transferred to beneficiary and premium is transferred to market maker
     * @param _order order struct with order details
     * @param _userSignature user permit signature
     * @param _mmSignature market maker permit signature
     * @param _premium order premium amount (USDC value with USDC decimals)
     * @param _collateralAsset collateral asset address
     * @param _collateralAmount collateral amount (with its respective token decimals)
     * @param _notional notional amount (USD value with 6 decimals)
     */
    function _settleFunds(
        Order memory _order,
        Permit calldata _userSignature,
        Permit calldata _mmSignature,
        uint256 _premium,
        address _collateralAsset,
        uint256 _collateralAmount,
        uint256 _notional
    ) private {
        // user inflow
        _deposit(USDC, _premium, _userSignature);

        // market maker inflow
        _deposit(_collateralAsset, _collateralAmount, _mmSignature);

        // eg. fee = 400 = 4bps = 0.04% , then need to divide by the FEE_PERCENT_MULTIPLIER
        // multiplication by 1e8 is used to compensate for the 8 decimals from USDC oracle price
        uint256 usdcPrice = oracle.getPrice(USDC);
        require(usdcPrice > 0, "OTCWrapper: invalid USDC price");
        uint256 orderFee = ((_notional * (fee[_order.underlying]) * 1e8) / FEE_PERCENT_MULTIPLIER) / usdcPrice;

        // transfer premium to market maker
        IERC20(USDC).safeTransfer(_msgSender(), (_premium - orderFee));
    }

    /**
     * @notice deposits collateral and mints otokens
     * @param _order order struct with order details
     * @param _collateralAsset collateral asset address
     * @param _collateralAmount collateral amount (with its respective token decimals)
     * @return vault id and otoken address
     */
    function _depositCollateralAndMint(
        Order memory _order,
        address _collateralAsset,
        uint256 _collateralAmount
    ) private returns (uint256, address) {
        // open vault
        uint256 vaultID = (controller.getAccountVaultCounter(address(this))) + 1;

        UtilsWrapperInterface.ActionArgs[] memory actions = new UtilsWrapperInterface.ActionArgs[](3);

        actions[0] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.OpenVault,
            address(this), // owner
            address(this), // receiver
            address(0), // asset, otoken
            vaultID, // vaultId
            0, // amount
            0, // index
            abi.encode(1) // vault type
        );

        // Approve margin pool to deposit collateral
        IERC20(_collateralAsset).safeApproveNonCompliant(addressbook.getMarginPool(), _collateralAmount);

        // deposit collateral
        actions[1] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.DepositCollateral,
            address(this), // owner
            address(this), // address to transfer from
            _collateralAsset, // deposited asset
            vaultID, // vaultId
            _collateralAmount, // amount
            0, // index
            "" // data
        );

        // retrieve otoken address
        address oToken = _getOrDeployOToken(_order, _collateralAsset);

        // mint otokens
        actions[2] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.MintShortOption,
            address(this), // owner
            _order.buyer, // address to transfer to
            oToken, // option address
            vaultID, // vaultId
            _order.size, // mint amount
            0, // index
            "" // data
        );

        // execute actions
        controller.operate(actions);

        return (vaultID, oToken);
    }

    /**
     * @notice checks if oToken exists, if not then deploys a new one
     * @param _order order struct with order details
     * @param _collateralAsset collateral asset address
     * @return otoken address
     */
    function _getOrDeployOToken(Order memory _order, address _collateralAsset) private returns (address) {
        address oToken = OTokenFactory.getOtoken(
            _order.underlying,
            USDC,
            _collateralAsset,
            _order.strikePrice,
            _order.expiry,
            _order.isPut
        );

        if (oToken == address(0)) {
            oToken = OTokenFactory.createOtoken(
                _order.underlying,
                USDC,
                _collateralAsset,
                _order.strikePrice,
                _order.expiry,
                _order.isPut
            );
        }

        return oToken;
    }

    /**
     * @notice settles the vault after expiry
     * @dev can only be called by the market maker who is the order seller
     * @param _orderID order id
     */
    function settleVault(uint256 _orderID) external nonReentrant {
        require(orderStatus[_orderID] == OrderStatus.Succeeded, "OTCWrapper: inexistent or unsuccessful order");

        Order memory order = orders[_orderID];

        require(order.seller == _msgSender(), "OTCWrapper: sender is not the order seller");

        UtilsWrapperInterface.ActionArgs[] memory actions = new UtilsWrapperInterface.ActionArgs[](1);

        actions[0] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.SettleVault,
            address(this), // owner
            order.seller, // address to transfer to
            address(0), // not used
            order.vaultID, // vaultId
            0, // not used
            0, // not used
            "" // not used
        );

        // execute actions
        controller.operate(actions);

        emit VaultSettled(_orderID);
    }

    /**
     * @notice allows user to redeem after expiry
     * @dev can only be called by the user who is the order buyer
     * @param _orderID order id
     */
    function redeem(uint256 _orderID) external nonReentrant {
        require(orderStatus[_orderID] == OrderStatus.Succeeded, "OTCWrapper: inexistent or unsuccessful order");

        Order memory order = orders[_orderID];

        require(order.buyer == _msgSender(), "OTCWrapper: sender is not the order buyer");

        // check if vault has enough collateral to cover payout
        (UtilsWrapperInterface.Vault memory vault, uint256 typeVault, ) = controller.getVaultWithDetails(
            address(this),
            order.vaultID
        );

        (, bool isValidVault) = calculator.getExcessCollateral(vault, typeVault);

        // require that vault is valid (has excess collateral) before redeeming
        // to avoid allowing redeeming undercollateralized vaults
        require(isValidVault, "OTCWrapper: insuficient collateral to redeem");

        UtilsWrapperInterface.ActionArgs[] memory actions = new UtilsWrapperInterface.ActionArgs[](1);

        actions[0] = UtilsWrapperInterface.ActionArgs(
            UtilsWrapperInterface.ActionType.Redeem,
            address(0), // not used
            order.buyer, // address to transfer to
            order.oToken, // otoken address
            0, // not used
            order.size, // otoken amount
            0, // not used
            "" // not used
        );

        // execute actions
        controller.operate(actions);

        orders[_orderID].size = 0;

        emit Reedem(_orderID, order.size);
    }

    /**
     * @notice sends fees to beneficiary
     * @param _asset the asset to claim
     */
    function claimFees(address _asset) external {
        require(_asset != address(0), "OTCWrapper: asset address cannot be 0");

        IERC20 asset = IERC20(_asset);

        uint256 amountToClaim = asset.balanceOf(address(this));
        require(amountToClaim > 0, "OTCWrapper: amount to claim cannot be 0");

        asset.safeTransfer(beneficiary, amountToClaim);

        emit FeesClaimed(amountToClaim, _asset);
    }

    /**
     * @notice Allows current buyer to unwind the position
     * @dev can only be called by whitelisted market makers
     * @param _sellerOrderSignature seller order unwind signature
     * @param _bidderOrderSignature bidder order unwind signature
     * @param _bidderUSDCSignature bidder permit signature
     */
    function sellRedeemRights(
        UnwindPermit calldata _sellerOrderSignature,
        UnwindPermit calldata _bidderOrderSignature,
        Permit calldata _bidderUSDCSignature
    ) external nonReentrant {
        // ensure order signature integrity
        UNWIND_PERMIT.checkOrderPermit(
            _sellerOrderSignature.acct,
            _sellerOrderSignature.orderID,
            _sellerOrderSignature.bidValue,
            _sellerOrderSignature.deadline,
            _sellerOrderSignature.v,
            _sellerOrderSignature.r,
            _sellerOrderSignature.s
        );
        UNWIND_PERMIT.checkOrderPermit(
            _bidderOrderSignature.acct,
            _bidderOrderSignature.orderID,
            _bidderOrderSignature.bidValue,
            _bidderOrderSignature.deadline,
            _bidderOrderSignature.v,
            _bidderOrderSignature.r,
            _bidderOrderSignature.s
        );

        // ensure match between seller and bidder unwind permits plus storage data
        require(_sellerOrderSignature.orderID == _bidderOrderSignature.orderID, "OTCWrapper: orders do not match");
        require(
            orderStatus[_sellerOrderSignature.orderID] == OrderStatus.Succeeded,
            "OTCWrapper: inexistent or unsuccessful order"
        );

        Order memory order = orders[_sellerOrderSignature.orderID];

        require(_msgSender() == _bidderOrderSignature.acct, "OTCWrapper: sender is not bidder");
        require(order.buyer == _sellerOrderSignature.acct, "OTCWrapper: seller has no right to sell");
        require(
            _bidderOrderSignature.bidValue >= _sellerOrderSignature.bidValue,
            "OTCWrapper: insufficient bid amount"
        );
        require(_sellerOrderSignature.bidValue > 0, "OTCWrapper: invalid bid value");

        // ensure a match between the bidder unwind permit and the bidder USDC permit
        require(_bidderUSDCSignature.acct == _bidderOrderSignature.acct, "OTCWrapper: accounts do not match");
        require(
            _bidderUSDCSignature.amount == _bidderOrderSignature.bidValue,
            "OTCWrapper: amount and bid value do not match"
        );
        require(_bidderUSDCSignature.deadline == _bidderOrderSignature.deadline, "OTCWrapper: deadlines do not match");

        // operation related restrictions
        require(
            block.timestamp + unwindBufferDuration < order.expiry,
            "OTCWrapper: can not unwind too close to expiry"
        );
        require(
            order.buyer != order.seller,
            "OTCWrapper: can not sell if same address is already long and short the option"
        );
        require(isWhitelistedMarketMaker[_msgSender()], "OTCWrapper: address not whitelisted market maker");

        // bidder's inflow
        _deposit(USDC, _bidderOrderSignature.bidValue, _bidderUSDCSignature);

        // calculate fee to beneficiary
        uint256 orderFee = (_bidderOrderSignature.bidValue * unwindFee[order.underlying]) / FEE_PERCENT_MULTIPLIER;

        // seller receives premium after fee is paid
        IERC20(USDC).safeTransfer(order.buyer, _bidderOrderSignature.bidValue - orderFee);

        // seller transfers otokens to bidder - requires approve() by the seller
        IERC20(order.oToken).safeTransferFrom(_sellerOrderSignature.acct, _bidderOrderSignature.acct, order.size);

        // bidder becomes the new order buyer
        orders[_bidderOrderSignature.orderID].buyer = _bidderOrderSignature.acct;

        emit RedeemRightsSold(
            _bidderOrderSignature.orderID,
            _sellerOrderSignature.acct,
            _bidderOrderSignature.acct,
            _bidderOrderSignature.bidValue
        );
    }

    /************************************************
     *  MISCELLANEOUS
     ***********************************************/

    /**
     * @dev overrides _msgSender() related to ERC2771
     */
    function _msgSender()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev overrides _msgData() related to ERC2771
     */
    function _msgData()
        internal
        view
        virtual
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}