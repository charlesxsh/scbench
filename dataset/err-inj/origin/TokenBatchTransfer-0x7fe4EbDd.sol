// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TokenBatchTransfer {
    address[] public recipients;
    uint256 public totalAmount;
    address public owner;

    constructor(address[] memory _recipients, address _owner) {
        require(_recipients.length > 0, "Recipient list is empty");
        require(_owner != address(0), "Invalid owner address");
        
        recipients = _recipients;
        owner = _owner;
    }

    function transferTokens(address token, uint256 amount) public {
        IERC20 tokenContract = IERC20(token);
        require(tokenContract.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(tokenContract.approve(msg.sender, amount), "Approval failed");

        uint256 remainingAmount = amount;
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 transferAmount = getRandomAmount(i, remainingAmount);
            remainingAmount -= transferAmount;

            tokenContract.transfer(recipients[i], transferAmount);
        }
    }

    function getRandomAmount(uint256 index, uint256 remainingAmount) private view returns (uint256) {
        uint256 maxAmount = remainingAmount / (recipients.length - index);
        return (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, index))) % (maxAmount + 1));
    }

    function withdrawToken(address token) public {
        require(msg.sender == owner, "Only the contract owner can call this function");

        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        tokenContract.transfer(owner, balance);
    }

    function withdrawBNB() public {
        require(msg.sender == owner, "Only the contract owner can call this function");

        uint256 balance = address(this).balance;
        require(balance > 0, "No BNB to withdraw");

        payable(owner).transfer(balance);
    }

    function batchTransferBNB(address payable[] memory _recipients, uint256 _amount) public payable {
       require(_recipients.length > 0, "Recipient list is empty");
       require(msg.value >= _recipients.length * _amount, "Insufficient BNB balance");

       for (uint256 i = 0; i < _recipients.length; i++) {
        _recipients[i].transfer(_amount);
        }
    }

    function airdropTokens(address token, address[] memory _recipients, uint256[] memory _amounts) public {
        require(msg.sender == owner, "Only the contract owner can call this function");
        require(_recipients.length == _amounts.length, "Lengths of recipients and amounts arrays do not match");
        require(_recipients.length > 0, "Recipient list is empty");

        IERC20 tokenContract = IERC20(token);
        uint256 totalTransferAmount = 0;
        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Invalid recipient address");
            require(_amounts[i] > 0, "Amount should be greater than 0");

            totalTransferAmount += _amounts[i];
        }

        require(tokenContract.balanceOf(address(this)) >= totalTransferAmount, "Insufficient balance");
        require(tokenContract.approve(msg.sender, totalTransferAmount), "Approval failed");

        for (uint256 i = 0; i < _recipients.length; i++) {
            tokenContract.transfer(_recipients[i], _amounts[i]);
        }
    }
    
    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    receive() external payable {}

}