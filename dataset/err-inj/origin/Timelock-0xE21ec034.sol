// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

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


contract Timelock is ReentrancyGuard {

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MINIMUM_DELAY = 2 days;
    uint public constant MAXIMUM_DELAY = 30 days;
    uint public delay;

    mapping (bytes32 => bool) public queuedTransactions;
    bytes32[] public executedTransactions;

    address public admin;
    address public pendingAdmin;

    modifier requires(address addr) {
        require(msg.sender == addr, "Not authorized");
        _;
    }

    constructor(address admin_, uint delay_) {
        require(delay_ >= MINIMUM_DELAY, "Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Delay must not exceed maximum delay.");

        admin = admin_;
        delay = delay_;
    }

    receive() external payable {}

    function withdrawFunds(address payable to, uint amount)
        public
        requires(admin)
    {
        to.transfer(amount);
    }

    function setDelay(uint delay_)
        public
        requires(admin)
    {
        require(delay_ >= MINIMUM_DELAY, "Delay must exceed minimum delay.");
        require(delay_ <= MAXIMUM_DELAY, "Delay must not exceed maximum delay.");
        delay = delay_;

        emit NewDelay(delay);
    }

    function acceptAdmin()
        public
        requires(pendingAdmin)
    {
        admin = pendingAdmin;
        pendingAdmin = address(0);

        emit NewAdmin(admin);
    }

    function setPendingAdmin(address pendingAdmin_)
        public
        requires(address(this))
    {
        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta)
        public
        requires(admin)
        returns (bytes32)
    {
        require(eta >= getBlockTimestamp() + delay, "Estimated execution block must satisfy delay.");

        bytes4 sigBytes4 = bytes4(keccak256(bytes(signature)));
        if (sigBytes4.length != 0) {
            require(sigBytes4.length % 4 == 0, "Invalid function signature provided.");
        }

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta)
        requires(admin)
        public
    {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta)
        public
        payable
        nonReentrant
        requires(admin)
        returns (bytes memory)
    {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Transaction hasn't been queued.");
        require(getBlockTimestamp() >= eta, "Transaction hasn't surpassed time lock.");
        require(getBlockTimestamp() <= eta + GRACE_PERIOD, "Transaction is stale.");

        bytes4 expectedSelector = bytes4(keccak256(bytes(signature)));
        bytes4 providedSelector;
        assembly {
            providedSelector := mload(add(data, 32))
        }
        require(providedSelector == expectedSelector, "Provided data does not match the expected function signature.");

        bytes memory callData = data;

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Transaction execution reverted.");
        executedTransactions.push(txHash);
        queuedTransactions[txHash] = false;

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp()
        internal
        view
        returns (uint)
    {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}