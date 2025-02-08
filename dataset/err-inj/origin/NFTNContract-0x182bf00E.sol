//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
interface INFMMint{    
    function _updateBNFTAmount(address minter) external returns (bool);
} 
interface ERC721TokenReceiver {     
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}
interface IERC721Errors {     
    error ERC721InvalidOwner(address owner);

    error ERC721NonexistentToken(uint256 tokenId);

    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
     
    error ERC721InvalidSender(address sender);
     
    error ERC721InvalidReceiver(address receiver);
     
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
     
    error ERC721InvalidApprover(address approver);
     
    error ERC721InvalidOperator(address operator);
}
interface INFMController {
    function _checkWLSC(address Controller, address Client) external pure returns (bool);
    
    function _getTreasury() external pure returns (address);

    function _getMinting() external pure returns (address);
}
contract ERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(0x01ffc9a7);
    }

    function supportsInterface(bytes4 interfaceId) external virtual view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Invalid interface ID");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract NFTNContract is ERC165,IERC721Errors {
    string private _name;
    string private _symbol;
    uint256 private _tokenIdCounter;
    uint256 private _locked=0;
    address private _owner;
    address private _SController;
    uint256 private _commision=2;
    uint256 private _mintcomission=1000000000000000000;
    //Maps
    mapping(uint256 => address) private _owners;
    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => address) private _royaltiesOwner;
    mapping(uint256 => uint256) private _royalties;
    mapping(uint256 => uint256) private _enumeration;
    //Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event Royalties(uint256 indexed tokenId, address indexed recipient, uint256 value);
    event Mint(address indexed to, uint256 indexed tokenId);
    //Interfaces
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    bytes4 private constant _INTERFACE_ID_ERC721_RECEIVER = 0x150b7a02;
    //Reentrancy
    modifier reentrancyGuard() {
        require(_locked == 0);
        _locked = 1;
        _;
        _locked = 0;
    }
    constructor(string memory nn, string memory sy, address SController ) {
        _name = nn;
        _symbol = sy;
        _owner = msg.sender;
        _SController=SController;
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC2981);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
        _registerInterface(_INTERFACE_ID_ERC721_RECEIVER);
    }
    
    function name() external view returns (string memory) {
        return _name;
    }
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function comission() external view returns (uint256,uint256) {
        require(
            INFMController(address(_SController))._checkWLSC(_SController, msg.sender) == true ||
                _owner == msg.sender,
            "oO"
        );
        return (_commision,_mintcomission);
    }
    function changeComission(uint256 nc,uint256 nmc) external returns (bool) {
        require(
            INFMController(address(_SController))._checkWLSC(_SController, msg.sender) == true ||
                _owner == msg.sender,
            "oO"
        );
        if(_commision!=nc){
            _commision=nc;
        }
        if(_mintcomission!=nmc){
            _mintcomission=nmc;
        }
        return true;
    }
    
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter;
    }
    
    function balanceOf(address owner) external view returns (uint256) {
        return _ownedTokens[owner].length;
    }
    function returnAllNftsOf(address owner) external view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
    
    function ownerOf(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _owners[tokenId];
    }
    
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenURIs[tokenId];
    }
    
    function approve(address to, uint256 tokenId) external {
        address owner = this.ownerOf(tokenId);
        require(to != owner, "Cannot approve to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender) || msg.sender == _owner, "Not approved");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function getApproved(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenApprovals[tokenId];
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "Cannot set approval for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        _safeTransferFrom(from, to, tokenId, '');
    }
    
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
    
    function setTokenURI(uint256 tokenId, string memory tokenuRI) internal returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        _tokenURIs[tokenId] = tokenuRI;
        return true;
    }
    
    function setRoyalties(uint256 tokenId, uint256 value) external {
        require(_exists(tokenId), "Token does not exist");
        require(_owners[tokenId]==msg.sender, "Not owner");
        uint256 b =value; 
        //Limit to max 10 Matic
        if(value > 10000000000000000000){
            b=10000000000000000000;
        }
        _royalties[tokenId] = b;
        _royaltiesOwner[tokenId]=_owners[tokenId];
        emit Royalties(tokenId, msg.sender, b);
    }
    function _burn(uint256 tokenId) public reentrancyGuard{
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        address previousOwner = this.ownerOf(tokenId);
        _removeTokenFromOwner(previousOwner, tokenId);
        _addTokenToOwner(address(0),tokenId);
        _owners[tokenId] = address(0);
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        emit Transfer(previousOwner, address(0), tokenId);
    }
    function getRoyalties(uint256 tokenId) external view returns (uint256, address) {
        require(_exists(tokenId), "Token does not exist");
        return (_royalties[tokenId],_royaltiesOwner[tokenId]);
    }
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) public view returns (
        address receiver,
        uint256 royaltyAmount
    ){return (_royaltiesOwner[_tokenId],_royalties[_tokenId]);}
    
    function supportsInterface(bytes4 interfaceId) external override  view returns (bool) {
        return
            interfaceId == _INTERFACE_ID_ERC721 ||
            interfaceId == _INTERFACE_ID_ERC721_METADATA ||
            interfaceId == _INTERFACE_ID_ERC2981 ||
            interfaceId == _INTERFACE_ID_ERC721_ENUMERABLE ||
            interfaceId == _INTERFACE_ID_ERC721_RECEIVER ||
            this.supportsInterface(interfaceId);
    }
    
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(this.ownerOf(tokenId) == from, "Not the owner of the token");
        require(to != address(0), "Cannot transfer to zero address");

        _removeTokenFromOwner(from, tokenId);
        _addTokenToOwner(to,tokenId);
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        address owner = this.ownerOf(tokenId);
        return (spender == owner || this.getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    
    // Helper functions for array manipulation
    
    function _addTokenToOwner(address owner, uint256 tokenId) internal {
        _ownedTokens[owner].push(tokenId);
    }
    
    function _removeTokenFromOwner(address owner, uint256 tokenId) internal {
        uint256[] storage ownerTokens = _ownedTokens[owner];
        for (uint256 i = 0; i < ownerTokens.length; i++) {
            if (ownerTokens[i] == tokenId) {
                // Swap with the last element and remove
                ownerTokens[i] = ownerTokens[ownerTokens.length - 1];
                ownerTokens.pop();
                break;
            }
        }
    }    
    function _removeTokenFromApproval(uint256 tokenId) internal {
        if (_tokenApprovals[tokenId] != address(0)) {
            delete _tokenApprovals[tokenId];
        }
    }
    receive() external payable{}
    fallback() external payable{}

    function mint(address to, string memory tokenuRI ) external payable reentrancyGuard {
        require(msg.value > _mintcomission);
        require(to != address(0), "Cannot mint to zero address");
        payable(address(INFMController(address(_SController))._getTreasury())).transfer(_mintcomission);
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _owners[tokenId] = to;
        _ownedTokens[to].push(tokenId);
        if(setTokenURI(tokenId, tokenuRI)==true){
        INFMMint(address(INFMController(address(_SController))._getMinting()))._updateBNFTAmount(to);
        emit Mint(to, tokenId);
        emit Transfer(address(0), to, tokenId);
        }
    }
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) public returns(bytes4){
        return _INTERFACE_ID_ERC721_RECEIVER;
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (isContract(to)==true) {
            try ERC721TokenReceiver(to).onERC721Received(to, from, tokenId, data) returns (bytes4 retval) {
                if (retval != ERC721TokenReceiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
    
    function withdrawOwner(address to, uint typ) payable public returns (bool){
        require(_owner == msg.sender,"oO");
        if(typ==0){
            payable(address(to)).transfer(address(this).balance);
        }else{
            payable(address(to)).transfer(typ);
        }
        return true;
    } 
    
}