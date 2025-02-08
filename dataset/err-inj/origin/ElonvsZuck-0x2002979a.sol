// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ElonvsZuck {
    address public owner;
    uint256 public creationBlock;
    uint256 public constant withdrawalDelay = 175000; 

    constructor() {
        owner = msg.sender;
        creationBlock = block.number;
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() public onlyOwner {
        require(block.number >= creationBlock + withdrawalDelay, "Withdrawal not yet allowed");
        uint256 amount = address(this).balance;
        payable(owner).transfer(amount);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}