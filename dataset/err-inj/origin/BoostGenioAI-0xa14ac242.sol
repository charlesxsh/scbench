// SPDX-License-Identifier: GPL-3.0

/**
*
*   ,d888888b   8888888888  88\\     88    88  ,d888888b,                                             
*   88     88   88          88 \\    88    88  88      88                                     
*   88          88888888    88  \\   88    88  88      88                                      
*   88  d8888   88          88   \\  88    88  88      88  
*   88     88   88          88    \\ 88    88  88      88  
*.  'd88bd888   8888888888  88     \\88    88  `d88888Pb'      
*                                                     
*                                                     
*
* 
**/


pragma solidity ^0.8.18;


interface IERC20 {function transfer(address _to, uint256 _value) external returns (bool);}



contract BoostGenioAI{

    address payable public owner;
    uint256 public balance;
    constructor(){owner = payable(msg.sender);}

    struct  Payment {
        bool is_exists; 
        address myAddress; 
        uint timestamp; 
        uint amount; 
    }

    struct  Overpayment {
        bool is_exists; 
        address myAddress; 
        uint timestamp; 
        uint amount; 
    }

    struct  Underpayment {
        bool is_exists; 
        address myAddress; 
        uint timestamp; 
        uint amount; 
    }


    mapping (address => Payment) public pay;
    mapping (address => Overpayment) public overpay;
    mapping (address => Underpayment) public underpay;

    modifier superGenio() {require(msg.sender == owner, "Transaction not coming from Genio!"); _;}
    receive() payable external superGenio {

        pay[msg.sender].is_exists = true;
        pay[msg.sender].timestamp =  block.timestamp;
        pay[msg.sender].myAddress = msg.sender;
        pay[msg.sender].amount = msg.value  ;

    } 

    function BoostMe() payable external {

        pay[msg.sender].is_exists = true;
        pay[msg.sender].timestamp =  block.timestamp;
        pay[msg.sender].myAddress = msg.sender;
        pay[msg.sender].amount = 5e17  ;
        // require(msg.value < 5 * 10**15, "Must send at least 0.5 MATIC");
        // if(msg.value == 5e16){
        //     // Payent in View
        //     pay[msg.sender].is_exists = true;
        //     pay[msg.sender].timestamp =  block.timestamp;
        //     pay[msg.sender].myAddress = msg.sender;
        //     pay[msg.sender].amount = 5e17 ;

        // }else if(msg.value > 5e17){

        //     // Over Payment
        //     overpay[msg.sender].is_exists = true;
        //     overpay[msg.sender].timestamp =  block.timestamp;
        //     overpay[msg.sender].myAddress = msg.sender;
        //     overpay[msg.sender].amount = msg.value ;

        // }else{

        //     // Under payment
        //     underpay[msg.sender].is_exists = true;
        //     underpay[msg.sender].timestamp =  block.timestamp;
        //     underpay[msg.sender].myAddress = msg.sender;
        //     underpay[msg.sender].amount = msg.value ;
        // }

        

    }



    function GenioBoost(address myaddress) superGenio public {

        pay[myaddress].is_exists = true;
        pay[myaddress].timestamp =  block.timestamp;
        pay[myaddress].myAddress = myaddress;
        pay[myaddress].amount = 5e17 ;

    }


    function withDraw(address payable to) public payable superGenio {
        uint Balance = address(this).balance;
        require(Balance > 0 wei, "Error! No Balance to withdraw"); 
        to.transfer(Balance);
    }



}