// Sources flattened with hardhat v2.17.3 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol@v0.7.6

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// End consumer library.
library Client {
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit and strict = false.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV1)
  }

  // extraArgs will evolve to support new features
  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;
  struct EVMExtraArgsV1 {
    uint256 gasLimit; // ATTENTION!!! MAX GAS LIMIT 4M FOR BETA TESTING
    bool strict; // See strict sequencing details below.
  }

  function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol@v0.7.6

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Application contracts that intend to receive messages from
/// the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message.
  /// If this reverts, any token transfers also revert. The message
  /// will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message
  /// @dev Note ensure you check the msg.sender is the OffRampRouter
  function ccipReceive(Client.Any2EVMMessage calldata message) external;
}


// File @chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/utils/introspection/IERC165.sol@v0.7.6

// Original license: SPDX_License_Identifier: MIT
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


// File @chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol@v0.7.6

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPReceiver is IAny2EVMMessageReceiver, IERC165 {
  address internal immutable i_router;

  constructor(address router) {
    if (router == address(0)) revert InvalidRouter(address(0));
    i_router = router;
  }

  /// @notice IERC165 supports an interfaceId
  /// @param interfaceId The interfaceId to check
  /// @return true if the interfaceId is supported
  function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
    return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  /// @inheritdoc IAny2EVMMessageReceiver
  function ccipReceive(Client.Any2EVMMessage calldata message) external virtual override onlyRouter {
    _ccipReceive(message);
  }

  /// @notice Override this function in your implementation.
  /// @param message Any2EVMMessage
  function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

  /////////////////////////////////////////////////////////////////////
  // Plumbing
  /////////////////////////////////////////////////////////////////////

  /// @notice Return the current router
  /// @return i_router address
  function getRouter() public view returns (address) {
    return address(i_router);
  }

  error InvalidRouter(address router);

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != address(i_router)) revert InvalidRouter(msg.sender);
    _;
  }
}


// File contracts/ccip/interface/ICCIPRateProvider.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ICCIPRateProvider {
    error TransferNotAllow();

    function setRate(uint256 _rate) external;

    function getRate() external view returns (uint256);
}


// File contracts/ccip/Types.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

struct RateInfo {
    address receiver;
    address destination;
}

struct RateMsg {
    address destination;
    uint256 rate;
}


// File contracts/ccip/RateReceiver.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;




contract RateReceiver is CCIPReceiver {
    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        address destination,
        uint256 rate
    );

    bytes32 private lastReceivedMessageId; // Store the last received messageId.
    bytes private lastReceivedData; // Store the last received bytes data.

    constructor(address _router) CCIPReceiver(_router) {}

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        lastReceivedData = any2EvmMessage.data;

        RateMsg memory rateMsg = abi.decode(
            lastReceivedData,
            (RateMsg)
        );
        ICCIPRateProvider(rateMsg.destination).setRate(rateMsg.rate);

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            rateMsg.destination,
            rateMsg.rate
        );
    }

    /// @notice Fetches the details of the last received message.
    /// @return messageId The ID of the last received message.
    /// @return data The last received bytes data.
    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, bytes memory data)
    {
        return (lastReceivedMessageId, lastReceivedData);
    }
}