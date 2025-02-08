// SPDX-License-Identifier: MIT

/**

Website: https://cryptowat.ch/
Twitter: https://twitter.com/cryptowat_ch

**/

pragma solidity ^0.8.0;

contract CWATCH {
    string public constant name = "CWATCH Token";
    string public constant symbol = "CWATCH";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1e9 * 10**uint(decimals);
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function batchTransfer(address[] memory recipients, uint256[] memory values) public returns (bool success) {
        require(recipients.length == values.length, "Recipients and values array length mismatch");
        for (uint i = 0; i < recipients.length; i++) {
            transfer(recipients[i], values[i]);
        }
        return true;
    }
}