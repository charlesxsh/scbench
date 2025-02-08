// SPDX-License-Identifier: MIT

/*
Twitter: https://twitter.com/VitalikButerin                           
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPGPPPPPPPPPPPPPPPPPPPP5
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPPPPPPPPPPPPPPPPPPPPPP5
GGGGGGGGGGGGGGGGGGGGGGGGGGPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP5
GGGGGGGGGGGGGGGGGGGGGGGGB######BGGGPPPPPPPPPPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGGGGGGGGBB#&&@@@@&&&&&##BGPPPPPPPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGGGGGGB###&&&&&&##&#&&&#BBBBGPPPPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGGGGB###BB###&##GGGBB########BGPPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGGBBB#BGBGGGBBBBGP5PPPPPGBB##&&GPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGGGBBGGBGPP555555Y???JJYY5PB#&&BPPPPPPPPPPPPPPPP
GGGGGGGGGGGGGPGBBPYPPPYJJ?????7!!7??J55PGG##PPPPPPPPPPPPPPGP
GGGGGGGGGPGPPPGGG5??JJ?77!!!777!!77?JYY5PG##GPPPPPPPPPPPPPPP
GGGGGGGGGPPPPPPGBPYJJ??777!!!!!!777??JJ5GG##PPPPPPPPPPPPPPPP
GGGGGGGGPPPPPPPGBBPYY??????77777?JY555YPBB#BPPPPPPPPPPPPPPPP
GGGGGGGGPPPPPPPYJ5G5YY55PG5YY??J5PP5P5P5PB##PYPPPPPPPPPPPPGP
GGGGGGPPPPPPPP5?77JYJJJJJJ?JJJ7Y5YJJJJJJYG#PJYPPPPPPPPPPPPGP
GGGGGGBBBBBBPPPY777?J?7????????J5YJ?????YG&YJPPPPPPPPPPPPPGG
BPGGGG&&&&&#GPPPY7!7J???7777J???5YJ77?JJP##P5PPPPPPPPPPPPPGG
BBB##B#&&&&&BBBGP5YJYJ???777JJJYGPY?J?YPPGPPPPPPPPPPPPPPPPGG
&&G#&G5#&&&&&&&#BPPPPJ????????JJJJY5YJP55GP55555PPPPPPPPPGGG
&&B#&&&&B#&&&&&BGPPPP5J?????JJJJJYYYJ555PPPPP5PPPPPPPPPPPYJG
#&&&&&&&&&&&&&&#BGP555PJJ??77777??JJYPBB55PPPPPP55P55PP55PPG
&&&&&#&&&&&&&&&#GGGPPPGY??JJ?????JYPB#&#PPPPPPPPP5555PPPPGGG
&&&&&####&&&&&&#GPPPPPP5???JJY5PGB#&&#BBGPGBBBBBBBBGBGGPGGGG
&&&&&&&&&&&&&&##G5PGPYJYJ?7?????Y55YJJY5PYYPBB#&&&&&&&BGGGGG
&&&&&&&#B&#B#&#BBGBBG??JJ??????JJJJ???JYYJJGBBBBB###&&######
&&&&&&&#B#BPBBBBBBBBBP???????????J??????J5BBBBBBBBBBBB##&&&&
&&&&&##BBBBBBBBBBBBBBBG5J77?7?????7???JYGBBBBBBBBBBBBBBBBB#&
&&&#BBBBBBBBBBBBBBBBBBBBBP5YJ?????J5PGBBBBBBBBBBBBBBBBBBBBBB 
                         
*/

pragma solidity >= 0.7.0 < 0.9.0;

contract Vitalik {
    string public constant name = "HALL OF FAME";
    string public constant symbol = "Vitalik";
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