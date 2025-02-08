// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract StaknetChainStats {
    address public owner;
    mapping(string => string) public total_transactions;
    mapping(string => string) public total_wallets;
    mapping(string => string) public daily_transactions;
    mapping(string => string) public daily_new_wallets;
    mapping(string => string) public chain_tps;
    mapping(string => string) public chain_tvl;
    mapping(string => string) public daily_active_wallets;
    mapping(string => string) public average_txs_per_wallet;





    constructor() {
        owner = msg.sender;
    }

    function set_total_transactions(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        total_transactions[date] = value;
    }
    
    function set_total_wallets(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        total_wallets[date] = value;
    }

    function set_daily_transactions(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        daily_transactions[date] = value;
    }

    function set_daily_new_wallets(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        daily_new_wallets[date] = value;
    }

    function set_chain_tps(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        chain_tps[date] = value;
    }

    function set_chain_tvl(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        chain_tvl[date] = value;
    }

    function set_daily_active_wallets(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        daily_active_wallets[date] = value;
    }

    function set_average_txs_per_wallet(string memory date,string memory value) public {
        require(msg.sender == owner, "Only owner can set data");
        average_txs_per_wallet[date] = value;
    }

    function donate() public payable {}

    function WithdrawAll() public {
        require(msg.sender == owner, "Only the contract owner can withdraw all funds");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available for withdrawal");
        payable(msg.sender).transfer(balance);
    }

    function set_Owner(address new_owner)  public {
        require(msg.sender == owner, "Only the contract owner can change owner");
        owner = new_owner;
    }
}