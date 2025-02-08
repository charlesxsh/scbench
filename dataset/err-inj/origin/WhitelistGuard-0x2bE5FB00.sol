// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGuard {
    function checkTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes calldata signatures,
        address msgSender
    ) external;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}

contract WhitelistGuard is IGuard {
    mapping(address => bool) public whitelist;

    constructor(address[] memory _whitelistedAddresses) {
        for (uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            whitelist[_whitelistedAddresses[i]] = true;
        }
    }

    function checkTransaction(
        address to,
        uint256 /*value*/,
        bytes memory /*data*/,
        uint8 operation,
        uint256 /*safeTxGas*/,
        uint256 /*baseGas*/,
        uint256 /*gasPrice*/,
        address /*gasToken*/,
        address /*refundReceiver*/,
        bytes memory /*signatures*/,
        address msgSender
    ) external override {
        require(whitelist[msgSender], "Sender address is not whitelisted");
        require(operation == 0, "Only direct calls are allowed"); // operation 0 is a Call
        require(whitelist[to], "Recipient address is not whitelisted");
    }

    function checkAfterExecution(bytes32 /*txHash*/, bool /*success*/) external override {
        // Not implemented
    }

    // Add an address to the whitelist
    function addToWhitelist(address _address) public {
        whitelist[_address] = true;
    }

    // Remove an address from the whitelist
    function removeFromWhitelist(address _address) public {
        whitelist[_address] = false;
    }
}