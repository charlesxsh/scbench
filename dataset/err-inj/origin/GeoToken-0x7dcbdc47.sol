// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GeoToken is IERC20 {
    string public name = "GEOINDEX"; // Token name
    string public symbol = "GEO"; // Token symbol
    uint8 public decimals = 18; // Number of decimals

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    uint256 public override totalSupply = 1_000_000 * (10 ** uint256(decimals)); // Total supply of tokens

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= value, "Insufficient balance");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        require(from != address(0), "Invalid address");
        require(to != address(0), "Invalid address");
        require(balances[from] >= value, "Insufficient balance");
        require(allowed[from][msg.sender] >= value, "Allowance exceeded");

        balances[from] -= value;
        balances[to] += value;
        allowed[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowed[owner][spender];
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }
}