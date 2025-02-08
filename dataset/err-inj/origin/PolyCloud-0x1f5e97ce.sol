// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract PolyCloud {
    struct User {
        uint userId;
        string userName;
        uint totalFiles;
        uint totalStorage;
        uint usedStorage;
        string userImage;
        address payable userAddress;
    }
    User[] private users;

    uint private userId = 0;

    struct File {
        uint fileId;
        string fileName;
        string fileCID;
        uint fileSize;
    }

    File[] private files;

    uint private fileId = 0;

    mapping(address => User) userAddresses;
    mapping(address => File[]) userFiles;

    function createUser(
        string memory _userName,
        string memory _userImage
    ) public {
        require(
            userAddresses[msg.sender].userAddress == address(0),
            "Account already exists"
        );

        User memory newUser = User({
            userId: userId,
            userName: _userName,
            totalFiles: 0,
            totalStorage: 500,
            usedStorage: 0,
            userImage: _userImage,
            userAddress: payable(msg.sender)
        });

        users.push(newUser);
        userAddresses[msg.sender] = newUser;
        userId++;
    }

    function getUser() public view returns (User memory) {
        return userAddresses[msg.sender];
    }

    function editUser(
        string memory _userName,
        string memory _userImage
    ) public {
        User storage currentUser = userAddresses[msg.sender];
        require(
            currentUser.userAddress == msg.sender,
            "Not authorized to edit"
        );
        currentUser.userName = _userName;
        currentUser.userImage = _userImage;
    }

    function uploadFile(
        string memory _fileName,
        string memory _fileCID,
        uint _fileSize
    ) public {
        User storage currentUser = userAddresses[msg.sender];

        require(
            currentUser.usedStorage + _fileSize <= currentUser.totalStorage,
            "Storage limit exceeded"
        );

        File memory newFile = File({
            fileId: fileId,
            fileName: _fileName,
            fileCID: _fileCID,
            fileSize: _fileSize
        });

        files.push(newFile);
        userFiles[msg.sender].push(newFile);

        currentUser.totalFiles++;
        currentUser.usedStorage += _fileSize;
        fileId++;
    }

    function upgradeStorage(uint storageToAdd) public payable {
        userAddresses[msg.sender].totalStorage += storageToAdd;
    }

    function getFilesForUser() public view returns (File[] memory) {
        return userFiles[msg.sender];
    }

    function getCurrentTotalStorage() public view returns (uint) {
        return userAddresses[msg.sender].totalStorage;
    }

    function getCurrentUsedStorage() public view returns (uint) {
        return userAddresses[msg.sender].usedStorage;
    }

    function getAllUsersCount() public view returns (uint) {
        return users.length;
    }

    function getAllUsers() public view returns (User[] memory) {
        return users;
    }

    function getAllFiles() public view returns (File[] memory) {
        return files;
    }

    function getAllFilesCount() public view returns (uint) {
        return files.length;
    }

    address payable private owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function withdrawAllFunds() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds to withdraw");
        owner.transfer(contractBalance);
    }

    function getContractBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
}