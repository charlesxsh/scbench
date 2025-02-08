// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

pragma experimental ABIEncoderV2;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IMATIC is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

// This contract simply calls multiple targets sequentially, ensuring MATIC balance before and after

contract FlashBotsMultiCall {
    address private immutable owner;
    address private immutable executor;
    // 0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0  // polygon matic address
    IMATIC private constant MATIC = IMATIC(0xE8742F36189Ec749685e529c2166FB498DeD23BE);

    modifier onlyExecutor() {
        require(msg.sender == executor);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _executor) public payable {
        owner = msg.sender;
        executor = _executor;
        if (msg.value > 0) {
            MATIC.deposit{value: msg.value}();
        }
    }

    receive() external payable {
    }

    function uniswapMatic(uint256 _maticAmountToFirstMarket, uint256 _amountToCoinbase, address[] memory _targets, bytes[] memory _payloads) external onlyExecutor payable {
        require (_targets.length == _payloads.length);
        uint256 _maticBalanceBefore = MATIC.balanceOf(address(this));
        MATIC.transfer(_targets[0], _maticAmountToFirstMarket);
        for (uint256 i = 0; i < _targets.length; i++) {
            (bool _success, bytes memory _response) = _targets[i].call(_payloads[i]);
            require(_success); _response;
        }

        uint256 _maticBalanceAfter = MATIC.balanceOf(address(this));
        require(_maticBalanceAfter > _maticBalanceBefore + _amountToCoinbase);
        if (_amountToCoinbase == 0) return;

        uint256 _maticBalance = address(this).balance;
        if (_maticBalance < _amountToCoinbase) {
            MATIC.withdraw(_amountToCoinbase - _maticBalance);
        }
        block.coinbase.transfer(_amountToCoinbase);
    }

    
    function call(address payable _to, uint256 _value, bytes calldata _data) external onlyOwner payable returns (bytes memory) {
        require(_to != address(0));
        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
        require(_success);
        return _result;
    }
}