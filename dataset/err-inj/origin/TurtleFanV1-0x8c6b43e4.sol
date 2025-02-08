/*
  _            _   _        __           
 | |_ _  _ _ _| |_| |___   / _|__ _ _ _  
 |  _| || | '_|  _| / -_)_|  _/ _` | ' \ 
  \__|\_,_|_|  \__|_\___(_)_| \__,_|_||_|
                                    
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity >=0.8.2 <0.9.0;

contract TurtleFanV1 is Ownable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;
    uint256 public holderFeePercent;

    event Trade(address trader, address subject, bool isBuy, uint256 shareAmount, uint256 ethAmount, uint256 protocolEthAmount, uint256 subjectEthAmount, uint256 holderEthAmount, uint256 supply, uint256 timestamp);

    mapping(address => mapping(address => uint256)) public sharesBalance;

    mapping(address => uint256) public sharesSupply;

    mapping(address => address[]) public sharesSubjectToBuyers;

    mapping(address => address[]) public BuyerTosharesSubjects;


    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function setHolderFeePercent(uint256 _feePercent) public onlyOwner {
        holderFeePercent = _feePercent;
    }

    function getPrice(uint256 supply, uint256 amount) public pure returns (uint256) {
        uint256 sum1 = supply == 0 ? 0 : (supply - 1 )* (supply) * (2 * (supply - 1) + 1) / 6;
        uint256 sum2 = supply == 0 && amount == 1 ? 0 : (supply - 1 + amount) * (supply + amount) * (2 * (supply - 1 + amount) + 1) / 6;
        uint256 summation = sum2 - sum1;
        return summation * 1000000000000000000 / 12;
    }


    function getBuyPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject], amount);
    }

    function getSellPrice(address sharesSubject, uint256 amount) public view returns (uint256) {
        return getPrice(sharesSupply[sharesSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getBuyPrice(sharesSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        uint256 holderFee = (price * holderFeePercent) / 1 ether;
        return price + protocolFee + subjectFee + holderFee;
    }

    function getSellPriceAfterFee(address sharesSubject, uint256 amount) public view returns (uint256) {
        uint256 price = getSellPrice(sharesSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        uint256 holderFee = (price * holderFeePercent) / 1 ether;
        return price - protocolFee - subjectFee - holderFee;
    }

    function getSubjectsForBuyer(address buyer) public view returns (address[] memory) {
        return BuyerTosharesSubjects[buyer];
    }

    function getBuyersForSubject(address subject) public view returns (address[] memory) {
        return sharesSubjectToBuyers[subject];
    }

    function AddtoArray(address sharesSubject, uint256 amount) private {
        for (uint256 i = 0; i < amount; i++) {
            BuyerTosharesSubjects[msg.sender].push(sharesSubject);
        }
    }

    function RemovefromArray(address sharesSubject, uint256 amount) private {
     address[] storage holdings = BuyerTosharesSubjects[msg.sender];
        uint256 removals = 0;
        for (uint256 i = 0; i < holdings.length && removals < amount;) {
            if (holdings[i] == sharesSubject) {
                holdings[i] = holdings[holdings.length - 1];
                holdings.pop();
                removals++;
            }
            else {
                i++;
            }
        }
    }

    function buyShell(address sharesSubject, uint256 amount) public payable {
        uint256 supply = sharesSupply[sharesSubject];
        require(supply > 0 || sharesSubject == msg.sender, "Only the shares' subject can buy the first share");
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        uint256 holderFee = price * holderFeePercent / 1 ether;
        require(msg.value >= price + protocolFee + subjectFee + holderFee, "Insufficient payment");
        sharesBalance[sharesSubject][msg.sender] = sharesBalance[sharesSubject][msg.sender] + amount;
        for (uint256 i = 0; i < amount; i++) {
            sharesSubjectToBuyers[sharesSubject].push(msg.sender);
        }
        sharesSupply[sharesSubject] = supply + amount;
        AddtoArray(sharesSubject, amount);
        emit Trade(msg.sender, sharesSubject, true, amount, price, protocolFee, subjectFee, holderFee, supply + amount, block.timestamp);
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = sharesSubject.call{value: subjectFee}("");
        address[] memory shareHolders = sharesSubjectToBuyers[sharesSubject];
        uint256 individualHolderFee = holderFee / shareHolders.length;
        for (uint256 i = 0; i < shareHolders.length; i++) {
            (bool successLoop, ) = shareHolders[i].call{value: individualHolderFee}("");
            require(successLoop, "Unable to send funds to a holder");
        }
        require(success1 && success2, "Unable to send funds");
    }


    function sellShell(address sharesSubject, uint256 amount) public payable {
        uint256 supply = sharesSupply[sharesSubject];
        require(supply > amount, "Cannot sell the last share");
        require(sharesBalance[sharesSubject][msg.sender] >= amount, "Insufficient shares");
        sharesBalance[sharesSubject][msg.sender] = sharesBalance[sharesSubject][msg.sender] - amount;
        address[] storage buyers = sharesSubjectToBuyers[sharesSubject];
        uint256 removals = 0;
        for (uint256 i = 0; i < buyers.length && removals < amount;) {
            if (buyers[i] == msg.sender) {
                buyers[i] = buyers[buyers.length - 1];
                buyers.pop();
                removals++;
            }
            else {
                i++;
            }
        }
        sharesSupply[sharesSubject] = supply - amount;
        RemovefromArray(sharesSubject, amount);
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = price * protocolFeePercent / 1 ether;
        uint256 subjectFee = price * subjectFeePercent / 1 ether;
        uint256 holderFee = price * holderFeePercent / 1 ether;
        uint256 forEvent = supply - amount;
        emit Trade(msg.sender, sharesSubject, false, amount, price, protocolFee, subjectFee, holderFee, forEvent, block.timestamp);
        (bool success1, ) = msg.sender.call{value: price - protocolFee - subjectFee - holderFee}("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = sharesSubject.call{value: subjectFee}("");
        address[] memory shareHolders = sharesSubjectToBuyers[sharesSubject];
        uint256 individualHolderFee = holderFee / shareHolders.length;
        for (uint256 i = 0; i < shareHolders.length; i++) {
            (bool successLoop, ) = shareHolders[i].call{value: individualHolderFee}("");
            require(successLoop, "Unable to send funds to a holder");
        }
        require(success1 && success2 && success3, "Unable to send funds");
    }
}