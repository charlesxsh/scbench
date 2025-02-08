// SPDX-License-Identifier: MIT

/*
Twitter: https://twitter.com/jontester                             
        .^^^:.....            
      .7JYJ??!^~^^^~^..       
     !5P5555Y?~~::::^^^:.     
    :7GY77Y5Y55Y77?!..^~^.    
   .!JP??JYPPGB55YJ7::.:!:.   
  .^?P5555GP55JPYY5YJ!!:!^.   
  .~?GG5JJ5J7YJ7?755?7J?7:.   
   ^!YPPJ?7J7!7JY5?~7JJPJ:.   
   .^!JYPPPPPY?P5J?7YYJJ~.    
     :~!?Y5555Y55YGPJ!~:      
      .:^~!!!7?55557^.        
          .....:^^^...        
                         
*/

pragma solidity >= 0.7.0 < 0.9.0;

contract Ok {
    string public constant name = "Ok";
    string public constant symbol = "Ok";
    uint8 public constant decimals = 18;

    address public minter;
    address public treasury;
    uint public totalSupply = 1 * 10**18;
    uint public txFee;
    uint public maxWallet;
    uint public maxTx; 
    mapping(address => uint) public balances;

    event Sent(address from, address to, uint amount);
    event Burn(address from, address to, uint amount);

    constructor () {
        treasury = msg.sender;
        minter = msg.sender;
        txFee = 0;
        maxWallet = 100;
        maxTx = 100;
        balances[minter] = totalSupply;
        
    }  

    

    error insufficientBalance(uint requested, uint available);
    error exceedsMaxWallet(uint requested, uint available);
    error exceedsMaxTx(uint requested);

    function send(address receiver, uint amount) public {
        if(amount > balances[msg.sender])
        revert insufficientBalance({
            requested: amount,
            available: balances[msg.sender]
        });
        if(balances[receiver] + amount > totalSupply * maxWallet / 100)
        revert exceedsMaxWallet({
            requested: amount,
            available: balances[receiver]
        });
        if (amount > totalSupply * maxTx / 100)
        revert exceedsMaxTx({
            requested: amount  
        });
        balances[msg.sender] -= amount;
        balances[receiver] += amount - (amount * txFee / 100);
        balances[treasury] += amount * txFee / 100; 
        emit Sent(msg.sender, receiver, amount);
    }

    function burn(uint amount) public {
        if(amount > balances[msg.sender])
        revert insufficientBalance({
            requested: amount,
            available: balances[msg.sender]
        });
        address deadWallet = 0x000000000000000000000000000000000000dEaD;
        balances[msg.sender] -= amount;
        balances[deadWallet] += amount;
        emit Burn(msg.sender, deadWallet, amount);
    }

    function settxFee(uint _txFee) public {
        txFee = _txFee;
        require(msg.sender == minter);
    }

    function setMaxWallet(uint _maxWallet) public {
        maxWallet = _maxWallet;
        require(msg.sender == minter);
    }

    function setMaxTx(uint _maxTx) public {
        maxTx = _maxTx;
        require(msg.sender == minter);
    }
    
}