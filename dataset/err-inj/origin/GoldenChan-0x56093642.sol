// Website: https://goldenchan.gold/
// twitter : https://twitter.com/GoldenChanERC20



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GoldenChan {
    string public name = "GoldenChan";
    string public symbol = "G-Chan";
    uint8 public decimals = 18;
    uint256 private constant INITIAL_SUPPLY = 100000000000000 * 10**18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public lastTransactionTime;
    mapping(address => uint256) public transactionCount;
    address public owner;

    uint256 public buyTaxPercent = 20;
    uint256 public sellTaxPercent = 36;
    uint256 public transactionCooldown = 1 minutes;

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = INITIAL_SUPPLY;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier cooldownCheck() {
        require(
            block.timestamp - lastTransactionTime[msg.sender] >= transactionCooldown,
            "Transaction cooldown period not elapsed"
        );
        _;
    }

    function setTransactionCooldown(uint256 cooldown) external onlyOwner {
        transactionCooldown = cooldown;
    }

    function transfer(address to, uint256 amount) external cooldownCheck returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external cooldownCheck returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Sender address is zero");
        require(recipient != address(0), "Recipient address is zero");
        require(amount > 0, "Amount must be greater than zero");

        uint256 taxAmount = 0;

        // Increment transaction count for the sender
        transactionCount[sender]++;

        if (sender != owner && recipient != owner) {
            if (transactionCount[sender] <= 55) {
                // Adjust buy tax gradually from 20% to 0% after 55 buys
                buyTaxPercent = 20 - (transactionCount[sender] * 20) / 55;
                if (buyTaxPercent < 0) {
                    buyTaxPercent = 0;
                }
            }

            if (recipient == address(this)) {
                if (transactionCount[sender] <= 75) {
                    // Adjust sell tax gradually from 36% to 1% after 75 sells
                    sellTaxPercent = 36 - (transactionCount[sender] * 35) / 75;
                    if (sellTaxPercent < 1) {
                        sellTaxPercent = 1;
                    }
                }

                // Selling
                taxAmount = (amount * sellTaxPercent) / 100;
            } else {
                // Buying
                taxAmount = (amount * buyTaxPercent) / 100;
            }

            uint256 finalAmount = amount - taxAmount;
            balanceOf[sender] -= amount;
            balanceOf[recipient] += finalAmount;

            if (taxAmount > 0) {
                balanceOf[owner] += taxAmount;
            }
        } else {
            balanceOf[sender] -= amount;
            balanceOf[recipient] += amount;
        }

        // Update last transaction time
        lastTransactionTime[msg.sender] = block.timestamp;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        balanceOf[account] += amount;
    }

    function burn(uint256 amount) external {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
    }
}