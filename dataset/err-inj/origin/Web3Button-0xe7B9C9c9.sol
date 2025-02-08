// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

contract Web3Button {
  address public owner;
  bool public isGameActive = true;
  uint256 public constant CLAIM_DURATION = 300 seconds;

  struct GameStatus {
    address lastPresser;
    uint256 lastPressTimestamp;
    uint256 potBalance;
  }

  GameStatus public gameStatus;

  event GameStatusChanged(
    address indexed lastPresser,
    uint256 lastPressTimestamp,
    uint256 potBalance
  );

  event GameWon(
    address indexed lastPresser,
    uint256 lastPressTimestamp,
    uint256 potBalance
  );

  constructor() {
    owner = msg.sender;
  }

  modifier onlyLastPresser() {
    require(msg.sender == gameStatus.lastPresser, "Only the last presser can call this function");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
  }

  function press() external payable {
    require(msg.value >= 0.001 ether, "You need to send at least 0.001 Eth");

    if(msg.sender == gameStatus.lastPresser && block.timestamp <= gameStatus.lastPressTimestamp + CLAIM_DURATION) {
      revert("You're already the last presser");
    }

    // Check if the previous game was unclaimed and if it's past the claimDeadline
    if(!isGameActive && block.timestamp > gameStatus.lastPressTimestamp + CLAIM_DURATION) {
      isGameActive = true;
    }

    // Check if someone is eligible to claim the pot
    if(block.timestamp - gameStatus.lastPressTimestamp >= 60 seconds && block.timestamp <= gameStatus.lastPressTimestamp + CLAIM_DURATION) {
      revert("Game has ended. Waiting for the winner to claim the pot.");
    }

    gameStatus.potBalance += (msg.value * 9) / 10;
    gameStatus.lastPresser = msg.sender;
    gameStatus.lastPressTimestamp = block.timestamp;

    emit GameStatusChanged(gameStatus.lastPresser, gameStatus.lastPressTimestamp, gameStatus.potBalance);
  }

  function claimPot() external onlyLastPresser {
    require(block.timestamp - gameStatus.lastPressTimestamp >= 60 seconds, "Wait for the timer to expire.");
    require(block.timestamp <= gameStatus.lastPressTimestamp + CLAIM_DURATION, "Claim period has expired.");
    require(gameStatus.potBalance > 0, "Pot balance is empty");

    uint256 amountToSend = gameStatus.potBalance;
    gameStatus.potBalance = 0;
    isGameActive = false;
    gameStatus.lastPresser = address(0);
    gameStatus.lastPressTimestamp = 0;

    (bool success, ) = msg.sender.call{ value: amountToSend }("");
    require(success, "Transfer failed");

    emit GameWon(msg.sender, block.timestamp, amountToSend);
  }

  receive() external payable {
    revert("Contract does not accept direct Ether transfers");
  }

  function withdraw() external onlyOwner {
    uint256 protocolBalance = address(this).balance - gameStatus.potBalance;
    payable(owner).transfer(protocolBalance);
  }

}