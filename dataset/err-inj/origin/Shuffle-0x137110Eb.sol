// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Shuffle is Ownable {
    //every time variable used is in seconds
    uint256 internal nextRoomId = 1;
    mapping(uint256 => ShuffleRoom) private rooms;

    uint256 constant GAME_NOT_STARTED = 0;
    uint256 constant GAME_ONGOING = 1;
    uint256 constant GAME_WAITING_FOR_BID = 2;
    uint256 constant MAX_CAPACITY_REACHED = 3;
    uint256 constant TIME_OVER = 4;
    uint256 constant SHUFFLE_DOESNT_MATCH = 5;
    uint256 constant ROOM_HAS_STOPPED = 6; //valid is false
    uint256 constant BID_CANNOT_BE_ZERO = 7;
    uint256 constant BID_TOO_LOW = 8;
    uint256 constant INVALID_COMMISSION_PERCENT = 9;
    uint256 constant BID_TOO_HIGH = 10;

    struct ShuffleRoom {
        uint256 id;
        string name;
        uint256 capacity;
        uint256 timePeriod;
        uint256 minTimePeriod;
        uint256 minBidAmount;
        uint256 maxBidAmount;
        uint256 commissionPercent;
        uint256 totalCollection;
        uint256 totalDistribution;
        address fundsWallet;
        GameHistory[] history;
        ShuffleGame game;
    }

    struct ShuffleGame {
        bool valid;
        uint256 gameNo;
        GameBid[] bids;
        uint256 state; // shuffle not started or shuffle ongoing
        uint256 totalAmount;
        uint256 startedAt; // default 0
        uint256 counterStartedAt;
        address previousWinner; // default owner address
        uint256 previousWinAmount; // 0
        uint256 previousBidValue; // 0
    }

    struct GameBid {
        address bidder;
        uint256 amount;
    }

    struct GameHistory {
        uint256 roomId;
        uint256 gameNo;
        address winner;
        uint256 totalBid;
        uint256 winnerAmount;
        uint256 drawnAt;
    }

    event GameTimerStarted(uint256 roomId, uint256 gameNo, uint256 startedAt);

    event GameWon(
        uint256 roomId,
        uint256 gameNo,
        address winner,
        uint256 totalBid,
        uint256 winnerAmount
    );

    event GameBidPlaced(
        uint256 roomId,
        uint256 gameNo,
        address bidder,
        uint256 amount
    );

    event ShuffleRoomCreated(uint256 roomId, string name);

    event ShuffleRoomUpdated(uint256 roomId, bool valid);

    function createRoom(
        string memory name,
        uint256 minBidAmount,
        uint256 maxBidAmount,
        uint256 commissionPercent,
        uint256 capacity,
        uint256 timePeriod,
        address fundsWallet
    ) external onlyOwner {
        ShuffleRoom storage newRoom = rooms[nextRoomId];
        newRoom.id = nextRoomId;
        newRoom.name = name;
        newRoom.capacity = capacity;
        newRoom.timePeriod = timePeriod;
        newRoom.minTimePeriod = timePeriod;
        newRoom.minBidAmount = minBidAmount;
        newRoom.maxBidAmount = maxBidAmount;
        newRoom.commissionPercent = commissionPercent;
        newRoom.fundsWallet = fundsWallet;

        // Initialize other fields of ShuffleRoom
        newRoom.totalCollection = 0;
        newRoom.totalDistribution = 0;
        newRoom.game.valid = true;
        newRoom.game.gameNo = 0;
        newRoom.game.state = 0;
        newRoom.game.totalAmount = 0;
        newRoom.game.startedAt = 0;
        newRoom.game.counterStartedAt = 0;
        newRoom.game.previousWinner = address(0);
        newRoom.game.previousWinAmount = 0;
        newRoom.game.previousBidValue = 0;

        rooms[nextRoomId] = newRoom;
        emit ShuffleRoomCreated(nextRoomId, name);
        nextRoomId++;
    }

    function modifyRoom(
        uint256 roomId,
        bool valid,
        uint256 commissionPercent,
        address fundsWallet
    ) external {
        ShuffleRoom storage room = rooms[roomId];
        require(
            room.game.state == GAME_NOT_STARTED,
            "Can't modify room : ongoing game"
        );
        room.game.valid = valid;
        room.fundsWallet = fundsWallet;
        room.commissionPercent = commissionPercent;
        emit ShuffleRoomUpdated(roomId, valid);
    }

    function placeBid(uint256 roomId) external payable {
        address bidder = msg.sender;
        uint256 bidAmount = msg.value;
        uint256 currentTime = block.timestamp;
        ShuffleRoom storage room = rooms[roomId];
        require(room.game.valid, "ROOM_HAS_STOPPED");

        if (room.game.state == GAME_ONGOING) {
            require(
                currentTime <= room.game.counterStartedAt + room.timePeriod,
                "TIME_OVER"
            );
        }

        require(bidAmount > 0, "BID_CANNOT_BE_ZERO");

        uint256 len = room.game.bids.length;
        bool exists = false;
        uint256 i = 0;
        for (; i < len; i++) {
            GameBid memory cur = room.game.bids[i];
            if (cur.bidder == bidder) {
                exists = true;
                break;
            }
        }

        if (exists) {
            GameBid storage myBid = room.game.bids[i];
            require(
                myBid.amount + bidAmount <= room.maxBidAmount,
                "BID_TOO_HIGH"
            );
            myBid.amount += bidAmount;
        } else {
            require(len < room.capacity, "MAX_CAPACITY_REACHED");
            require(bidAmount >= room.minBidAmount, "BID_TOO_LOW");
            require(bidAmount <= room.maxBidAmount, "BID_TOO_HIGH");

            GameBid memory newBid = GameBid(bidder, bidAmount);
            room.game.bids.push(newBid);
        }
        //emti event for bid place
        emit GameBidPlaced(roomId, room.game.gameNo, bidder, bidAmount);

        // Update balance

        room.game.totalAmount += bidAmount;

        len = room.game.bids.length;
        if (len == 1) {
            room.game.startedAt = block.timestamp;
            room.game.state = GAME_WAITING_FOR_BID;
        } else if (len == 2) {
            room.game.state = GAME_ONGOING;
            room.game.counterStartedAt = block.timestamp;
            // Emit events
            emit GameTimerStarted(roomId, room.game.gameNo, currentTime);
        } else {
            room.timePeriod += 5;
        }
    }

    function selectWinner(
        uint256 winnerIndex,
        uint256 roomId
    ) external onlyOwner {
        ShuffleRoom storage room = rooms[roomId];

        // Check if shuffle is running
        require(room.game.valid, "ROOM_HAS_STOPPED");
        require(room.game.state == GAME_ONGOING, "GAME_IS_NOT_ONGOING");

        // Check if the shuffle time period has been closed
        uint256 currentTime = block.timestamp;
        require(
            currentTime > room.game.counterStartedAt + room.timePeriod,
            "GAME_ONGOING"
        );

        GameBid storage winnerBid = room.game.bids[winnerIndex];
        uint256 totalCollection = room.game.totalAmount;
        uint256 tax = (totalCollection * room.commissionPercent) / 100;
        uint256 prizeMoney = totalCollection - tax;

        //transfer funds
        payable(room.fundsWallet).transfer(tax);
        payable(winnerBid.bidder).transfer(prizeMoney);

        address bidder = winnerBid.bidder;
        room.game.previousWinner = bidder;
        room.game.previousWinAmount = prizeMoney;
        room.game.previousBidValue = totalCollection;
        room.game.state = GAME_NOT_STARTED; // SHUFFLE_NOT_STARTED
        room.game.gameNo = room.game.gameNo + 1;
        room.totalCollection += totalCollection;
        room.totalDistribution += prizeMoney;
        room.timePeriod = room.minTimePeriod;
        room.game.totalAmount = 0;

        // Clear bids
        delete room.game.bids;

        GameHistory memory obj = GameHistory(
            room.id,
            room.game.gameNo,
            bidder,
            totalCollection,
            prizeMoney,
            currentTime
        );

        // Add obj to history
        if (room.history.length == 20) {
            for (uint256 i = 0; i < 19; i++) {
                room.history[i] = room.history[i + 1];
            }
            room.history[19] = obj;
        } else {
            room.history.push(obj);
        }

        emit GameWon(
            room.id,
            room.game.gameNo,
            bidder,
            totalCollection,
            prizeMoney
        );
    }

    function withdrawBid(uint256 roomId) external {
        ShuffleRoom storage room = rooms[roomId];
        require(
            room.game.state == GAME_WAITING_FOR_BID,
            "Game state is invalid to withdraw"
        );
        require(
            block.timestamp > room.game.startedAt + 86400,
            "Limit time not exceeded yet"
        );
        require(
            room.game.bids[0].bidder == msg.sender,
            "You are not the bidder"
        );
        payable(msg.sender).transfer(room.game.bids[0].amount);
        room.game.state = GAME_NOT_STARTED;
        
        room.game.totalAmount = 0;
        
        delete room.game.bids;
    }

    function getRoom(
        uint256 roomId
    )
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 capacity,
            uint256 timePeriod,
            uint256 minTimePeriod,
            uint256 minBidAmount,
            uint256 maxBidAmount,
            uint256 commissionPercent,
            uint256 totalCollection,
            uint256 totalDistribution,
            address fundsWallet,
            GameHistory[] memory history
        )
    {
        ShuffleRoom storage room = rooms[roomId];
        return (
            room.id,
            room.name,
            room.capacity,
            room.timePeriod,
            room.minTimePeriod,
            room.minBidAmount,
            room.maxBidAmount,
            room.commissionPercent,
            room.totalCollection,
            room.totalDistribution,
            room.fundsWallet,
            room.history
        );
    }

    function getRoomGameDetails(
        uint256 roomId
    ) external view returns (ShuffleGame memory game) {
        ShuffleRoom storage room = rooms[roomId];
        return (room.game);
    }
}