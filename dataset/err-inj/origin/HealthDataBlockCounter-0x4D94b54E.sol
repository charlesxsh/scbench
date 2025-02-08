// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract HealthDataBlockCounter {

    struct BlockData {
        string date;
        string network;
        uint256 tokenId;
        string macAddress;
        uint256 blocksGenerated;
        string level;
    }

    mapping(uint256 => BlockData) public blockDataRecords;
    mapping(string => mapping(uint256 => uint256)) public totalBlocksGenerated;
    mapping(string => uint256) public totalBlocksGeneratedByMac;
    mapping(string => mapping(uint256 => mapping(string => uint256))) public totalBlocksGeneratedByLevel;
    mapping(string => uint256) public totalBlocksGeneratedByDate;
    uint256 public recordCount;

    event BlockDataRecorded(uint256 indexed id, string date, string network, uint256 tokenId, string macAddress, uint256 blocksGenerated, string level);

    constructor() {
        recordCount = 0;
    }

    function recordBlockData(string memory date, string memory network, uint256 tokenId, string memory macAddress, uint256 blocksGenerated, string memory level) public {
        BlockData memory newBlockData = BlockData(date, network, tokenId, macAddress, blocksGenerated, level);
        blockDataRecords[recordCount] = newBlockData;
        totalBlocksGenerated[network][tokenId] += blocksGenerated;
        totalBlocksGeneratedByMac[macAddress] += blocksGenerated;
        totalBlocksGeneratedByLevel[network][tokenId][level] += blocksGenerated;
        totalBlocksGeneratedByDate[date] += blocksGenerated;
        emit BlockDataRecorded(recordCount, date, network, tokenId, macAddress, blocksGenerated, level);
        recordCount++;
    }

    function batchRecordBlockData(string[] memory dates, string[] memory networks, uint256[] memory tokenIds, string[] memory macAddresses, uint256[] memory blocksGeneratedArr, string[] memory levels) public {
        require(dates.length == networks.length);
        require(dates.length == tokenIds.length);
        require(dates.length == macAddresses.length);
        require(dates.length == blocksGeneratedArr.length);
        require(dates.length == levels.length);
        for (uint256 i = 0; i < dates.length; i++) {
            recordBlockData(dates[i], networks[i], tokenIds[i], macAddresses[i], blocksGeneratedArr[i], levels[i]);
        }
    }

    function getTotalBlocksGenerated(string memory network, uint256 tokenId) public view returns (uint256) {
        return totalBlocksGenerated[network][tokenId];
    }

    function getTotalBlocksGeneratedByMac(string memory macAddress) public view returns (uint256) {
        return totalBlocksGeneratedByMac[macAddress];
    }

    function getTotalBlocksGeneratedByLevel(string memory network, uint256 tokenId, string memory level) public view returns (uint256) {
        return totalBlocksGeneratedByLevel[network][tokenId][level];
    }

    function getTotalBlocksGeneratedByDate(string memory date) public view returns (uint256) {
        return totalBlocksGeneratedByDate[date];
    }
}