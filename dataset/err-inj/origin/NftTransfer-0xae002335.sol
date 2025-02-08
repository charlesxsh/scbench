/**
 *Submitted for verification at PolygonScan.com on 2023-08-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

interface IERC1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external;
}

contract NftTransfer {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

      modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function transferERC1155(
        IERC1155[] calldata _tokens,
        address[] calldata _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    ) public onlyOwner{
        require(_tokens.length > 0, "No tokens specified");
        require(
            _to.length == _ids.length && _to.length == _amounts.length,
            "Receivers, IDs, and amounts are of different lengths"
        );
        require(_to.length > 0, "No NFTs to transfer");

        uint256 numTokens = _tokens.length;
        uint256 numReceivers = _to.length;

        for (uint256 i = 0; i < numTokens; i++) {
            IERC1155 token = _tokens[i];
            bool isProcessed = false;
            for (uint256 j = 0; j < numReceivers; j++) {
                if (_amounts[i] > 0 && !isProcessed) {
                    token.safeTransferFrom(
                        msg.sender,
                        _to[j],
                        _ids[i],
                        _amounts[i],
                        ""
                    );
                    isProcessed = true;
                }
            }
        }
    }

     function transferERC721(
        IERC721[] calldata _tokens,
        address[] calldata _to,
        uint256[] calldata _ids
    ) public onlyOwner{
        require(_tokens.length > 0, "No tokens specified");
        require(
            _to.length == _ids.length,
            "Receivers, IDs are of different lengths"
        );
        require(_to.length > 0, "No NFTs to transfer");

        uint256 numTokens = _tokens.length;
        uint256 numReceivers = _to.length;

        for (uint256 i = 0; i < numTokens; i++) {
            IERC721 token = _tokens[i];
            bool isProcessed = false;
            for (uint256 j = 0; j < numReceivers; j++) {
                if (!isProcessed) {
                    token.safeTransferFrom(
                        msg.sender,
                        _to[j],
                        _ids[i]
                    );
                    isProcessed = true;
                }
            }
        }
    }

}