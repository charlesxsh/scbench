// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.9.0;

contract TexasHoldem {
    uint8[] private cards;

    constructor() {
        initializeDeck();
    }

    function initializeDeck() private {
        cards = [1,2,3,4,5,6,7,8,9,10,11,12,13,17,18,19,20,21,22,23,24,25,26,27,28,29,33,34,35,36,37,38,39,40,41,42,43,44,45,49,50,51,52,53,54,55,56,57,58,59,60,61];
    }

    function shuffle() public returns (uint8[] memory) {
        uint256 n = cards.length;
        for (uint256 i = n - 1; i > 0; i--) {
            uint256 j = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), i))) % (i + 1);
            (cards[i], cards[j]) = (cards[j], cards[i]);
        }
        return cards;
    }

    function getShuffledDeck() public view returns (uint8[] memory) {
        return cards;
    }
}