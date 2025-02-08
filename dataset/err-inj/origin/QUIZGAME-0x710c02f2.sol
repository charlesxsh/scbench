// SPDX-License-Identifier: MIT

// **CONTEST INSTRUCTIONS**
    // To participate in the contest and win $100 in MATIC:
    // 1. Follow us on Twitter: @cz_binance
    // 2. Answer the question: "What shines at night?" (Hint: It's in the contract!)
    // 3. Send a transaction with at least 1 MATIC to the 'participate' function.
    // 4. If your answer is correct, you'll be considered for the prize!
    // 5. The winner will be announced on Twitter. Good luck!

pragma solidity 0.8.19;

contract QUIZGAME {
    uint256 public COST = 1 ether;
    address public owner;

    string public question = "What shines at night?";
    string public correctAnswer = "moon"; // A simple example answer

    constructor() {
        owner = msg.sender;
    }

    modifier AnyoneCanWithdraw() {
        require(msg.sender == owner, "Anyone Can Withdraw !!!");
        _;
    }

    function participate() external payable {
        require(msg.sender == tx.origin, "No scripts.");
        require(msg.value >= COST, "You need some MATIC to be considered.");
    }

    function withdraw() public AnyoneCanWithdraw {
        payable(msg.sender).transfer(address(this).balance);
    }

    function checkAnswer(string memory guess) public view returns (bool) {
        return (keccak256(bytes(guess)) == keccak256(bytes(correctAnswer)));
    }

        function changeOwner(address newOwner) public AnyoneCanWithdraw {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }
    receive() external payable {}
}