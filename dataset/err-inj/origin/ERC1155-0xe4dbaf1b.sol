// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC1155 {
    mapping(uint256 => mapping(address => uint256)) private balances;
    mapping(uint256 => string) private tokenURIs;

    address public owner;
    uint256 public constant TOKEN_ID = 0;
    uint256 public constant INITIAL_SUPPLY = 100000;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[TOKEN_ID][msg.sender] = INITIAL_SUPPLY;
    }

    function balanceOf(address account, uint256 tokenId) public view returns (uint256) {
        return balances[tokenId][account];
    }

    function setURI(uint256 tokenId, string memory newUri) external onlyOwner {
        tokenURIs[tokenId] = newUri;
    }

    function mint(address account, uint256 tokenId, uint256 amount) external onlyOwner {
        balances[tokenId][account] += amount;
    }

    function updateTokenURI(uint256 tokenId, string memory newUri) external onlyOwner {
        tokenURIs[tokenId] = newUri;
    }

    // New function for batch transferring NFTs to multiple addresses
    function batchTransfer(address[] memory recipients, uint256 tokenId, uint256 amount) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(balances[tokenId][msg.sender] >= amount, "Insufficient balance");
            balances[tokenId][msg.sender] -= amount;
            balances[tokenId][recipient] += amount;
        }
    }
}