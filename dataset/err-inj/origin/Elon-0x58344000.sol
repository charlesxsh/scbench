// SPDX-License-Identifier: MIT

/*
Twitter: https://twitter.com/elonmusk                          
~~~~!!!77?J5PBBBB#####BGGBBBBBGBBBGPY?77?YGB###&&&@G^^:^^~~7
~~~!7??J5GBB##B####BBBGBBB#####&&&&&&&B5?7?5GBBGGPPB!::::^~~
~~~~~!!?J5G#&######BB#######BBBBBB##&&&&#57?YP5YY?5#?^::::^~
!~~~~~~~~~!JP#&###BBBGGP5YJ?7777??JYGB##&#GYY5YJ5B#&J^^^^^^~
J7!~~~^^^^^~!?PB##B5J??7!~~~~~~!777??YGBBBB5YY5P&&#&P~~~~~~!
BP?!!~~~^^^^^~!Y#BY777!~~~~~~~~!!777?J5GGBBGYJYG&&&&#Y?????7
B#BY7!~~~~^^^~~7BG??77!~~~~~~~~~!!77?JY5GBBGJJ5PB&&&&GJYYYYJ
G###GJ7!~~~~~^~~GP?777!~~~~~~~7JJJJJ???JGBB57YYJYB&&&BY55YYY
GB####PJ7!!~~~~~J5JJJYYJ?7!7YPBBBB##G5GGBB5JYJ?7?YG&&BY5555Y
GB#####BGY7!!!!~~JG##&##&B?7B&&&&&&&&PYY55YJY?777??YPGJJ5555
GB####BB###P?!!!!5@&&&&&@#J~?G#&&&&&BYJYYYYJJ7!!~~^^^~!JY555
B#####B###@&#GJ7!~5#&&&&#P7^!JJJJJ?J?JJJYY?J?^::..:.:^!7JY55
##&###B######&&B5?!J55Y?7?J7?Y?7~^^!?JJJYYJJJ^:.....:~!7?Y5P
#&&##BB#B###&&&&&#GYJ?7!!77!!!777!!!7JJJJ55YYJYG57^:.~777?J5
#&&&#B#####&&&&&&&&#Y??77?J?777?J?7!7??JJ5YJJ5####BG5YYJ???Y
#####B###&&&&&&&&&&&GJ??7??777!7777!7?J5P5J?P&##BB####BBBG55
####BBB##&&&&&&&&&&&&GYJ??7!~~~!7!7?Y5GG5YJJ##BBBBBBBBBBBBBB
5J5BBBB#&&#######&&#B#BBPYJ7!7?JYYPGGG5YYJJG&##BBBBBBBBBBBBB
5Y555PPGBB######B5?7P#&&&&##BPGBBBGPP5YYYJP&##BBBBBBBBBBBBB#
PPP5555555PGB##5^ ?#&#&&&&&&&BP555YYJJ?J?5#&#BBBBBBBBBBB#BBB
PPPP55555555PGB^ !#&#&&&&&&&&&&G55YY?777J###BBBBBB##BB#####B
PPPPP555555P5PJ.!#&##&&&&&&&&&&G?YYYJ?7J###BBBBB###BBBBBB###
PPPPPP55555PP57^B&&#&&&&&&&&&&&#?7?7??J####BBB##############
PPPPPPPPPPPPPPJ5&&&#&&&&&&&&&&&&B7777?G###BBB####BB#########
PPPPPPPPPPPPGPB&&&&&&&&&&&&&&&&#&BJ77Y&##BBB###BB###########
PPPPPPPPPPPGPP#&&&&&&&##&&&&&&&&#&&PY#&##BB##B##############
5PPPPPPPPPPGPG&&&&&&&&&&&&&&&&&&#&&&&&&#B###################
7?YPPPPPPPPGPB&&&&&&&&&&&&&&&&&&&&&&&&&##&&#################
                         
*/

pragma solidity >= 0.7.0 < 0.9.0;

contract Elon {
    string public constant name = "HALL OF FAME";
    string public constant symbol = "Elon";
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