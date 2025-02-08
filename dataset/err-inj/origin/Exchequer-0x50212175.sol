// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;
interface TokenLike {
    function transfer(address,uint) external;
    function balanceOf(address) external view returns (uint256);
}
contract Exchequer {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Exchequer/not-authorized");
        _;
    }
    
    TokenLike      public NEU = TokenLike(0x79A0842743c7a37a2914D42294FCdF68f33a742c);
    uint256[]      public rates = [5000,1000,2000,2000];
    uint256        public lpAmount;
    uint256        public vipAmount;
    uint256        public operationAmount;
    uint256        public fundAmount;
    address        public lpPoolAddress;
    address        public vipPoolAddress;
    address        public fundAddress;

    constructor() {
        wards[msg.sender] = 1;
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }

    function setAddress(uint what,address ust) external auth{
       if(what ==1) NEU = TokenLike(ust);
       if(what ==2) lpPoolAddress = ust;
       if(what ==3) vipPoolAddress = ust;
       if(what ==4) fundAddress = ust;
	}
    function setArray(uint[] memory data) external auth{
       rates = data;
	}
    function lpPool(address usr) public returns (uint256 wad){
        require(msg.sender == lpPoolAddress, "Exchequer/lp-not-authorized");
        wad = getlpPool();
        if (wad >0) {
            lpAmount = add(lpAmount,wad);
            NEU.transfer(usr,wad); 
        }
    }

    function vipPool(address usr) public returns (uint256 wad){
        require(msg.sender == vipPoolAddress, "Exchequer/vip-not-authorized");
        wad = getvipPool();
        if (wad >0) {
            vipAmount = add(vipAmount,wad);
            NEU.transfer(usr,wad);            
        }
    }

    function operationPool(address usr) public auth returns (uint256 wad){
        wad = getoperationPool();
        if (wad >0) {
            operationAmount = add(operationAmount,wad);
            NEU.transfer(usr,wad);       
        }
    }

    function fundPool(address usr) public returns (uint256 wad){
        require(msg.sender == fundAddress, "Exchequer/fund-not-authorized");
        wad = getfundPool();
        if (wad >0) {
            fundAmount = add(fundAmount,wad);
            NEU.transfer(usr,wad); 
        }     
    }

   //Enquire the Treasury's accumulated total revenue
    function getTotal() public  view returns (uint256 total){
        total = NEU.balanceOf(address(this)) + lpAmount + vipAmount + operationAmount + fundAmount;  
    }

    //Query the residual revenue of the LP pool
    function getlpPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*rates[0]/10000,lpAmount);
    }

    //Query the residual revenue of the integral pool
    function getvipPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*rates[1]/10000,vipAmount);
    }

    //Query residual revenue of operating expenses
    function getoperationPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*rates[2]/10000,operationAmount);
    }

    //Query fund pool residual returns
    function getfundPool() public view returns (uint256 wad){
        uint256 total = getTotal();
        wad = sub(total*rates[3]/10000,fundAmount);    
    }
 }