pragma solidity 0.4.22;

contract ERC20 {
    uint public totalSupply;

    function balanceOf(address _owner) public view returns (uint256);

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint);

    function transfer(address _to, uint _value) public returns (bool ok);

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract IST20 {
    function verifyTransaction(
        address _sender,
        address _reciver
    ) internal returns (bool);

    function lockAccount(address _address) public returns (bool);

    function unlockAccount(address _address) public returns (bool);

    function mint(uint256 _value) public returns (bool);

    function burn(uint256 _value) public returns (bool);
}

contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract JNTR is IST20, ERC20, SafeMath {
    string public constant name = " Jointer Token";
    string public constant symbol = "JNTR";
    uint256 public constant decimals = 18; // decimal places
    uint256 public totalSupply = 1000000000 * 10 ** 18; // tokens per 1 ether
    address public owner;

    struct Account {
        address _address;
        bool _active;
    }

    Account[] allowedAddress;
    mapping(address => uint256) balances;
    mapping(address => uint256) allowedIndex;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        allowedIndex[msg.sender] = 0;
        allowedAddress.push(Account({_address: msg.sender, _active: true}));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function getWallet(
        address _owner
    ) public view returns (address _address, bool _active) {
        uint256 index = allowedIndex[_owner];
        return (allowedAddress[index]._address, allowedAddress[index]._active);
    }

    function setAccount(address _address) public returns (bool) {
        require(msg.sender == owner);
        require(allowedAddress[allowedIndex[_address]]._address != _address);
        uint256 x = allowedAddress.length;
        allowedIndex[_address] = x;
        allowedAddress.push(Account({_address: _address, _active: true}));
        balances[_address] = 0;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function verifyTransaction(
        address _sender,
        address _reciver
    ) internal returns (bool) {
        require(allowedAddress[allowedIndex[_sender]]._address == _sender);
        require(allowedAddress[allowedIndex[_reciver]]._address == _reciver);
        require(allowedAddress[allowedIndex[_sender]]._active == true);
        require(allowedAddress[allowedIndex[_reciver]]._active == true);
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool ok) {
        require(verifyTransaction(msg.sender, _to));
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value);
        senderBalance = safeSub(senderBalance, _value);
        balances[msg.sender] = senderBalance;
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint) {
        return allowed[_owner][_spender];
    }

    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public returns (bool ok) {
        require(verifyTransaction(_from, _to));
        require(_value > 0);
        //Check amount is approved by the owner for spender to spent and owner have enough balances
        require(
            allowed[_from][msg.sender] >= _value && balances[_from] >= _value
        );
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(
            allowed[_from][msg.sender],
            _value
        );
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(verifyTransaction(msg.sender, _spender));
        require(_value > 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function mint(uint256 _value) public returns (bool) {
        require(msg.sender == owner);
        require(_value > 0);
        balances[msg.sender] = safeAdd(balances[msg.sender], _value);
        totalSupply = safeAdd(totalSupply, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);
        require(_value < balances[msg.sender]);
        require(msg.sender == owner);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        totalSupply = safeSub(totalSupply, _value);
        return true;
    }

    function lockAccount(address _address) public returns (bool) {
        require(msg.sender == owner);
        require(allowedAddress[allowedIndex[_address]]._address == _address);
        allowedAddress[allowedIndex[_address]]._active = false;
        return true;
    }

    function unlockAccount(address _address) public returns (bool) {
        require(msg.sender == owner);
        require(allowedAddress[allowedIndex[_address]]._address == _address);
        allowedAddress[allowedIndex[_address]]._active = true;
        return true;
    }

    function reduceToken(
        address _address,
        uint256 _value
    ) public returns (bool) {
        require(msg.sender == owner);
        require(allowedAddress[allowedIndex[_address]]._address == _address);
        uint256 reducerBalance = balances[_address];
        require(reducerBalance >= _value);
        reducerBalance = safeSub(reducerBalance, _value);
        balances[msg.sender] = safeAdd(balances[msg.sender], _value);
        balances[_address] = reducerBalance;
        emit Transfer(_address, msg.sender, _value);
        return true;
    }
}
