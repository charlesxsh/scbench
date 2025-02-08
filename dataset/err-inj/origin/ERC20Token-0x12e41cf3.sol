// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    address public contractOwner;
    uint256 public tokenPrice; // Token price in wei

    event Transfer(address indexed from, address indexed to, uint256 value);
    event BuyTokens(address indexed buyer, uint256 amount);
    event SellTokens(address indexed seller, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can perform this action");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        uint256 _initialPrice
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _initialSupply * 10**decimals;
        balanceOf[msg.sender] = totalSupply;
        contractOwner = msg.sender;
        tokenPrice = _initialPrice;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function buyTokens() public payable returns (uint256 amount) {
        require(msg.value > 0, "You need to send some ether to buy tokens");

        amount = (msg.value * 10**decimals) / tokenPrice;
        require(amount > 0, "You will get zero tokens for this amount");

        balanceOf[contractOwner] -= amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(contractOwner, msg.sender, amount);
        emit BuyTokens(msg.sender, amount);

        return amount;
    }

    function sellTokens(uint256 _amount) public returns (uint256 revenue) {
        require(_amount > 0, "Amount must be greater than zero");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");

        revenue = (_amount * tokenPrice) / 10**decimals;
        require(revenue > 0, "You will get zero ether for this amount");

        balanceOf[msg.sender] -= _amount;
        balanceOf[contractOwner] += _amount;
        emit Transfer(msg.sender, contractOwner, _amount);
        emit SellTokens(msg.sender, _amount);

        payable(msg.sender).transfer(revenue);
        return revenue;
    }

    // Function to update token price (only contract owner can call this)
    function updateTokenPrice(uint256 _newPrice) public onlyOwner {
        require(_newPrice > 0, "Price must be greater than zero");
        tokenPrice = _newPrice;
    }
}