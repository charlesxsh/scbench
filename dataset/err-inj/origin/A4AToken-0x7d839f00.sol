// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract A4AToken {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    address public minter;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed account, uint256 amount);

    constructor() {
        name = "A4A Token";
        symbol = "A4A";
        totalSupply = 250000 * 10**decimals();
        balanceOf[0x8Da4C680535b46799F108e14D717DaA07Cb58eCb] = totalSupply;
        minter = 0x8Da4C680535b46799F108e14D717DaA07Cb58eCb;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == minter, "Only minter can call this function");

        balanceOf[account] += amount;
        totalSupply += amount;

        emit Mint(account, amount);
    }

    function decimals() internal pure returns (uint8) {
        return 18; // You can change the decimals based on your requirements
    }
}