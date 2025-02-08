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
    ) external view;

    function checkAfterExecution(bytes32 txHash, bool success) external;
}

contract WhitelistGuard is IGuard {
    mapping(address => bool) public whitelist;
    address public owner;

    constructor(address[] memory _whitelistedAddresses) {
        for (uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            whitelist[_whitelistedAddresses[i]] = true;
        }
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
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
    ) external view override {
        require(whitelist[msgSender], "Sender address is not whitelisted");
        require(operation == 0, "Only direct calls are allowed"); // operation 0 is a Call
        require(whitelist[to], "Recipient address is not whitelisted");
    }

    function checkAfterExecution(bytes32 /*txHash*/, bool /*success*/) external override {
        // Not implemented
    }

    function addAddress(address _address) external onlyOwner {
        whitelist[_address] = true;
    }

    function removeAddress(address _address) external onlyOwner {
        whitelist[_address] = false;
    }
}
//Created by Michael Kartavchenko for Capestone project
//15.09.2023