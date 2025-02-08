// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BatchTransfer {
    function batchTransfer(address[] memory recipients, uint256[] memory amounts, address tokenAddress) public {
        require(recipients.length == amounts.length, "Invalid input");

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = tokenAddress.call(abi.encodeWithSignature("transfer(address,uint256)", recipients[i], amounts[i]));
            require(success, "Transfer failed");
        }
    }
}