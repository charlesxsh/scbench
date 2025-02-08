// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface  INFT {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint256 balance);
    function mintSeaDrop(address minter, uint256 quantity) external;
}

/**
 * @title Token mining manager administrator contract.
 */
contract Ownable {
    address public owner_;

    /// @dev Only admins can execute.
    modifier onlyOwner() {
        require(owner_ == msg.sender);
        _;
    }

    function setOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0) && owner_ != _newOwner);
        owner_ = _newOwner;
    }
}

contract CryptoPipisMint is Ownable {

    // Floor price per token
    uint256 public price_ = 0.0044e18;
    // The address of pipis NFT
    address public nft = 0xfb9DE29EE5406BDDC27A1413Ef2c47c66C78f097;
    // Mint event
    event Minted(address indexed wallet, uint amount);  

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor() {
        owner_ = msg.sender;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price_ = _price;
    }

    // =============================================================
    //                       PUPLIC FUNCTIONS
    // =============================================================
    
    function getMintable() public view returns(uint) {
        return (uint(10000) - INFT(nft).totalSupply());
    }

    // Maximum tokens to mint is 10,000
    function mint(uint256 _amount) public payable {

        uint256 _price = _amount * price_;
        uint256 _mintable = uint(10000) - INFT(nft).totalSupply();

        require(_amount <= _mintable, "Mint: quantity exceeds available tokens for mint");
        require(_amount <= 10, "Mint: quantity exceeds maximum allowed per transaction");

        // For contract owner to mass mint the remaining tokens if any
        // to be then sold on open marketplaces
        if (msg.sender == owner_) {
            _price = 0;
        } else {
            require(INFT(nft).balanceOf(msg.sender) + _amount <= 100, 'Exceeds max mint per wallet reached');
        }

        require(msg.value >= _price, "Insufficient payment");

        INFT(nft).mintSeaDrop(msg.sender, _amount);

        // Transfer excess amount of ether
        if (msg.value > _price) {
            payable(msg.sender).transfer(msg.value - _price);
        }

        emit Minted(msg.sender, _amount);        
    }

    function withdraw() public onlyOwner {
        uint _amount = address(this).balance;
        payable(owner_).transfer(_amount);
    }
}