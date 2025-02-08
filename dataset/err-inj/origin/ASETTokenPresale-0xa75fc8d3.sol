/*
 * -----------------------------------------------
 * ASET Token Presale
 * 
 * Description: AssetLink presale contract.
 *
 * Author: Tech Department / AssetLink
 * Version: 1.0.0
 * License: MIT
 * Date: 2023-08-01
 * -----------------------------------------------
 */

 /*
 * ASET Token Presale Contract Summary
 * -----------------------------------
 * 
 * Welcome to the AssetLink Token (ASET) Presale contract!
 * 
 * This contract has been designed with transparency and security in mind. Below is a breakdown of its features:
 * 
 * 1. **Token Basics**:
 *    - Name: AssetLink Token
 *    - Symbol: $ASET
 *    - Decimals: 18 (standard for most tokens)
 *    - Initial Supply: 100 million ASET tokens
 *    - Maximum Supply: 10 billion ASET tokens
 * 
 * 2. **Presale Details**:
 *    - Minimum Purchase: 0.06 ETH
 *    - Maximum Purchase: 5 ETH
 *    - Token Price: Initially set at 0.00015 ETH per ASET (6666 ASET per ETH), but can be adjusted. Price is incremental until presale is over. 
 *    - ETH contributions and corresponding ASET token purchases are recorded.
 * 
 * 3. **Token Distribution**:
 *    - Tokens purchased during the presale will be claimable after the presale ends. This ensures fair distribution and prevents early selling.
 *    - There's a vesting schedule for team tokens with a 3-month cliff and quarterly releases of 25%.
 *    - Please refer to the full list on our website https://assetlink.io#token?utm_source=sc
 *
 * 4. **Safety Measures**:
 *    - The contract includes a "pause" feature for added safety. In the unlikely event of any issues, this feature allows for the pausing of key functions to protect users.
 *    - A reentrancy guard is in place to prevent potential reentrant attacks during fund withdrawals.
 * 
 * 5. **Token Allocation**:
 *    - The initial supply is allocated to the contract owner.
 *    - There's a function to allocate a portion of tokens to a separate vesting/lock contract for the team and advisors. These tokens are locked for 2 years, with a 3-month cliff and quarterly releases of 25% thereafter. This is our statement and commitment to our community and investors.
 * 
 * 6. **Withdrawals**:
 *    - Funds (ETH) collected during the presale can be withdrawn to a designated wallet after the presale.
 * 
 * We are committed to maintaining transparency and security. If you have any questions or require further details, please reach out to the AssetLink team!
 * 
 * Disclaimer: Always make sure to do your own research and consult with professionals before participating in any presale or token purchase.
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ASETTokenPresale {
    // Token properties
    string public constant NAME = "AssetLink Token";
    string public constant SYMBOL = "ASET";
    uint8 public constant DECIMALS = 18;
    uint256 private _totalSupply = 100000000 * (10**18); // Initial supply of 100 million
    uint256 private constant _maxSupply = 10000000000 * (10**18); // Max supply of 10 billion
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    bool private _paused = false;
    event Paused(address indexed account);
    event Unpaused(address indexed account);

    // Presale properties
    address public owner;
    address public withdrawalAddress;
    uint256 public minByWallet = 0.06 ether; // Minimum Ether a wallet can send
    uint256 public maxByWallet = 5 ether; // Maximum Ether a wallet can send
    mapping(address => uint256) public contributions;
    uint256 public rate = 6666; // Tokens per Ether
    mapping(address => uint256) public tokensPurchased;

    // Events
    event FundsReceived(address indexed _from, uint256 _amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundsWithdrawn(address indexed _to, uint256 _amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this");
        _;
    }

    uint256 private unlocked = 1;
    modifier reentrancyGuard() {
        require(unlocked == 1, "Reentrant call");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        owner = msg.sender;

        // Define the vesting contract address for Team & Advisors allocation
        uint256 teamAdvisorsAllocation = (_totalSupply * 10) / 100;

        // Total tokens minus the team & advisors allocation will be assigned to the owner
        uint256 totalAllocation = _totalSupply - teamAdvisorsAllocation;

        _balances[owner] = totalAllocation;

        // Emitting events
        emit Transfer(address(0), owner, totalAllocation);
    }

    function SendTokensToLockContract(address teamAdvisorsLockAddress)
        external
        onlyOwner
    {
        require(
            teamAdvisorsLockAddress != address(0),
            "Lock contract address is not set!"
        );
        uint256 teamAdvisorsAllocation = (_totalSupply * 10) / 100;
        require(
            _balances[owner] >= teamAdvisorsAllocation,
            "Insufficient balance for allocation!"
        );

        _balances[owner] -= teamAdvisorsAllocation;
        _balances[teamAdvisorsLockAddress] += teamAdvisorsAllocation;

        emit Transfer(owner, teamAdvisorsLockAddress, teamAdvisorsAllocation);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Mint to the zero address");

        // Check if minting doesn't exceed the max supply
        require(
            _totalSupply + amount <= _maxSupply,
            "Minting would exceed max supply"
        );

        // Update total supply
        _totalSupply += amount;

        // Add the minted amount to the target address
        _balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external {
        require(
            _balances[msg.sender] >= amount,
            "Insufficient balance to burn"
        );

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    // Token functions
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Contract is not paused");
        _;
    }

    // The contract might be paused in case of migration or upgrade to a better contract if need be.
    // Pausing will help take a better and more effective snapshot of holders.
    function pause() external onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() external view returns (bool) {
        return _paused;
    }

    function transfer(address recipient, uint256 amount)
        external
        whenNotPaused
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) internal whenNotPaused {
        require(_owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    // Presale functions
    receive() external payable whenNotPaused {
        require(
            msg.value >= minByWallet,
            "Sent amount is below the minimum limit"
        );
        require(
            msg.value <= maxByWallet,
            "Sent amount is above the maximum limit"
        );

        contributions[msg.sender] += msg.value;

        uint256 tokensBought = (msg.value * rate) / (10**18); // Calculate tokens based on rate and adjust for decimals
        tokensPurchased[msg.sender] += tokensBought;

        emit FundsReceived(msg.sender, msg.value);
    }

    bool public claimAllowed = false;

    modifier canClaim() {
        require(
            claimAllowed,
            "Claiming is not allowed yet. Please check current presale stage rules."
        );
        _;
    }

    function setClaimAllowed(bool _status) external onlyOwner {
        claimAllowed = _status;
    }

    function claim() external canClaim {
        uint256 etherSent = contributions[msg.sender];
        require(etherSent > 0, "No contribution found for the caller");

        uint256 tokensToClaim = tokensPurchased[msg.sender];
        contributions[msg.sender] = 0; // reset their contribution to prevent re-claiming
        tokensPurchased[msg.sender] = 0; // reset their token amount to prevent re-claiming

        _transfer(owner, msg.sender, tokensToClaim);
    }

    function setRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Rate should be greater than 0");
        rate = newRate;
    }

    function setMinByWallet(uint256 newMin) external onlyOwner {
        minByWallet = newMin;
    }

    function setMaxByWallet(uint256 newMax) external onlyOwner {
        maxByWallet = newMax;
    }

    function setWithdrawalAddress(address _withdrawalAddress)
        external
        onlyOwner
    {
        require(_withdrawalAddress != address(0), "Invalid address");
        withdrawalAddress = _withdrawalAddress;
    }

    function withdraw() external onlyOwner reentrancyGuard {
        require(withdrawalAddress != address(0), "Withdrawal address not set");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available for withdrawal");

        payable(withdrawalAddress).transfer(balance);
        emit FundsWithdrawn(withdrawalAddress, balance);
    }
}