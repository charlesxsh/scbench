// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BougieToken {
    string public name = "Bougie"; // Token name
    string public symbol = "BOUGIE"; // Token symbol
    uint8 public decimals = 9; // Number of decimals
   
    uint256 public totalSupply; // Total token supply
    mapping(address => uint256) public balanceOf; // Balance of each address
    mapping(address => mapping(address => uint256)) public allowance; // Transfer permissions
   
    uint256 public taxRate = 2; // Tax rate in percentage
    address public marketingWallet = 0x9D8166Be2cA2066b0C31A986bC4BC1BD5f6c8959; // Marketing wallet
    address public owner; // Contract owner
    bool public contractActive = true; // Contract active
    bool public liquidityLocked = false; // Liquidity locked

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event LiquidityLocked(bool locked);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier liquidityNotLocked() {
        require(!liquidityLocked, "Liquidity is locked");
        _;
    }

    constructor() {
        totalSupply = 100000000000 * 10**uint256(decimals); // 100 billion with 9 decimals
        owner = msg.sender;
       
        // Send 20% of the total supply to the marketing wallet
        uint256 initialSupply = totalSupply * 20 / 100;
        balanceOf[marketingWallet] = initialSupply;
        totalSupply -= initialSupply;
    }

    function calculateTax(uint256 _value) internal view returns (uint256) {
        return (_value * taxRate) / 100;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(contractActive, "The contract is deactivated");

        uint256 taxAmount = calculateTax(_value);
        uint256 transferAmount = _value - taxAmount;

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingWallet] += taxAmount;
       
        emit Transfer(msg.sender, _to, transferAmount);
        emit Transfer(msg.sender, marketingWallet, taxAmount);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Cannot transfer from zero address");
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        require(contractActive, "The contract is deactivated");

        uint256 taxAmount = calculateTax(_value);
        uint256 transferAmount = _value - taxAmount;

        balanceOf[_from] -= _value;
        balanceOf[_to] += transferAmount;
        balanceOf[marketingWallet] += taxAmount;
        allowance[_from][msg.sender] -= _value;
       
        emit Transfer(_from, _to, transferAmount);
        emit Transfer(_from, marketingWallet, taxAmount);
        return true;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner's address cannot be zero");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

function lockLiquidity() public onlyOwner {
        require(!liquidityLocked, "Liquidity is already locked");
        liquidityLocked = true;
        emit LiquidityLocked(true);
    }
}