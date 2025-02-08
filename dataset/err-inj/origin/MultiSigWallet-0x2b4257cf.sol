// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract MultiSigWallet {

    // 存钱 记录
    event Deposit_log(address indexed sender, uint amount, uint balance);

    // 交易 记录
    event SubmitTransaction_log(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data,
        uint timestamp
    );

    // 确认交易 记录
    event ConfirmTransaction_log(address indexed owner, uint indexed txIndex);

    // 执行交易 记录
    event ExecuteTransaction_log(address indexed owner, uint indexed txIndex);

    // 多签成员
    address[] public owners;
    mapping(address => bool) public isOwner;

    // 交易多签通过 人数
    uint public numConfirmationsRequired;

    // 交易数据
    struct Transaction {
        address to;
        uint value;
        bytes data;
        uint timestamp;
        bool executed;
        uint numConfirmations;
    }

    // 每笔交易中 每个多签者确认情况
    mapping(uint => mapping(address => bool)) public isConfirmed;

    // 全部交易数据
    Transaction[] public transactions;

    // 只有签名者才能调用函数
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    // 通过序号判断交易是否存在
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    // 交易结束的不执行
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    // 避免同一签名者重复确认交易
    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    // 初始化合约,设置签名者和权重
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        // 添加签名者
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique"); // 确保签名者 不重复

            isOwner[owner] = true;
            owners.push(owner);
        }

        numConfirmationsRequired = _numConfirmationsRequired;
    }

    // 实现 receive 函数, 可接受 ETH
    receive() external payable {
        emit Deposit_log(msg.sender, msg.value, address(this).balance);
    }

    //未找到方法时
    fallback() external payable {
        revert("error func");
    }

    // 提交交易
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        // 获取序号
        uint txIndex = transactions.length;

        // 获取时间戳
        uint _timestamp = block.timestamp;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                timestamp: _timestamp,
                executed: false,
                numConfirmations: 1
            })
        );

        // 默认提交交易者确认交易
        isConfirmed[txIndex][msg.sender] = true;

        // 记录交易信息
        emit SubmitTransaction_log(msg.sender, txIndex, _to, _value, _data, _timestamp);

        // 记录确认交易者
        emit ConfirmTransaction_log(msg.sender, txIndex);

    }

    // 确认交易
    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        // 获取当前时间戳
        uint now_timestamp = block.timestamp;

        uint wait_time = 60 minutes * 24;

        // 未超时的投票才有效
        if (now_timestamp - transaction.timestamp <= wait_time) {
            transaction.numConfirmations += 1;
            isConfirmed[_txIndex][msg.sender] = true;
            emit ConfirmTransaction_log(msg.sender, _txIndex);
        } else {
            transaction.executed = true;
        }

    }

    // 执行交易
    function executeTransaction(uint _txIndex)
        public
        txExists(_txIndex)
        notExecuted(_txIndex)
    {

        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction_log(msg.sender, _txIndex);

    }

    // 获得多签者
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    // 获得交易数量
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

}