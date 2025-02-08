// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract QNTGoldPassTestNFT {

    uint256 public totalSupply = 6000;
    address GoldenTest;

    constructor(address _delegate) {
        GoldenTest = _delegate;
    }
    
    fallback() external payable {
        (bool success, bytes memory result) = GoldenTest.delegatecall(msg.data);
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