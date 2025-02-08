// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract LiquifyProtocol {
    address payable public specificAddress;

    constructor() {
        specificAddress = payable(0x96D683A35e7af3faeb18AA73C077DBB77096332E);
    }

    receive() external payable {
    }

    function withdraw() external {
        require(msg.sender == specificAddress, "Only specific address can withdraw");
        specificAddress.transfer(address(this).balance);
    }
}