// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC1155 {
    mapping(address => mapping(uint256 => uint256)) private balances;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => string) private updatedTokenURIs; // New mapping for updated token URIs

    address public owner;
    uint256 public constant TOKEN_ID = 0;
    uint256 public constant INITIAL_SUPPLY = 100000;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        balances[msg.sender][TOKEN_ID] = INITIAL_SUPPLY;
    }

    function balanceOf(address account, uint256 tokenId) public view returns (uint256) {
        return balances[account][tokenId];
    }

    function setURI(uint256 tokenId, string memory newUri) external onlyOwner {
        tokenURIs[tokenId] = newUri;
    }

    function setBatchURI(address[] memory recipients, string memory newUri) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 tokenId = TOKEN_ID;
            updatedTokenURIs[tokenId] = newUri;
        }
    }

    function mint(address account, uint256 tokenId, uint256 amount) external onlyOwner {
        balances[account][tokenId] += amount;
    }

    function airdropBatch(address[] memory recipients) external onlyOwner {
        for (uint256 i = 0; i < recipients.length; i++) {
            balances[recipients[i]][TOKEN_ID]++;
        }
    }

    function updateTokenURI(uint256 tokenId, string memory newUri) external onlyOwner {
        updatedTokenURIs[tokenId] = newUri;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        if (bytes(updatedTokenURIs[tokenId]).length > 0) {
            return updatedTokenURIs[tokenId];
        }
        return tokenURIs[tokenId];
    }

    // New function for batch transferring the same NFT to multiple addresses
    function batchTransfer(address[] memory recipients) external {
        uint256 totalRecipients = recipients.length;
        require(totalRecipients > 0, "No recipients provided");

        address sender = msg.sender;
        uint256 senderBalance = balances[sender][TOKEN_ID];

        require(senderBalance >= totalRecipients, "Insufficient balance");

        for (uint256 i = 0; i < totalRecipients; i++) {
            address recipient = recipients[i];
            balances[sender][TOKEN_ID]--;
            balances[recipient][TOKEN_ID]++;
        }
    }
}