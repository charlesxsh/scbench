// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CSGOMarketplace {
    address public owner;

    struct Listing {
        address seller;
        address buyer;
        uint256 price;
        bool isSold;
        bool isCompleted;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public latestListingId; // New state variable to keep track of the latest listing ID

    event ListingCreated(uint256 indexed id, address indexed seller);
    event ListingSold(uint256 indexed id, address indexed buyer, uint256 price);
    event FundsReleased(uint256 indexed id, address indexed seller, uint256 price);
    event FundsReturned(uint256 indexed id, address indexed buyer, uint256 price);

    constructor() {
        owner = msg.sender;
        latestListingId = 0; // Initialize the latestListingId to 0 (or any other starting value)
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function createListing() external returns (uint256) {
        address _seller = msg.sender;

        latestListingId++; // Increment the latestListingId
        uint256 listingId = latestListingId;

        listings[listingId] = Listing(_seller, address(0), 0, false, false);

        emit ListingCreated(listingId, _seller);
        
        return listingId;
    }

    function purchaseListing(uint256 _listingId) external payable {
        Listing storage listing = listings[_listingId];

        require(listing.seller != address(0), "Invalid seller wallet address");
        require(!listing.isSold, "Listing already sold");
        require(!listing.isCompleted, "Listing already completed");
        require(msg.value > 0, "Incorrect payment amount");

        listing.isSold = true;
        listing.price = msg.value;
        listing.buyer = msg.sender;

        emit ListingSold(_listingId, msg.sender, msg.value);
    }

    function releaseFunds(uint256 _listingId) external onlyOwner {
        Listing storage listing = listings[_listingId];

        require(listing.seller != address(0), "Invalid seller wallet address");
        require(listing.isSold, "Listing not sold");
        require(!listing.isCompleted, "Listing already completed");
        require(listing.price > 0, "No price available");

        address payable seller = payable(listing.seller);
        uint256 feeAmount = (listing.price * 4) / 100;
        seller.transfer(listing.price - feeAmount);
        payable(0xA7F2FD4367674b1f0A48E6803Be32397e16a5f3F).transfer(feeAmount);

        listing.isCompleted = true;

        emit FundsReleased(_listingId, seller, listing.price);
    }

    function returnToBuyer(uint256 _listingId) external onlyOwner {
        Listing storage listing = listings[_listingId];

        require(listing.seller != address(0), "Invalid listing ID");
        require(listing.price > 0, "No price available");
        require(!listing.isCompleted, "Listing already completed");

        address payable buyer = payable(listing.buyer);
        uint256 priceToReturn = listing.price;
        buyer.transfer(listing.price);

        listing.isCompleted = true;
        listing.price = 0;

        emit FundsReturned(_listingId, buyer, priceToReturn); // Emit event to indicate the return of funds
    }
}