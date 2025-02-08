// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDeposit {
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract BatchDeposit {
    address public owner;
    IDeposit public depositContract;
    bytes public withdrawalCredentials;

    constructor(address _depositContract, bytes memory _withdrawalCredentials) {
        owner = msg.sender;
        depositContract = IDeposit(_depositContract);
        withdrawalCredentials = _withdrawalCredentials;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function batchDeposit(
        bytes[] calldata pubkeys,
        bytes[] calldata signatures,
        bytes32[] calldata deposit_data_roots
    ) external payable {
        require(
            pubkeys.length == signatures.length &&
                pubkeys.length == deposit_data_roots.length,
            "Input arrays length mismatch"
        );

        uint256 totalDeposits = pubkeys.length;

        for (uint256 i = 0; i < totalDeposits; i++) {
            depositContract.deposit{value: 32 ether}(
                pubkeys[i],
                withdrawalCredentials,
                signatures[i],
                deposit_data_roots[i]
            );
        }
    }

    function setWithdrawalCredentials(
        bytes memory _withdrawalCredentials
    ) external onlyOwner {
        withdrawalCredentials = _withdrawalCredentials;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}