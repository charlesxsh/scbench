// File: FxRootTunnel/FxBaseRootTunnel.sol


pragma solidity ^0.8.0;


interface IFxStateSender {
    function sendMessageToChild(address _receiver, bytes calldata _data) external;
}

abstract contract FxBaseRootTunnel {
    

    // keccak256(MessageSent(bytes))
    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    // state sender contract
    IFxStateSender public fxRoot;
    
    // child tunnel contract which receives and sends messages
    address public ChildChain;

    

    constructor(address _fxRoot) {
       
        fxRoot = IFxStateSender(_fxRoot);
    }

    // set ChildChain if not set already
    function setChildChain(address _ChildChain) public virtual {
        require(ChildChain == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        ChildChain = _ChildChain;
    }

    /**
     * @notice Send bytes message to Child Tunnel
     * @param message bytes message that will be sent to Child Tunnel
     * some message examples -
     *   abi.encode(tokenId);
     *   abi.encode(tokenId, tokenMetadata);
     *   abi.encode(messageType, messageData);
     */
    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(ChildChain, message);
    }

    

    /**
     * @notice receive message from  L2 to L1, validated by proof
     * @dev This function verifies if the transaction actually happened on child chain
     *
     * @param inputData RLP encoded data of the reference tx containing following list of fields
     *  0 - headerNumber - Checkpoint header block number containing the reference tx
     *  1 - blockProof - Proof that the block header (in the child chain) is a leaf in the submitted merkle root
     *  2 - blockNumber - Block number containing the reference tx on child chain
     *  3 - blockTime - Reference tx block time
     *  4 - txRoot - Transactions root of block
     *  5 - receiptRoot - Receipts root of block
     *  6 - receipt - Receipt of the reference transaction
     *  7 - receiptProof - Merkle proof of the reference receipt
     *  8 - branchMask - 32 bits denoting the path of receipt in merkle tree
     *  9 - receiptLogIndex - Log Index to read from the receipt
     */
   
    /**
     * @notice Process message received from Child Tunnel
     * @dev function needs to be implemented to handle message as per requirement
     * This is called by onStateReceive function.
     * Since it is called via a system call, any event will not be emitted during its execution.
     * @param message bytes message that was sent from Child Tunnel
     */
    //function _processMessageFromChild(bytes memory message) internal virtual;
}
// File: FxRootTunnel/FxERC20RootTunnel.sol


pragma solidity ^0.8.0;



/**
 * @title FxERC20RootTunnel
 */
contract FxERC20RootTunnel is FxBaseRootTunnel {
    
    // maybe DEPOSIT and MAP_TOKEN can be reduced to bytes4
    bytes32 public constant DEPOSIT = keccak256("DEPOSIT");
    

    
   
    event FxDepositERC20(
        address indexed rootToken,
        address indexed user,
        uint256 amountOrTokenId,
		uint256 depositId
    );

   

    constructor(address _fxRoot) FxBaseRootTunnel(_fxRoot) {
        
    }

    
   

    function deposit(address rootToken, address user, uint256 amountOrTokenId, uint256 depositId) public {
                
        bytes memory message = abi.encode(DEPOSIT, abi.encode(rootToken, user, amountOrTokenId, depositId));
        _sendMessageToChild(message);
        emit FxDepositERC20(rootToken, user, amountOrTokenId, depositId);
    }

   
}