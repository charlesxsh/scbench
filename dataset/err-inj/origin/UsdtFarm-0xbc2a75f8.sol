// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12;
interface TokenLike {
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view  returns (uint);
}
interface ExchequerLike {
    function fundPool(address) external returns (uint);
    function getfundPool() external view returns (uint);
}
contract UsdtFarm {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "UsdtFarm/not-authorized");
        _;
    }

    struct UserInfo {
        uint256    amount;   
        int256    rewardDebt;
        uint256    harved;
        uint256[2][]  withdrawList;
        uint256[2][]  harveList;
        uint256[2][]  depositList;
    }

    uint256   public acclpPerShare;
    TokenLike public token = TokenLike(0x79A0842743c7a37a2914D42294FCdF68f33a742c);
    TokenLike public lptoken = TokenLike(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    ExchequerLike public exchequer = ExchequerLike(0x502121753D9acAeF68a4FcB97A6c7beC123bE6D2);

    mapping (address => UserInfo) public userInfo;


    event Deposit( address  indexed  owner,
                   uint256           wad
                  );
    event Harvest( address  indexed  owner,
                   uint256           wad
                  );
    event Withdraw( address  indexed  owner,
                    uint256           wad
                 );


        // --- Math ---
    function add(uint x, int y) internal pure returns (uint z) {
        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }
    function sub(uint x, int y) internal pure returns (uint z) {
        z = x - uint(y);
        require(y <= 0 || z <= x);
        require(y >= 0 || z >= x);
    }
    function mul(uint x, int y) internal pure returns (int z) {
        z = int(x) * y;
        require(int(x) >= 0);
        require(y == 0 || z / y == int(x));
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    
        return c;
      }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "UsdtFarm/SignedSafeMath: subtraction overflow");

        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "UsdtFarm/SignedSafeMath: addition overflow");

        return c;
    }
    function toUInt256(int256 a) internal pure returns (uint256) {
        require(a >= 0, "Integer < 0");
        return uint256(a);
    }
    constructor() {
        wards[msg.sender] = 1;
    }
    function setAddress(address _token,address _lptoken ,address _exchequer) external auth {
        token = TokenLike(_token);
        lptoken = TokenLike(_lptoken); 
        exchequer = ExchequerLike(_exchequer);
    }
    //The pledge LP  
    function deposit(uint _amount) public {
        updateReward();
        lptoken.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfo[msg.sender]; 
        user.amount = add(user.amount,_amount); 
        user.rewardDebt = add(user.rewardDebt,int256(mul(_amount,acclpPerShare) / 1e18));
        uint256[2] memory list = [_amount,block.timestamp];
        user.depositList.push(list); 
        emit Deposit(msg.sender,_amount);     
    }
    function depositAll() public {
        uint _amount = lptoken.balanceOf(msg.sender);
        if (_amount == 0) return;
        deposit(_amount);
    }
    //Update mining data
    function updateReward() internal {
        uint lpSupply = lptoken.balanceOf(address(this));
        if (lpSupply == 0) return;
        uint256 yield = exchequer.fundPool(address(this));
        uint256 lpReward = div(mul(yield,uint(1e18)),lpSupply);
        acclpPerShare = add(acclpPerShare,lpReward);
    }
    //The harvest from mining
    function harvest() public returns (uint256) {
        return harvestForOther(msg.sender);  
    }
    function harvestForOther(address usr) public returns (uint256) {
        updateReward();
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.amount,acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));

        // Effects
        user.rewardDebt = accumulatedlp;

        // Interactions
        if (_pendinglp != 0) {
            token.transfer(usr, _pendinglp);
            user.harved = add(user.harved,_pendinglp);
            uint256[2] memory list = [_pendinglp,block.timestamp];
            user.harveList.push(list);
        } 
        emit Harvest(usr,_pendinglp); 
       return  _pendinglp;    
    }
    //Withdrawal pledge currency
    function withdraw(uint256 _amount) public {
        if(_amount ==0) return;
        updateReward();
        UserInfo storage user = userInfo[msg.sender];
        user.rewardDebt = sub(user.rewardDebt,int(mul(_amount,acclpPerShare) / 1e18));
        user.amount = sub(user.amount,_amount);
        lptoken.transfer(msg.sender, _amount);
        uint256[2] memory list = [_amount,block.timestamp];
        user.withdrawList.push(list);
        emit Withdraw(msg.sender,_amount);     
    }

    function withdrawAll() public {
        UserInfo storage user = userInfo[msg.sender]; 
        uint256 _amount = user.amount;
        if (_amount == 0) return;
        withdraw(_amount);
    }
    function getUserInfo(address usr) public view returns (UserInfo memory) {
       return userInfo[usr];
    }

    //Estimate the harvest
    function beharvest(address usr) public view returns (uint256) {
        uint lpSupply = lptoken.balanceOf(address(this));
        if(lpSupply ==0) return 0;
        uint256 yield = exchequer.getfundPool();
        uint256 lpReward = div(mul(yield,uint(1e18)),lpSupply);
        uint256 _acclpPerShare = add(acclpPerShare,lpReward);
        UserInfo storage user = userInfo[usr];
        int256 accumulatedlp = int(mul(user.amount,_acclpPerShare) / 1e18);
        uint256 _pendinglp = toUInt256(sub(accumulatedlp,user.rewardDebt));
        return _pendinglp;
    }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        TokenLike(asses).transfer(ust, amount);
    }
 }