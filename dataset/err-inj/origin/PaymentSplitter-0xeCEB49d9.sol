// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract PaymentSplitter {
    address payable owner;
    address[] receivers;
    uint[] percentages;

    constructor() {
        owner = payable(msg.sender);
        receivers = [0xa0b78F179D02d608C312e1D4B9B5019926Fa4b4a, 0xdE32Ea761634431206eE3F7Af1667512c87b4ff5, 0xB5abb449d6109f4E736FAFf767b5D2C474540472, 0xc44EbA343D7aE54FbfC85Ba04ceCA934c03A02f3, 0xAa5372622a28296117a68c42B17463f71f7536dD, 0x4F5d90d666ED674Baa2996E98a0C3C2eC4A2aC50, 0x3E6452400eb1fA55aA4b20645bd2b4Bc80A775E2, 0x366bd6683f7369011829Ed2C77F067D63d397e7C, 0x3F89EBF926101FA777d7574afFf2202c7c1614D5, 0x1Fad82e1bA7ABFFebBBbf02ee5a7a35eF79b7BFa];
        percentages = [5, 5, 5, 5, 5, 5, 5, 5, 20, 40];
    }

    receive() external payable {

    }
    function distribute() external {
            require(address(this).balance/1e18>=1000, "not enough balance");
            payable(receivers[0]).transfer((address(this).balance * percentages[0])/100);
            payable(receivers[1]).transfer((address(this).balance * percentages[1])/100);
            payable(receivers[2]).transfer((address(this).balance * percentages[2])/100);
            payable(receivers[3]).transfer((address(this).balance * percentages[3])/100);
            payable(receivers[4]).transfer((address(this).balance * percentages[4])/100);
            payable(receivers[5]).transfer((address(this).balance * percentages[5])/100);
            payable(receivers[6]).transfer((address(this).balance * percentages[6])/100);
            payable(receivers[7]).transfer((address(this).balance * percentages[7])/100);
            payable(receivers[8]).transfer((address(this).balance * percentages[8])/100);
            payable(receivers[9]).transfer((address(this).balance * percentages[9])/100);
    }

    function setReceivers(address[] memory newReceivers) public {
        require(msg.sender == owner, "Only the contract owner can modify the receivers");
        receivers = newReceivers;
    }

    function setPercentages(uint[] memory newPercentages) public {
        require(msg.sender == owner, "Only the contract owner can modify the percentages");
        percentages = newPercentages;
    }
    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getReceivers() public view returns (address payable[] memory) {
        uint length = receivers.length;
        address payable[] memory result = new address payable[](length);

        for (uint i = 0; i < length; i++) {
            result[i] = payable(receivers[i]);
        }

        return result;
    }
    function withdraw() external {
        require(msg.sender == owner, "Only the contract owner can withdraw the balance.");
        payable(owner).transfer(address(this).balance);
    }

}