// SPDX-License-Identifier: MIT
// Blocktools DAO
// https://linktr.ee/blocktoolbox

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ToolsDAO is Ownable {
    
    enum VotingOptions { Yes, No }
    enum Status { Accepted, Rejected, Pending }
    struct Proposal {
        uint256 id;
        address author;
        string name;
        uint256 createdAt;
        uint256 votesForYes;
        uint256 votesForNo;
        Status status;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes;
    mapping(address => uint256) public tools;
    uint public totalTools;
    IERC20 public token;
    uint TOOLS_FOR_PROPOSAL = 1000000000000000000000;
    uint VOTING_TENURE = 3 days;
    uint public nextProposalId;
    
    constructor() {
        token = IERC20(0xc14B4d4CA66f40F352d7a50fd230EF8b2Fb3b8d4);
    }
    
    function supplyVotes(uint _amount) external {
        tools[msg.sender] += _amount;
        totalTools += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
    }
    
    function retrieve(uint _amount) external {
        require(tools[msg.sender] >= _amount, "Insufficient Tools Balance");
        tools[msg.sender] -= _amount;
        totalTools -= _amount;
        token.transfer(msg.sender, _amount);
    }

    function submitProposal(string memory name) external {
    require(tools[msg.sender] >= TOOLS_FOR_PROPOSAL, "Insufficient TOOLS to propose");
    
    proposals[nextProposalId] = Proposal(
        nextProposalId,
        msg.sender,
        name,
        block.timestamp,
        0,
        0,
        Status.Pending
    );
    nextProposalId++;
    }

    function vote(uint _proposalId, VotingOptions _vote) external {
    Proposal storage proposal = proposals[_proposalId];
    require(votes[msg.sender][_proposalId] == false, "already voted");
    require(block.timestamp <= proposal.createdAt + VOTING_TENURE, "Ballot time is finished");
    votes[msg.sender][_proposalId] = true;
    if(_vote == VotingOptions.Yes) {
        proposal.votesForYes += tools[msg.sender];
        if(proposal.votesForYes * 100 / totalTools > 50) {
            proposal.status = Status.Accepted;
        }
    } else {
        proposal.votesForNo += tools[msg.sender];
        if(proposal.votesForNo * 100 / totalTools > 50) {
            proposal.status = Status.Rejected;
        }
      }
    }

    function setProposalToll(uint256 _minTools) external onlyOwner {
        TOOLS_FOR_PROPOSAL = _minTools;
    }

    function setVotingRange(uint256 _tenure) external onlyOwner {
        VOTING_TENURE = _tenure;
    }

    function getVoteCounts(uint256 proposalId) external view returns (uint256, uint256) {
        require(proposalId < nextProposalId, "Invalid proposal ID");
    
         Proposal storage proposal = proposals[proposalId];
        return (proposal.votesForYes, proposal.votesForNo);
    }

     function votingTollgate() external view returns (uint256, uint256) {
        return (TOOLS_FOR_PROPOSAL, VOTING_TENURE);
    }
}