// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

// File: contracts/ERC20/SPM_contract.sol

contract SODO_ERC20 {
    using SafeMath for uint256;

    string public name;
    uint8 public decimals; 
    string public symbol;
    uint256 public totalSupply;

    bool public initialized;

    address public owner; // Declare the owner variable

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER_ALLOWED");
        _;
    }

    modifier validTrade(uint256 amount) {
        require(amount >= 1, "MINIMUM_TRADE_1_UNIT");
        _;
    }

    function init(
        address _creator,
        uint256 _totalSupply,
        string memory _name,
        string memory _symbol
    ) public {
        require(!initialized, "TOKEN_INITIALIZED");
        initialized = true;
        totalSupply = _totalSupply; // Set initial supply to 900
        balances[_creator] = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = 6; // Set decimals to 0
        owner = _creator;
        emit Transfer(address(0), _creator, _totalSupply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        totalSupply = totalSupply.add(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(address(0), to, amount);
    }


    function transfer(address to, uint256 amount) public validTrade(amount) returns (bool) {
        require(to != address(0), "TO_ADDRESS_IS_EMPTY");
        require(amount <= balances[msg.sender], "BALANCE_NOT_ENOUGH");
        require(amount % 1 == 0, "AMOUNT_MUST_BE_WHOLE_NUMBER");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public validTrade(amount) returns (bool) {
        require(to != address(0), "TO_ADDRESS_IS_EMPTY");
        require(amount <= balances[from], "BALANCE_NOT_ENOUGH");
        require(amount <= allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");
        require(amount % 1 == 0, "AMOUNT_MUST_BE_WHOLE_NUMBER");

        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        emit Transfer(from, to, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address ownerAddress, address spenderAddress) public view returns (uint256) {
        return allowed[ownerAddress][spenderAddress];
    }

    function burn(uint256 amount) public onlyOwner {
        require(amount <= balances[msg.sender], "BALANCE_NOT_ENOUGH");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);

        emit Transfer(msg.sender, address(0), amount);
    }

    function issue(uint256 amount) public onlyOwner {
        totalSupply = totalSupply.add(amount);
        balances[owner] = balances[owner].add(amount);
        emit Transfer(address(0), owner, amount);
    }

}