// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract QNTGoldPassNFT {

    uint256 public totalSupply = 6000;
    address Golden;

    constructor(address _delegate) {
        Golden = _delegate;
    }
    
    fallback() external payable {
        (bool success, bytes memory result) = Golden.delegatecall(msg.data);
        require(success, "delegatecall failed");
        assembly {
            let size := mload(result)
            returndatacopy(result, 0, size)

            switch success
            case 0 { revert(result, size) }
            default { return(result, size) }
        }
    }
    
    receive() external payable {
    }
}