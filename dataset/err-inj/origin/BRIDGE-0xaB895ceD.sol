// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
// Import ERC20
//solidity 0.8.5
//evm default
//enable optimization 200 false
//ADDRESS 0x6dAFc0e1Fc4D85c8686547a51e3E2Af03F5c2792
//polygon address 0xaB895ceD581B86e8f9783AB17f147217E015332D
interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
contract BRIDGE  {
    event  Deposit(address indexed dst, uint wad);
    event  Eventwithdraw(string  hash,uint amount,address reciever);
    event  ERC20transfer(string  hash,address erc20, address _recipient, uint256 _amount);
    mapping (string => bool)   public  allreadyWithdraw;
    address public Owner;
    mapping (string => bool)  public  maintained;
    constructor()  {
        Owner = msg.sender;
    }
        receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    modifier onlyOwner() {
        require(
            Owner == msg.sender,
            "only the owner can trigger this method!"
        );
        _;
    }
    function balance(address erc20) public view returns (uint256 r){
     return IERC20(erc20).balanceOf(address(this));
    }
    function erc20transfer(string memory hash,address erc20, address _recipient, uint256 _amount)
        public
        virtual
        onlyOwner
    {

        require(!maintained[hash], "Already maintained");
        maintained[hash]=true;
       if( !IERC20(erc20).transfer(_recipient, _amount)){
           revert("ERC20 transfererr ");
       }
        emit  ERC20transfer(  hash, erc20,  _recipient,  _amount);
       

    }
    function withdraw(string memory hash,uint amount,address reciever) public virtual onlyOwner {
      require(!allreadyWithdraw[hash], "Already withdrawed");
        allreadyWithdraw[hash]=true;
        payable(reciever).transfer(amount);
        emit Eventwithdraw(  hash, amount, reciever);
    }

   

}