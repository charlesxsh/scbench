// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/utils/introspection/ERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: @openzeppelin/contracts/token/ERC721/ERC721.sol


// OpenZeppelin Contracts (last updated v4.8.2) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;








/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * WARNING: Anyone calling this MUST ensure that the balances remain consistent with the ownership. The invariant
     * being that for any address `a` the value returned by `balanceOf(a)` must be equal to the number of tokens such
     * that `ownerOf(tokenId)` is `a`.
     */
    // solhint-disable-next-line func-name-mixedcase
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}

// File: contracts/FFT.sol


pragma solidity 0.8.18;




// The FTO contract interface
interface IFTO {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}



contract FFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    IFTO private _ftoContract;
   

    mapping(uint256 => uint256[]) private _ftoTokens;
  

struct FarmData {
    uint256 tokenId;
    string name;
    string location;
    string streetAddress;
    string city;
    string country;
    uint256 sizeInHectares;
    string farmOwnershipReference;
    bool isVerified;
    uint256 farmerTokenId; 
    }
    mapping(uint256 => FarmData) private _farmData;
    mapping(uint256 => string) private _tokenIPFSHash;
    mapping(address => uint256[]) private _farmsByOwner;
    address private contractAddress;
    address payable private _recipientAddress; 
   uint256 private _totalVerifiedFarms;
    uint256 private _totalUnverifiedFarms;
    mapping(address => uint256) private _totalVerifiedFarmsByOwner;
    mapping(address => uint256) private _totalUnverifiedFarmsByOwner;


    event FFTTokenCreated(
        uint256 indexed tokenId,
        address indexed owner,
        string tokenURI,
        string name,
        string location,
        string streetAddress,
        string city,
        string country,
        string farmOwnershipReference,
        uint256 sizeInHectares,
        uint256 _farmVerificationFee,
        address recipientAddress,
        address contractAddress
    );

   event FarmVerified(
    uint256 indexed tokenId,
    address contractAddress,
    address contractOwner,
    address tokenOwner
);

    event FarmUnverified(
        uint256 indexed tokenId,
    address contractAddress,
    address contractOwner,
    address tokenOwner
    );

    event FarmDataUpdated(
    uint256 indexed tokenId,
    string name,
    string location,
    string streetAddress,
    string city,
    string country,
    string farmOwnershipReference,
    uint256 sizeInHectares
    );


    constructor() ERC721("Fruittex Farm", "FFT") {
        _farmVerificationFee = 0; 
        _recipientAddress = payable(msg.sender); 
            
        }
 
    function setRecipientAddress(address payable newRecipientAddress) external onlyOwner {
        _recipientAddress = newRecipientAddress;
    }
     function getRecipientAddress() public view returns (address payable) {
    return _recipientAddress;
    }

      function setFTOContractAddress(address ftoContractAddress) external onlyOwner {
        _ftoContract = IFTO(ftoContractAddress);
    }

    function getFTOContractAddress() public view returns (address) {
    return address(_ftoContract);
    }

    
    uint256 private _farmVerificationFee;
    function setFarmVerficationFee(uint256 feeToVerify) external onlyOwner {
        _farmVerificationFee = feeToVerify;
    }
    function getVerificationFee() public view returns (uint256) {
        return _farmVerificationFee;
    }

   function mint(
    string memory name,
    string memory location,
    string memory streetAddress,
    string memory city,
    string memory country,
    string memory farmOwnershipReference,
    uint256 sizeInHectares
) public payable  {
    uint256 tokenId = _tokenIdCounter.current() + 1;
    _tokenIdCounter.increment();

    FarmData memory farm = FarmData({
        tokenId: tokenId,
        name: name,
        location: location,
        streetAddress: streetAddress,
        city: city,
        country: country,
        farmOwnershipReference: farmOwnershipReference,
        sizeInHectares: sizeInHectares,
        isVerified: false,
        farmerTokenId: 1 // Initialize the farmerTokenId to 1
    });

    _farmData[tokenId] = farm;
    _mint(msg.sender, tokenId);
    _farmsByOwner[msg.sender].push(tokenId);

    // Increase the count of total unverified farms
    _totalUnverifiedFarms++;
    _totalUnverifiedFarmsByOwner[msg.sender]++;


    // Emit the FFTTokenCreated event
    emit FFTTokenCreated(
        tokenId,
        msg.sender,
        tokenURI(tokenId),
        name,
        location,
        streetAddress,
        city,
        country,
        farmOwnershipReference,
        sizeInHectares,
        _farmVerificationFee,
        _recipientAddress,
        address(this)
    );

    // Apply farm Verification Fee
    require(msg.value >= _farmVerificationFee, "FTT: Insufficient merge fee");
    _recipientAddress.transfer(_farmVerificationFee);
}


    function updateFarmData(
        uint256 tokenId,
        string memory name,
        string memory location,
        string memory streetAddress,
        string memory city,
        string memory country,
        string memory farmOwnershipReference,
        uint256 sizeInHectares

    ) external onlyOwner {
        require(_exists(tokenId), "FFT: Token does not exist");

        FarmData storage farm = _farmData[tokenId];
        require(!farm.isVerified, "FFT: Farm is already verified");

        farm.name = name;
        farm.location = location;
        farm.streetAddress = streetAddress;
        farm.city = city;
        farm.country = country;
        farm.farmOwnershipReference;
        farm.sizeInHectares = sizeInHectares;

        emit FarmDataUpdated(
        tokenId,
        name,
        location,
        streetAddress,
        city,
        country,
        farmOwnershipReference,
        sizeInHectares
    );

    }

 function verifyFarm(uint256 tokenId) external onlyOwner {
    require(_exists(tokenId), "FFT: Token does not exist");
    FarmData storage farm = _farmData[tokenId];
    require(!farm.isVerified, "FFT: Farm is already verified");
    farm.isVerified = true;

    // Increment the counters
    _totalVerifiedFarms++;
    _totalUnverifiedFarms--;
    _totalVerifiedFarmsByOwner[ownerOf(tokenId)]++;
    _totalUnverifiedFarmsByOwner[ownerOf(tokenId)]--;


    emit FarmVerified(tokenId, address(this), owner(), ownerOf(tokenId));
}

function unverifyFarm(uint256 tokenId) external onlyOwner {
    require(_exists(tokenId), "FFT: Token does not exist");
    FarmData storage farm = _farmData[tokenId];
    require(farm.isVerified, "FFT: Farm is not verified");
    farm.isVerified = false;

    // Decrement the counters
    _totalVerifiedFarms--;
    _totalUnverifiedFarms++;
    _totalVerifiedFarmsByOwner[ownerOf(tokenId)]--;
    _totalUnverifiedFarmsByOwner[ownerOf(tokenId)]++;


    emit FarmUnverified(tokenId, address(this), owner(), ownerOf(tokenId));
}



    function doesFarmerExist(uint256 farmerTokenId) external view returns (bool) {
    return _exists(farmerTokenId);
}


    function getFarmData(uint256 tokenId) public view returns (FarmData memory) {
        require(_exists(tokenId), "FFT: Token does not exist");
        return _farmData[tokenId];
    }

    
    

    function totalTokensSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

       function getFarmsByOwner(address owner) public view returns (FarmData[] memory) {
        uint256[] storage farms = _farmsByOwner[owner];
        FarmData[] memory ownerFarms = new FarmData[](farms.length);

        for (uint256 i = 0; i < farms.length; i++) {
            ownerFarms[i] = _farmData[farms[i]];
        }

        return ownerFarms;
    }


    function listAllFarms() public view returns (FarmData[] memory) {
        FarmData[] memory farms = new FarmData[](_tokenIdCounter.current());

    for (uint256 i = 0; i < _tokenIdCounter.current(); i++) {
    farms[i] = _farmData[i];
    }
        return farms;
    }

       string private _baseTokenURI;

    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _setTokenURI(uint256 tokenId, string memory ipfsHash) internal {
    require(_exists(tokenId), "FFT: Token does not exist");
    _tokenIPFSHash[tokenId] = ipfsHash;
}

    function setTokenIPFSHash(uint256 tokenId, string memory ipfsHash) external onlyOwner {
        _setTokenURI(tokenId, ipfsHash);
    }

     function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "FTO: Token does not exist");

    string memory baseURI = _baseTokenURI;
    string memory ipfsHash = _tokenIPFSHash[tokenId];

    if (bytes(ipfsHash).length > 0) {
        return string(abi.encodePacked(baseURI, ipfsHash));
    } else {
        return "";
    }
}

  
 

    function getTotalVerifiedFarms() public view returns (uint256) {
        return _totalVerifiedFarms;
    }

 
    function getTotalNotVerifiedFarms() public view returns (uint256) {
    return _totalUnverifiedFarms;
}


    function getTotalVerifiedFarmsByOwner(address owner) public view returns (uint256) {
        return _totalVerifiedFarmsByOwner[owner];
    }

    function getTotalNotVerifiedFarmsByOwner(address owner) public view returns (uint256) {
        return _totalUnverifiedFarmsByOwner[owner];
    }



   function associateFTOWithFFT(uint256 fftTokenId, uint256 ftoTokenId) external {
    require(msg.sender == address(_ftoContract), "FFT: Only the FTO contract can associate FTO tokens.");
    require(_exists(fftTokenId), "FFT: FFT token does not exist.");

    _ftoTokens[fftTokenId].push(ftoTokenId);
}

function transferFFT(address to, uint256 fftTokenId) external {
    require(ownerOf(fftTokenId) == msg.sender, "FFT: Only the FFT owner can transfer the token.");

    // Check if the owner of the FFT token also owns the associated FTO tokens
    for (uint256 i = 0; i < _ftoTokens[fftTokenId].length; i++) {
        uint256 ftoTokenId = _ftoTokens[fftTokenId][i];
        require(_ftoContract.ownerOf(ftoTokenId) == msg.sender, "FFT: FFT owner does not own associated FTO token.");
    }

    // Transfer FFT token
    safeTransferFrom(msg.sender, to, fftTokenId);

    // Transfer associated FTO tokens
    for (uint256 i = 0; i < _ftoTokens[fftTokenId].length; i++) {
        uint256 ftoTokenId = _ftoTokens[fftTokenId][i];
        _ftoContract.safeTransferFrom(msg.sender, to, ftoTokenId);
    }
}


}
// File: @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// File: contracts/FTO.sol



pragma solidity 0.8.18;







contract FTO is ERC721Enumerable, Ownable, Pausable {
    using SafeMath for uint256;


    uint256 public constant MAX_TOKENS = 1000000;
    uint256 private _nextTokenId = 1;
    address payable private _recipientAddress; 
    address private contractAddress;
    address[] private _tokenOwner;
    uint256[] private _totalTrees;
    uint256[] private _datePlanted;
    string[] private _cropType;
    string[] private _rootstock;
    string[] private _cultivar;
    uint256[] private _yieldPercentage;
     uint256[] private _term;
     string private _baseTokenURI;
     uint256 private _FTOMintFee;
     address private _fftContractAddress;
     address public newContractAddress;
    bool public isUpgraded = false;
    mapping(uint256 => string) private _tokenIPFSHash;
    uint256[] private _farmerTokenId;

   enum OrchardStatus {
    PendingPlanting,
    InProgress,
    HarvestReady,
    PostHarvest,
    UnderReplantation,
    UnderRehabilitation,
    Abandoned,
    Dormant,
    Active,
    Transferred,
    Retired
}

    mapping(uint256 => OrchardStatus) private _orchardStatus;
    mapping(uint256 => bool) private _tokenPaused;


    event TokenCreated(
        uint256 indexed tokenId,
        uint256 farmerTokenId,
        address indexed owner,
        uint256 totalTrees,
        uint256 datePlanted,
        string cropType,
        string rootstock,
        string cultivar,
        uint256 _FTOMintFee,
        address contractAddress,
        uint256 tokenProfitTerm,
        uint256 tokenProfitPercentage
    );
    event TokenTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );
    event TokenSold(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        uint256 price
    );
    event TokenMetadataUpdated(
        uint256 indexed tokenId,
        uint256 indexed datePlanted,
        string indexed cropType,
        string rootstock,
        string cultivar
    );


     event tokenProfitPercentageSet(
            uint256 indexed tokenId,
            uint256 yieldPercentage,
            address indexed from,
            address contractAddress
        );

     event tokenProfitTermSet(
    uint256 indexed tokenId,
    uint256 termInYears,
    address indexed setter,
    address indexed contractAddress
);
   
    event TokenBurned(uint256 indexed tokenId);
    event ContractUpgraded(address indexed oldContractAddress, address indexed newContractAddress);

    constructor(address fftContractAddress, uint256 mintFee) ERC721("Fruittex Orchard", "FTO") {
    _fftContractAddress = fftContractAddress;
    _FTOMintFee = mintFee;
    _recipientAddress = payable(msg.sender);

    }

 
 function setOrchardStatus(uint256 tokenId, OrchardStatus status) external onlyOwner {
    require(_exists(tokenId), "FTO: Token does not exist");

    _orchardStatus[tokenId] = status;

 
    if (status == OrchardStatus.Retired) {
        _pauseToken(tokenId);
    } else {
        _unpauseToken(tokenId);
    }
}

    function _pauseToken(uint256 tokenId) internal {
        require(!_tokenPaused[tokenId], "FTO: Token is already paused");
        _tokenPaused[tokenId] = true;
    }

    function _unpauseToken(uint256 tokenId) internal {
        require(_tokenPaused[tokenId], "FTO: Token is not paused");
        _tokenPaused[tokenId] = false;
    }

    function isTokenPaused(uint256 tokenId) public view returns (bool) {
        return _tokenPaused[tokenId];
    }

    function getFTODetails(uint256 tokenId) public view returns (
        uint256 totalTrees,
        uint256 datePlanted,
        string memory cropType,
        string memory rootstock,
        string memory cultivar,
        uint256 term,
        uint256 yieldPercentage,
        uint256 fftTokenId
    ) {
        require(_exists(tokenId), "FTO: Token does not exist");

        totalTrees = _totalTrees[tokenId - 1];
        datePlanted = _datePlanted[tokenId - 1];
        cropType = _cropType[tokenId - 1];
        rootstock = _rootstock[tokenId - 1];
        cultivar = _cultivar[tokenId - 1];
        fftTokenId = _farmerTokenId[tokenId - 1];
        term = _term[tokenId - 1];
        yieldPercentage = _yieldPercentage[tokenId - 1];
    }


    function setFFTContractAddress(address fftContractAddress) public onlyOwner {
        _fftContractAddress = fftContractAddress;
    }

     function setRecipientAddress(address payable newRecipientAddress) external onlyOwner {
        _recipientAddress = newRecipientAddress;
    }

   function getRecipientAddress() public view returns (address payable) {
    return _recipientAddress;
    }


    function setTokenIPFSHash(uint256 tokenId, string memory ipfsHash) public onlyOwner {
    require(_exists(tokenId), "FTO: Token does not exist");
    _tokenIPFSHash[tokenId] = ipfsHash;
}


    function getTokenIPFSHash(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "FTO: Token does not exist");
    return _tokenIPFSHash[tokenId];
    }

  
    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _setTokenURI(uint256 tokenId, string memory ipfsHash) internal {
    require(_exists(tokenId), "FFT: Token does not exist");
    _tokenIPFSHash[tokenId] = ipfsHash;
}

     function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "FTO: Token does not exist");

    string memory baseURI = _baseTokenURI;
    string memory ipfsHash = _tokenIPFSHash[tokenId];

    if (bytes(ipfsHash).length > 0) {
        return string(abi.encodePacked(baseURI, ipfsHash));
    } else {
        return "";
    }
}

    function setFTOMintFee(uint256 mintFee) external onlyOwner {
        _FTOMintFee = mintFee;
    }
    function getFTOMintFee() public view returns (uint256) {
        return _FTOMintFee;
    }

  

   function createToken(
        uint256 totalTrees,
        uint256 datePlanted,
        string memory cropType,
        string memory rootstock,
        string memory cultivar,
        address fftContractAddress,
        uint256 farmerTokenId,
        uint256 term,
        uint256 yieldPercentage
        
    ) public payable {
        require(
            _nextTokenId <= MAX_TOKENS,
            "FTO: Maximum number of tokens reached"
        );
        require(totalTrees > 0, "FTO: Invalid total trees count");

    
        require(
            FFT(fftContractAddress).doesFarmerExist(farmerTokenId),
            "FTO: Farmer token does not exist"
        );

   
        require(
            FFT(fftContractAddress).balanceOf(msg.sender) > 0,
            "FTO: No FFT token exists for the owner"
        );

        uint256 tokenId = _nextTokenId;
        _nextTokenId = _nextTokenId.add(1);

        _tokenOwner.push(msg.sender); 
        _totalTrees.push(totalTrees);
        _datePlanted.push(datePlanted);
        _cropType.push(cropType);
        _rootstock.push(rootstock);
        _cultivar.push(cultivar);
        _term.push(term);
        _yieldPercentage.push(yieldPercentage);
        _farmerTokenId.push(farmerTokenId);
        _safeMint(msg.sender, tokenId);
       

        require(msg.value >= _FTOMintFee, "FTO: Insufficient FTO Minting fee");
        _recipientAddress.transfer(_FTOMintFee);

       FFT(fftContractAddress).associateFTOWithFFT(farmerTokenId, tokenId);
 
        emit TokenCreated(
            tokenId,
            farmerTokenId,
            msg.sender,
            totalTrees,
            datePlanted,
            cropType,
            rootstock,
            cultivar,
            _FTOMintFee,
            address(this),
            term,
            yieldPercentage
        );
          
    }


    function isOwnerOf(address owner, uint256 tokenId) public view returns (bool) {
    return ownerOf(tokenId) == owner;
    }

    function tokenExists(uint256 tokenId)
        public
        view
        returns (bool)
    {
        return _exists(tokenId);
    }

    struct TokenInfo {
        uint256 tokenId;
        uint256 totalTrees;
        uint256 datePlanted;
        string cropType;
        string rootstock;
        string cultivar; 
        uint256 term;
        uint256 yieldPercentage;
        address ownerAddress;
        address fftContractAddress; 
        uint256 farmerTokenId; 
    }

function getFTOTokens() external view returns (TokenInfo[] memory) {
    uint256 totalSupply = totalSupply();
    TokenInfo[] memory allTokens = new TokenInfo[](totalSupply);

    for (uint256 i = 0; i < totalSupply; i++) {
        uint256 tokenId = tokenByIndex(i);
        allTokens[i] = getTokenInfo(tokenId);
    }

    return allTokens;
}

function getAllFTOTokensByFFT(uint256 farmerTokenId) external view returns (TokenInfo[] memory) {
    uint256 totalSupply = totalSupply();
    TokenInfo[] memory farmerTokens = new TokenInfo[](totalSupply);
    uint256 tokenCount = 0;

    for (uint256 i = 0; i < totalSupply; i++) {
        uint256 tokenId = tokenByIndex(i);
        if (_farmerTokenId[tokenId - 1] == farmerTokenId) {
            farmerTokens[tokenCount++] = getTokenInfo(tokenId);
        }
    }

    // Resize the array to fit the actual number of tokens
    assembly {
        mstore(farmerTokens, tokenCount)
    }

    return farmerTokens;
}



function calculateTotalTreesForAllFTOs() public view returns (uint256) {
    uint256 totalTrees = 0;

    for (uint256 i = 0; i < _nextTokenId - 1; i++) {
        address tokenOwner = ownerOf(i + 1);
        if (tokenOwner != address(0)) {
            totalTrees += _totalTrees[i];
        }
    }

    return totalTrees;
}


 function calculateTotalFTOTreesByOwner(address owner) public view returns (uint256) {
    uint256 totalTrees = 0;

    for (uint256 i = 0; i < _nextTokenId - 1; i++) {
        address tokenOwner = ownerOf(i + 1);
        if (tokenOwner == owner) {
            totalTrees += _totalTrees[i];
        }
    }

    return totalTrees;
}

        function burnToken(uint256 tokenId) external onlyOwner {
    require(_exists(tokenId), "FTO: Token does not exist");

    _burn(tokenId);
    delete _totalTrees[tokenId];
    delete _datePlanted[tokenId];
    delete _cropType[tokenId];
    delete _rootstock[tokenId];
    delete _cultivar[tokenId];

    emit TokenBurned(tokenId);
}

    function updateTokenMetadata(
        uint256 tokenId,
        uint256 datePlanted,
        string memory cropType,
        string memory rootstock,
        string memory cultivar

    ) public {
        require(_exists(tokenId), "FTO: Token does not exist");
        require(
            _tokenOwner[tokenId] == msg.sender,
            "FTO: Caller is not the token owner"
        );

        _datePlanted[tokenId] = datePlanted;
        _cropType[tokenId] = cropType;
        _rootstock[tokenId] = rootstock;
        _cultivar[tokenId] = cultivar;

        emit TokenMetadataUpdated(
            tokenId,
            datePlanted,
            cropType,
            rootstock,
            cultivar
        );
    }

function getAllFTOTokensByOwner(address owner) public view returns (TokenInfo[] memory) {
    uint256 tokenCount = balanceOf(owner);
    TokenInfo[] memory allTokens = new TokenInfo[](tokenCount);

    for (uint256 i = 0; i < tokenCount; i++) {
        uint256 tokenId = tokenOfOwnerByIndex(owner, i);
        allTokens[i] = getTokenInfo(tokenId);
    }

    return allTokens;
}


    function getTotalFTObyOwner(address owner) public view returns (uint256) {
    uint256 totalFTO = 0;

    for (uint256 i = 0; i < _tokenOwner.length; i++) {
        if (_tokenOwner[i] == owner) {
            totalFTO++;
        }
    }

    return totalFTO;
}

function getTotalFTObyFFT(uint256 farmerTokenId) public view returns (uint256) {
    uint256 totalFTO = 0;

    for (uint256 i = 0; i < _nextTokenId - 1; i++) {
        if (_farmerTokenId[i] == farmerTokenId) {
            totalFTO++;
        }
    }

    return totalFTO;
}


    function getTreeCount(uint256 ftoTokenId) public view returns (uint256) {
        require(_exists(ftoTokenId), "FTO: FTO token does not exist");
        return _totalTrees[ftoTokenId - 1];
    }

    function upgradeContract(address _newContractAddress) external onlyOwner {
        newContractAddress = _newContractAddress;
        isUpgraded = true;

        emit ContractUpgraded(address(this), newContractAddress);
    }

    function getNewContractAddress() public view returns (address) {
        require(isUpgraded, "Contract has not been upgraded yet");
        return newContractAddress;
    }

function getTokenInfo(uint256 tokenId) public view returns (TokenInfo memory) {
    require(tokenId > 0 && tokenId <= _nextTokenId, "FTO: Invalid tokenId");
    uint256 index = tokenId - 1;
    return TokenInfo({
        tokenId: tokenId,
        totalTrees: _totalTrees[index],
        datePlanted: _datePlanted[index],
        cropType: _cropType[index],
        rootstock: _rootstock[index],
        cultivar: _cultivar[index],
        term: _term[index],
        yieldPercentage: _yieldPercentage[index],
        fftContractAddress: _fftContractAddress,
        farmerTokenId: _farmerTokenId[index],
        ownerAddress: ownerOf(tokenId)
    });
}




}

// File: contracts/FTT.sol


pragma solidity 0.8.18;










contract FTT is ERC721, Ownable, Pausable, ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

 struct FTTData {
    uint256 ftoTokenId;
    uint256 fttTokenId;
    uint256 treeCount;
    address owner;
    bool isSold;
     
}

    FTO private _ftoContract;
    mapping(uint256 => uint256) private _treeCounts;
    mapping(uint256 => uint256) private _treesPerFTT;
    mapping(uint256 => uint256) private _fttToFtoMapping;
    uint256 private _maxTreesPerFTO;
    uint256 private _mintingFee;
    address private _approvedSpender;
    address payable private _recipientAddress; 
    uint256 private _totalTreeCount;
    mapping(uint256 => string) private _tokenIPFSHash;
    address private contractAddress;
    address public newContractAddress;
    bool public isUpgraded = false;
    address private _ftoContractAddress;
  
    event MintingFeePaid(address indexed payer, address indexed recipient, uint256 amount);
    event MintEvent(
        uint256 indexed ftoTokenId, 
        uint256 indexed tokenId, 
        uint256 treeCount, 
        address owner,
        address contractAddress,
        uint256 _mintingFee, 
        string tokenURI
        );
    event bulkTokensMinted(
      uint256 indexed tokenId, 
      uint256 treeCount, 
      address indexed owner,
       address contractAddress, 
      uint256 ftoTokenId,
      uint256 _mintingFee
      );   
    event splitTokensCreated(
        uint256 indexed tokenId, 
        uint256 treeCount, 
        address indexed owner, 
        address contractAddress,
        uint256 ftoTokenId,
        uint256 _splitFee
    );
    event splitTokenBurned(
        uint256 indexed tokenId, 
        uint256 treeCount, 
        address indexed owner, 
        address contractAddress,
        uint256 ftoTokenId
    );
    event mergeTokenBurned(
        uint256 burnedTokenId, 
        uint256 treeCount, 
        address contractAddress, 
        address indexed owner,
        uint256 ftoTokenId
    );
    event mergeTokenAdjusted(
        uint256 mergedTokenId, 
        uint256 treeCount, 
        address contractAddress, 
        address indexed owner, 
        uint256 ftoTokenId,
        uint256 _mergeFee
    );
     event transferFromEvent(
         address from, 
         address to, 
         uint256 indexed tokenId,
         address indexed owner,
         address contractAddress,
         uint256 ftoTokenId,
         uint256 totalTrees
    );
    event approveFTTMarketPlaceOnceEvent(
        address indexed FTTMarketPlaceAddress, 
        address indexed owner,
        address contractAddress
    );
    event disapproveFTTMarketPlaceOnceEvent(
        address indexed FTTMarketPlaceAddress, 
        address indexed owner,
        address contractAddress
    );
    event burnFTTEvent(
        uint256 indexed tokenId,
        uint256 treeCount, 
        address contractAddress, 
        address indexed owner, 
        uint256 ftoTokenId 
    );
    event withdrawEvent(
        address fromAddress, 
        address indexed recipientAddress, 
        address contractAddress, 
        uint256 amount
    );
     event setRecipientAddressEvent(
        address indexed recipientAddress,
        address fromAddress, 
        address indexed owner, 
        address contractAddress
    );
    event setMintingFeeEvent(
        address fromAddress, 
        address indexed owner, 
        address contractAddress,
        uint256 mintingFee
    );
    event setSplitFeeEvent(
        address fromAddress, 
        address indexed owner, 
        address contractAddress,
        uint256 splitFee
    );
    event setMergeFeeEvent(
        address fromAddress, 
        address indexed owner, 
        address contractAddress,
        uint256 mergeFee
    );

    event setApprovedSpenderEvent(
        address indexed spender,
        address fromAddress, 
        address indexed owner, 
        address contractAddress
        );

    event ContractUpgraded(address indexed oldContractAddress, address indexed newContractAddress);
   
 constructor(address ftoContractAddress, uint256 maxTreesPerFTO, uint256 mintingFeeInWei, uint256 feeToSplit, uint256 feeToMerge) ERC721("Fruittex Trees", "FTT") {
    _ftoContract = FTO(ftoContractAddress);
    _maxTreesPerFTO = maxTreesPerFTO;
    _mintingFee = mintingFeeInWei;
    _splitFee = feeToSplit;
    _mergeFee = feeToMerge;
    _recipientAddress = payable(msg.sender); 
    contractAddress = address(this);
}

   function setFtoContractAddress(address ftoContractAddress) public onlyOwner {
        _ftoContractAddress = ftoContractAddress;
    }


    function getContractAddress() public view returns (address) {
        return contractAddress;
    }

    function setMintingFee(uint256 feeInWei) external onlyOwner {
        _mintingFee = feeInWei;

       emit setMintingFeeEvent(msg.sender, owner(), address(this), _mintingFee);  
    }

    function setTreeCount(uint256 tokenId, uint256 treeCount) external onlyOwner {
        _treeCounts[tokenId] = treeCount;
    }
    function setRecipientAddress(address payable newRecipientAddress) external onlyOwner {
        _recipientAddress = newRecipientAddress;

        emit setRecipientAddressEvent(_recipientAddress, msg.sender, owner(), address(this));

    }
     function getRecipientAddress() public view returns (address payable) {
    return _recipientAddress;
    }

    function getMintingFee(uint256 treeCount, uint256 treesPerFTT) public view returns (uint256) {
    uint256 fttMintCount = treeCount / treesPerFTT;
    uint256 fttRemainder = treeCount % treesPerFTT;
    if (fttRemainder > 0) {
        fttMintCount += 1;
    }
    uint256 mintingFee = _mintingFee * fttMintCount;

    return mintingFee;
}


function approveFTTMarketPlaceOnce(address payable FTTMarketPlaceAddress) public {
   
    setApprovalForAll(FTTMarketPlaceAddress, true);
    emit approveFTTMarketPlaceOnceEvent(FTTMarketPlaceAddress, msg.sender, address(this));
}

function disapproveFTTMarketPlaceOnce(address FTTMarketPlaceAddress) public {
   
    setApprovalForAll(FTTMarketPlaceAddress, false);

     emit disapproveFTTMarketPlaceOnceEvent(FTTMarketPlaceAddress, msg.sender, address(this));
}

function getApprovalStatus(address FTTMarketPlaceAddress) public view returns (bool) {
   
    return isApprovedForAll(owner(), FTTMarketPlaceAddress);
}


function mint(uint256 ftoTokenId, uint256 treeCount, address owner, uint256 treesPerFTT) public payable whenNotPaused{
    require(_ftoContract.getTreeCount(ftoTokenId) > 0, "FTT: Invalid FTO token ID");
    require(treeCount > 0, "FTT: Invalid tree count");
    require(treesPerFTT > 0, "FTT: Invalid trees per FTT");
    uint256 existingFTTsTreeCount = getTotalTreeCountByFto(owner, ftoTokenId);
    uint256 remainingTreeCount = _ftoContract.getTreeCount(ftoTokenId) - existingFTTsTreeCount;

    require(treeCount <= remainingTreeCount, "FTT: Exceeds available tree count for FTO");

    uint256 fttMintCount = treeCount / treesPerFTT;
    uint256 fttRemainder = treeCount % treesPerFTT;
    if (fttRemainder > 0) {
        fttMintCount += 1;
    }

    uint256 mintingFee = _mintingFee * fttMintCount;

    require(msg.value >= mintingFee, "FTT: Insufficient payment");

   
    _recipientAddress.transfer(mintingFee);
    emit MintingFeePaid(msg.sender, _recipientAddress, mintingFee);

    for (uint256 i = 0; i < fttMintCount; i++) {
        uint256 currentFttCount = i == fttMintCount - 1 && fttRemainder > 0 ? fttRemainder : treesPerFTT;
        uint256 tokenId = _tokenIds.current() + 1;
        _mint(owner, tokenId);
        _tokenIds.increment();
        _treeCounts[tokenId] = currentFttCount;
        _treesPerFTT[tokenId] = treesPerFTT;
        _fttToFtoMapping[tokenId] = ftoTokenId;

        emit MintEvent(
            ftoTokenId,
            tokenId,
            currentFttCount,
            owner,
            address(this),
            _mintingFee,
            tokenURI(tokenId) 
        );
    }
}

    

   function mintBulk(uint256 ftoTokenId, uint256[] memory treeCounts, address owner) public payable whenNotPaused{
    require(_ftoContract.getTreeCount(ftoTokenId) > 0, "FTT: Invalid FTO token ID");
    
 
    
    uint256 existingFTTsTreeCount = getTotalTreeCountByFto(owner, ftoTokenId);
    uint256 remainingTreeCount = _ftoContract.getTreeCount(ftoTokenId) - existingFTTsTreeCount;
    
    uint256 totalMintingFee = _mintingFee * treeCounts.length;
    
    require(msg.value >= totalMintingFee, "FTT: Insufficient payment");
    
   
    _recipientAddress.transfer(totalMintingFee);
    emit MintingFeePaid(msg.sender, _recipientAddress, totalMintingFee);
    
    uint256 tokenId = _tokenIds.current() + 1;
    
    for (uint256 i = 0; i < treeCounts.length; i++) {
        uint256 treeCount = treeCounts[i];
        
        require(treeCount > 0, "FTT: Invalid tree count");
        require(treeCount <= remainingTreeCount, "FTT: Exceeds available tree count for FTO");
        
        _mint(owner, tokenId);
        _tokenIds.increment();
        _treeCounts[tokenId] = treeCount;
        _treesPerFTT[tokenId] = 1;  
        _fttToFtoMapping[tokenId] = ftoTokenId;
        
      
        emit bulkTokensMinted(tokenId, treeCount, owner, address(this), ftoTokenId, _mintingFee);

        tokenId++;
    }
}

            uint256 private _splitFee;
            uint256 public splitFee;
            function setSplitFee(uint256 feeToSplit) external onlyOwner {
                _splitFee = feeToSplit;

                emit setSplitFeeEvent(msg.sender, owner(), address(this), _splitFee); 
            }

            function getSplitFee() public view returns (uint256) {
                return _splitFee;
            }


        function splitFTT(uint256 tokenId, uint256 newTokenCount) external payable whenNotPaused{
        require(_exists(tokenId), "FTT: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "FTT: Sender does not own the token");
        require(newTokenCount > 0, "FTT: Invalid new token count");
        uint256 treeCount = _treeCounts[tokenId];
        require(treeCount % newTokenCount == 0, "FTT: Tree count is not divisible by the new token count");
        uint256 treesPerNewToken = treeCount / newTokenCount;
        uint256 originalMappingValue = _fttToFtoMapping[tokenId];

        for (uint256 i = 0; i < newTokenCount; i++) {
            uint256 newTokenId = _tokenIds.current() + 1;
            _mint(msg.sender, newTokenId);
            _tokenIds.increment();
            _treeCounts[newTokenId] = treesPerNewToken;
            _treesPerFTT[newTokenId] = treesPerNewToken;
        _fttToFtoMapping[newTokenId] = originalMappingValue; 

            emit splitTokensCreated(newTokenId, treesPerNewToken, msg.sender, address(this), _fttToFtoMapping[tokenId], _splitFee);
        }

     
        uint256 splitFeeTotal = _splitFee * newTokenCount;
        require(msg.value >= splitFeeTotal, "FTT: Insufficient split fee");
        _recipientAddress.transfer(splitFeeTotal);

        emit splitTokenBurned(tokenId, treeCount, msg.sender, address(this), _fttToFtoMapping[tokenId]);

        delete _fttToFtoMapping[tokenId];
        _burn(tokenId);
        delete _treeCounts[tokenId];
        delete _treesPerFTT[tokenId];
        delete _fttToFtoMapping[tokenId];
    }

    uint256 private _mergeFee;
    function setMergeFee(uint256 feeToMerge) external onlyOwner {
        _mergeFee = feeToMerge;

        emit setMergeFeeEvent(msg.sender, owner(), address(this), _mergeFee); 
    }
    function getMergeFee() public view returns (uint256) {
        return _mergeFee;
    }

    function mergeFTT(uint256[] memory tokenIds, uint256 mergedTokenId) external payable whenNotPaused{
    require(tokenIds.length > 1, "FTT: Must provide at least two token IDs");
    require(_exists(mergedTokenId), "FTT: Merged token ID does not exist");

    uint256 totalTrees = 0;
    uint256 ftoId = _fttToFtoMapping[tokenIds[0]];  

    for (uint256 i = 0; i < tokenIds.length; i++) {
        uint256 tokenId = tokenIds[i];
        require(_exists(tokenId), "FTT: Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "FTT: Sender does not own the token");
        require(_fttToFtoMapping[tokenId] == ftoId, "FTT: Tokens must belong to the same FTO");

        uint256 treeCount = _treeCounts[tokenId];
        totalTrees += treeCount;

      
        _burn(tokenId);
        delete _treeCounts[tokenId];
        delete _treesPerFTT[tokenId];
        delete _fttToFtoMapping[tokenId];

       
        emit mergeTokenBurned(tokenId, treeCount, address(this), msg.sender, ftoId);

    }

 
    _fttToFtoMapping[mergedTokenId] = ftoId;
    require(msg.value >= _mergeFee, "FTT: Insufficient merge fee");
    _recipientAddress.transfer(_mergeFee);
    _treeCounts[mergedTokenId] += totalTrees;

    emit mergeTokenAdjusted(mergedTokenId, _treeCounts[mergedTokenId], address(this), msg.sender, ftoId, _mergeFee);
}

        
    function getTotalTreeCountByFto(address owner, uint256 ftoTokenId) public view returns (uint256) {
        uint256 fttCount = balanceOf(owner);
        uint256 totalTrees = 0;

        for (uint256 i = 0; i < fttCount; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            uint256 ftoId = getFtoTokenId(tokenId);

            if (ftoId == ftoTokenId) {
                totalTrees += _treeCounts[tokenId];
            }
        }

        return totalTrees;
    }



function getTotalFTTmintedByFtoOwner(address owner) public view returns (uint256) {
    uint256 totalTrees = 0;
    uint256 ftoCount = balanceOf(owner);

    for (uint256 i = 0; i < ftoCount; i++) {
        uint256 ftoTokenId = tokenOfOwnerByIndex(owner, i);
        uint256 treesInFTT = getTreesInFTT(ftoTokenId);
        totalTrees += treesInFTT;
    }

    return totalTrees;
}

function getTreesInFTT(uint256 ftoTokenId) internal view returns (uint256) {
    uint256 totalTrees = 0;
    uint256 fttCount = _tokenIds.current();

    for (uint256 tokenId = 1; tokenId <= fttCount; tokenId++) {
        if (_exists(tokenId) && getFtoTokenId(tokenId) == ftoTokenId) {
            totalTrees += _treeCounts[tokenId];
        }
    }

    return totalTrees;
}


    function getFtoTokenId(uint256 fttTokenId) public view returns (uint256) {
        return _fttToFtoMapping[fttTokenId];
    }

    function getFtoTreeCount(uint256 tokenId) public view returns (uint256) {
        uint256 ftoTokenId = getFtoTokenId(tokenId);
        return _ftoContract.getTreeCount(ftoTokenId);
    }

    function getFTTsByOwner(address owner) public view returns (FTTData[] memory) {
    uint256 fttCount = balanceOf(owner);
    FTTData[] memory fttData = new FTTData[](fttCount);

    for (uint256 i = 0; i < fttCount; i++) {
        uint256 tokenId = tokenOfOwnerByIndex(owner, i);
        uint256 ftoTokenId = getFtoTokenId(tokenId); 
        fttData[i] = FTTData({
            ftoTokenId: ftoTokenId, 
            fttTokenId: tokenId,
            treeCount: _treeCounts[tokenId],
            owner: owner,
            isSold: false
            
        });
    }

    return fttData;
    }

function getFTTDataByTokenId(uint256 fttTokenId) public view returns (FTTData memory) {
    require(_exists(fttTokenId), "FTT token does not exist");

    FTTData memory fttData;

    fttData = FTTData({
        ftoTokenId: getFtoTokenId(fttTokenId),
        fttTokenId: fttTokenId,
        treeCount: _treeCounts[fttTokenId],
        owner: ownerOf(fttTokenId),
        isSold: false
    });

    return fttData;
}



    
    function countTotalTreesByOwner(address owner) public view returns (uint256) {
        uint256 fttCount = balanceOf(owner);
        uint256 totalTrees = 0;

        for (uint256 i = 0; i < fttCount; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            totalTrees += _treeCounts[tokenId];
        }

        return totalTrees;
    }

    function listAllFTTs() public view returns (FTTData[] memory) {
    uint256 fttCount = _tokenIds.current();
    FTTData[] memory fttData = new FTTData[](fttCount);

    uint256 dataCount = 0;

    for (uint256 tokenId = 1; tokenId <= fttCount; tokenId++) {
        if (_exists(tokenId)) {
            uint256 treeCount = _treeCounts[tokenId];
            address owner = ownerOf(tokenId);
            uint256 ftoTokenId = getFtoTokenId(tokenId); 

            fttData[dataCount] = FTTData({
                ftoTokenId: ftoTokenId,
                fttTokenId: tokenId,
                treeCount: treeCount,
                owner: owner,
                isSold: false
            });
            dataCount++;
        }
    }

  
    if (dataCount < fttCount) {
        FTTData[] memory resizedData = new FTTData[](dataCount);
        for (uint256 i = 0; i < dataCount; i++) {
            resizedData[i] = fttData[i];
        }
        fttData = resizedData;
    }

    return fttData;
}




    function listAllFTTsByFto(uint256 ftoTokenId) public view returns (FTTData[] memory) {
    uint256 fttCount = _tokenIds.current();
    FTTData[] memory fttData = new FTTData[](fttCount);
    uint256 dataCount = 0;

    for (uint256 tokenId = 1; tokenId <= fttCount; tokenId++) {
        if (_exists(tokenId)) {
            uint256 treeCount = _treeCounts[tokenId];
            address owner = ownerOf(tokenId);
            uint256 ftoId = getFtoTokenId(tokenId);

            if (ftoId == ftoTokenId) {
                fttData[dataCount] = FTTData({
                    ftoTokenId: ftoId,
                    fttTokenId: tokenId,
                    treeCount: treeCount,
                    owner: owner,
                    isSold: false
                });
                dataCount++;
            }
        }
    }

    
    if (dataCount < fttCount) {
        FTTData[] memory resizedData = new FTTData[](dataCount);
        for (uint256 i = 0; i < dataCount; i++) {
            resizedData[i] = fttData[i];
        }
        fttData = resizedData;
    }

    return fttData;
}

function listAllOwnerFTTsByFto(uint256 ftoTokenId, address walletAddress) public view returns (FTTData[] memory) {
    uint256 fttCount = _tokenIds.current();
    FTTData[] memory fttData = new FTTData[](fttCount);
    uint256 dataCount = 0;

    for (uint256 tokenId = 1; tokenId <= fttCount; tokenId++) {
        if (_exists(tokenId)) {
            uint256 treeCount = _treeCounts[tokenId];
            address owner = ownerOf(tokenId);
            uint256 ftoId = getFtoTokenId(tokenId);

            if (ftoId == ftoTokenId && owner == walletAddress) {
                fttData[dataCount] = FTTData({
                    ftoTokenId: ftoId,
                    fttTokenId: tokenId,
                    treeCount: treeCount,
                    owner: owner,
                    isSold: false
                });
                dataCount++;
            }
        }
    }

  
    if (dataCount < fttCount) {
        FTTData[] memory resizedData = new FTTData[](dataCount);
        for (uint256 i = 0; i < dataCount; i++) {
            resizedData[i] = fttData[i];
        }
        fttData = resizedData;
    }

    return fttData;
}




    function getTotalTreeCount(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "FTT: Token does not exist");
        return _treeCounts[tokenId];
    }

    
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }


  function getTotalFTTtreeCount() public view returns (uint256) {
    uint256 totalTrees = 0;
    for (uint256 i = 1; i <= totalSupply(); i++) {
        totalTrees += _treeCounts[i];
    }
    return totalTrees;
    }

        function burnFTT(uint256 tokenId) external {
            require(_exists(tokenId), "FTT: Token does not exist");
            require(ownerOf(tokenId) == msg.sender, "FTT: Sender does not own the token");

            _burn(tokenId);
            delete _treeCounts[tokenId];
            delete _treesPerFTT[tokenId];
            delete _fttToFtoMapping[tokenId];

            uint256 ftoTokenId = getFtoTokenId(tokenId); 
            uint256 fttTreeCount = getTotalTreeCount(tokenId);

            emit burnFTTEvent(tokenId, fttTreeCount, address(this), msg.sender, ftoTokenId);
        }

        function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
            require(index < balanceOf(owner), "FTT: Index out of bounds");

            uint256 tokenCount = 0;
            for (uint256 i = 1; i <= _tokenIds.current(); i++) {
                uint256 tokenId = i;
                if (_exists(tokenId) && ownerOf(tokenId) == owner) {
                    if (tokenCount == index) {
                        return tokenId;
                    }
                    tokenCount++;
                }
            }
            revert("FTT: No token found for the provided index");
        }

        function uintToString(uint256 value) internal pure returns (string memory) {
            if (value == 0) {
                return "0";
            }
            uint256 temp = value;
            uint256 digits;
            while (temp != 0) {
                digits++;
                temp /= 10;
            }
            bytes memory buffer = new bytes(digits);
            while (value != 0) {
                digits -= 1;
                buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
                value /= 10;
            }
            return string(buffer);
        }

        function setTokenIPFSHash(uint256 tokenId, string memory ipfsHash) public onlyOwner {
        require(_exists(tokenId), "FTO: Token does not exist");
        _tokenIPFSHash[tokenId] = ipfsHash;
    }


    function getTokenIPFSHash(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "FTO: Token does not exist");
    return _tokenIPFSHash[tokenId];
    }


    string private _baseTokenURI;

    function setBaseURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _setTokenURI(uint256 tokenId, string memory ipfsHash) internal {
    require(_exists(tokenId), "FFT: Token does not exist");
    _tokenIPFSHash[tokenId] = ipfsHash;
}

     function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), "FTO: Token does not exist");

    string memory baseURI = _baseTokenURI;
    string memory ipfsHash = _tokenIPFSHash[tokenId];

    if (bytes(ipfsHash).length > 0) {
        return string(abi.encodePacked(baseURI, ipfsHash));
    } else {
        return "";
    }
}

    function setApprovedSpender(address spender) external onlyOwner {
        _approvedSpender = spender;

         emit setApprovedSpenderEvent(spender, msg.sender, owner(), address(this) );
    }

    function isApprovedSpender(address spender) public view returns (bool) {
        return spender == _approvedSpender;
    }

 

function transferFrom(address from, address to, uint256 tokenId) public override {
    super.transferFrom(from, to, tokenId);

    uint256 ftoTokenId = getFtoTokenId(tokenId); 
    uint256 fttTreeCount = getTotalTreeCount(tokenId);
   

    emit transferFromEvent(from, to, tokenId, msg.sender, address(this), ftoTokenId, fttTreeCount);
}



    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            _treesPerFTT[tokenId] == _treeCounts[tokenId] || isApprovedSpender(msg.sender),
            "FTT: Can only transfer entire FTT tokens or spender must be approved"
        );
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function withdraw(uint256 amount) external onlyOwner nonReentrant{
    require(amount <= address(this).balance, "FTT: Withdraw amount exceeds balance");
    payable(owner()).transfer(amount);

    
    emit withdrawEvent(msg.sender, owner(), address(this), amount);

    }

      function upgradeContract(address _newContractAddress) external onlyOwner {
        newContractAddress = _newContractAddress;
        isUpgraded = true;
        emit ContractUpgraded(address(this), newContractAddress);
    }

    function getNewContractAddress() public view returns (address) {
        require(isUpgraded, "Contract has not been upgraded yet");
        return newContractAddress;
    }

       function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

}