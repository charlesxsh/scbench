//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSendNative {
    function sendFixedAmount(
        address payable[] memory recipients,
        uint256 amount
    ) public payable {
        require(recipients.length > 0, "No recipients provided");
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalRequired = amount * recipients.length;

        require(msg.value >= totalRequired, "Insufficient funds sent");

        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amount);
        }
        
        handleExcess(totalRequired);
    }

    function sendVariableAmounts(
        address payable[] memory recipients,
        uint256[] memory amounts
    ) public payable {
        require(recipients.length > 0, "No recipients provided");
        require(
            recipients.length == amounts.length,
            "Mismatch between recipients and amounts"
        );

        uint256 total = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        require(msg.value >= total, "Insufficient funds sent");

        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amounts[i]);
        }

        handleExcess(total);
    }

    function handleExcess(uint256 totalSent) private {
        uint256 excess = msg.value - totalSent;

        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }
}