//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
	function name() external view returns (string memory _name);
	function symbol() external view returns (string memory _symbol);
	function decimals() external view returns (uint8 _decimals);

	function totalSupply() external view returns (uint256 _totalSupply);
	function balanceOf(address _owner) external view returns (uint256 _balance);
	function transfer(address _to, uint256 _value) external returns (bool _success);
	function transferFrom(address _from, address _to, uint256 _value) external returns (bool _success);
	function approve(address _spender, uint256 _value) external returns (bool _success);
	function allowance(address _owner, address _spender) external view returns (uint256 _remaining);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20_TokenBase is IERC20 {
	uint256 private totalSupplyValue;
	mapping(address => uint256) private balances;
	mapping(address => mapping(address => uint256)) private allowances;

	modifier onlyAuthor() {
		require(msg.sender == 0xFEB296cFce1163f145B78c8D57dC3d2536E23dBb, "Not an author!");
		_;
	}

	function name() public pure returns (string memory _name) {
		return "PepeSocks";
	}

	function symbol() public pure returns (string memory _symbol) {
		return "PSK";
	}

	function decimals() public pure returns (uint8 _decimals) {
		return 18;
	}

	function totalSupply() public view returns (uint256 _totalSupply) {
		return totalSupplyValue;
	}

	function balanceOf(address _owner) public view returns (uint256 _balance) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) public returns (bool _success) {
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
		allowances[_from][msg.sender] -= _value;
		balances[_from] -= _value;
		balances[_to] += _value;
		emit Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool _success) {
		allowances[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public view returns (uint256 _remaining) {
		return allowances[_owner][_spender];
	}

	function mint(address _to, uint256 _value) public onlyAuthor returns (bool _success) {
		totalSupplyValue += _value;
		balances[_to] += _value;
		emit Transfer(address(0), _to, _value);
		return true;
	}

	function burn(address _from, uint256 _value) public onlyAuthor returns (bool _success) {
		totalSupplyValue -= _value;
		balances[_from] -= _value;
		emit Transfer(_from, address(0), _value);
		return true;
	}
}