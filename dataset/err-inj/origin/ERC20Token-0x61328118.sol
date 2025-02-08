// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ERC20Token {
    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(
        uint256 _totalSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(amount <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(amount <= balances[from], "Insufficient balance");
        require(amount <= allowed[from][msg.sender], "Allowance exceeded");

        balances[from] -= amount;
        balances[to] += amount;
        allowed[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
}