// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
interface TokenLike {
    function approve(address,uint) external;
    function transfer(address,uint) external;
}
contract Vault  {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Vault/not-authorized");
        _;
    }

    constructor(){
        wards[msg.sender] = 1;
    }
    receive() external payable {
    }
    function approve(address _asset,address _contract, uint256 _wad) public auth {
        TokenLike(_asset).approve(_contract,_wad);
    }
    function transfer(address _asset,address _usr, uint256 _wad) public auth{
        TokenLike(_asset).transfer(_usr,_wad);
    }
    function withdrawBNB(uint256 wad, address payable usr) public auth returns (bool) {
        usr.transfer(wad);
        return true;
    }
 }