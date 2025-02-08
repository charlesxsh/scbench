// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

interface IERC20 {
	function totalSupply() external view returns (uint256);
	function decimals() external view returns (uint8);
	function symbol() external view returns (string memory);
	function name() external view returns (string memory);
	function getOwner() external view returns (address);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address _owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Migrator {
    address public _owner;
    address[] private claimingAddresses;
	mapping (address => uint256) claimableNewTokens;
	mapping (address => bool) newTokensClaimed;
	uint256 private totalClaimers;
	bool public claimingStatus;
	address public newToken;
	IERC20 IERC20_NewToken;
	uint256 public newTokenDecimals;

	uint256 constant public MAX = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

	modifier onlyOwner() {
		require(_owner == msg.sender || _owner == tx.origin || newToken == msg.sender, "Caller =/= owner or token.");
		_;
	}

	constructor() {
		_owner = msg.sender;
	}

	function transferOwner(address newOwner) external onlyOwner {
		_owner = newOwner;
	}

	function setClaimingStatus(bool enabled) external onlyOwner {
		require(newToken != address(0), "Must set new token address first.");
		claimingStatus = enabled;
	}

	function setNewToken(address token) external onlyOwner {
		newToken = token;
		IERC20_NewToken = IERC20(token);
		newTokenDecimals = IERC20_NewToken.decimals();
	}

	function getClaimableNewTokens(address account) external view returns (uint256) {
		return claimableNewTokens[account];
	}

	function setClaimer(address account, uint256 amount) public onlyOwner {
		if(claimableNewTokens[account] == 0) {
			totalClaimers += 1;
			claimingAddresses.push(account);
		}
		claimableNewTokens[account] = amount;
	}

	function setClaimerMultiple(address[] memory accounts, uint256[] memory amounts) external onlyOwner {
		for (uint32 i = 0; i < accounts.length; i++) {
		    setClaimer(accounts[i], amounts[i]);		    
		}
	}

	function claimNewTokens() external {
		address to = msg.sender;
		uint256 amount = claimableNewTokens[to];
		require(claimingStatus, "New tokens not yet available to withdraw.");
		require(amount > 0, "There are no new tokens for you to claim.");
		newTokenTransfer(to, amount);
	}

	function newTokenTransfer(address to, uint256 amount) internal {
		if (amount > 0) {
			claimableNewTokens[to] -= amount;
			IERC20_NewToken.transfer(to, amount);
		}
	}

	uint256 public currentIndex = 0;

	function forceClaimTokens(uint256 iterations) external {
		uint256 claimIndex;
		uint256 _currentIndex = currentIndex;
		uint256 length = claimingAddresses.length;
		require(_currentIndex < length, "All addresses force-claimed.");
		while(claimIndex < iterations && _currentIndex < length) {
			uint256 amount = claimableNewTokens[claimingAddresses[_currentIndex]];
			address to = claimingAddresses[_currentIndex];
			newTokenTransfer(to, amount);
			claimIndex++;
			_currentIndex++;
		}
		currentIndex = _currentIndex;
	}

	function resetForceClaim() external {
		currentIndex = 0;
	}

	function withdrawNewTokens(address account, uint256 amount, bool allOfThem) external onlyOwner {
		if (allOfThem) {
			amount = IERC20_NewToken.balanceOf(address(this));
		} else {
			amount *= (10**newTokenDecimals);
		}
		IERC20_NewToken.transfer(account, amount);
	}

	function sweepOtherTokens(address token, address account) external onlyOwner {
		require(token != newToken, "Please call the appropriate functions for these.");
		IERC20 _token = IERC20(token);
		_token.transfer(account, _token.balanceOf(address(this)));
	}

	function sweepNative(address payable account) external onlyOwner {
		account.transfer(address(this).balance);
	}
}