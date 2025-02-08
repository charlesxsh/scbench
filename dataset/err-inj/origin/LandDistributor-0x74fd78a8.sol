// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18 <0.9.0;


//import "../utils/Context.sol";
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//import "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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


//import "./Common/IMintable.sol";
//--------------------------------------------
// Mintable interface
//--------------------------------------------
interface IMintable {
    //----------------
    // write
    //----------------
    function mintByMinter( uint256 mintBlockId, address to, uint256 mintIdFrom, uint256 mintIdTo ) external;
}


//import "./Common/IAirdrop.sol";
//--------------------------------------------
// AIRDROP intterface
//--------------------------------------------
interface IAirdrop {
    //--------------------
    // function
    //--------------------
    function getTotal() external view returns (uint256);
    function getPackedDataAt( uint256 at ) external view returns (uint256);
}



//------------------------------------------------------------
// LandDistributor
//------------------------------------------------------------
contract LandDistributor is Ownable {
    //--------------------------------------------------------
    // constant
    //--------------------------------------------------------
    address constant public LAND_ADDRESS = 0x3196EC0a2434bb8c5F84b44f7c0EeAEe0F9A99b4;
    uint256 constant public MINT_BLOCK_ID = 20230829;

    //--------------------------------------------------------
    // storage
    //--------------------------------------------------------
    address private _agent;

    address private _list;
    uint256 private _token_id_ofs;
    uint256 private _total_supply;

    uint256 private _cur_at;
    uint256 private _cur_done;
    uint256 private _total_minted;

    //--------------------------------------------------------
    // [modifier] onlyOwnerOrAgent
    //--------------------------------------------------------
    modifier onlyOwnerOrAgent() {
        require( msg.sender == owner() || msg.sender == agent(), "caller is not the owner neither the agent" );
        _;
    }

    //--------------------------------------------------------
    // constructor
    //--------------------------------------------------------
    constructor() Ownable() {
        _agent = 0xfCf358686Faa2FDb776BC62D970Cde01cDEec7fC;
    }

    //--------------------------------------------------------
    // [public] agent
    //--------------------------------------------------------
    function agent() public view returns (address) {
        return( _agent );
    }

    //--------------------------------------------------------
    // [external/onlyOwner] setAgent
    //--------------------------------------------------------
    function setAgent( address target ) external onlyOwner {
        _agent = target;
    }

    //--------------------------------------------------------
    // [external] get
    //--------------------------------------------------------
    function getList() external view returns (address) { return( _list ); }
    function getPackedDataAt( uint256 at ) external view returns (uint256) { return( IAirdrop(_list).getPackedDataAt( at ) ); }
    function getTokenIdOfs() external view returns( uint256 ){ return( _token_id_ofs ); }
    function getTotalSupply() external view returns( uint256 ){ return( _total_supply ); }

    function getCurAt() external view returns( uint256 ){ return( _cur_at ); }
    function getCurDone() external view returns( uint256 ){ return( _cur_done ); }
    function getTotalMinted() external view returns( uint256 ){ return( _total_minted ); }

    //--------------------------------------------------------
    // [external/onlyOwnerOrAgent] registerList
    //--------------------------------------------------------
    function registerList( address list, uint256 idOfs, uint256 total ) external onlyOwnerOrAgent {
        require( _list == address(0x0), "registerList: already registered" );
        require( list != address(0x0), "registerList: invalid list" );

        IAirdrop drop = IAirdrop( list );

        uint256 numData = drop.getTotal();
        uint256 packedData;
        uint256 totalMint;
        uint256 temp;
        for( uint256 i=0; i<numData; i++ ){
            packedData = drop.getPackedDataAt( i );

            temp = packedData & 0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            require( temp != 0, "registerList: 0x0 address found" );

            temp = uint256(packedData>>160);
            require( temp > 0, "registerList: 0 amount found" );
            totalMint += temp;
        }

        require( total == totalMint, "registerList: invalid total" );

        _list = list;
        _token_id_ofs = idOfs;
        _total_supply = total;

        _cur_at = 0;
        _cur_done = 0;
        _total_minted = 0;
    }

    //--------------------------------------------------------
    // [external/onlyOwnerOrAgent] unregisterList
    //--------------------------------------------------------
    function unregisterList() external onlyOwnerOrAgent {
        require( _list != address(0x0), "unregisterList: not registetred" );
        _list = address(0x0);
        _token_id_ofs = 0;
        _total_supply = 0;

        _cur_at = 0;
        _cur_done = 0;
        _total_minted = 0;
    }

    //--------------------------------------------------------
    // [external/onlyOwnerOrAgent] setStatus
    //--------------------------------------------------------
    function setStatus( uint256 curAt, uint256 curDone, uint256 totalMinted ) external onlyOwnerOrAgent {
        require( _list != address(0x0), "setStatus: not registetred" );
        require( totalMinted <= _total_supply, "setStatus: invalid totalMinted" );

        IAirdrop drop = IAirdrop( _list );
        uint256 numData = drop.getTotal();
        require( curAt <= numData, "setStatus: invalid curAt" );

        if( totalMinted == _total_supply ){          
            require( curAt == numData, "setStatus: invalid curAt(finished)" );
            require( curDone == 0, "setStatus: invalid curDone(finished)" );
        }else{
            require( curAt < numData, "setStatus: invalid curAt(not finishhed)" );

            uint256 packedData;
            uint256 numMint;
            uint256 temp;
            for( uint256 i=0; i<curAt; i++ ){
                packedData = drop.getPackedDataAt( i );
                temp += uint256(packedData>>160);
            }

            packedData = drop.getPackedDataAt( curAt );
            numMint = uint256(packedData>>160);
            require( curDone < numMint, "setStatus: invalid curDone(not finishhed)" );

            temp += curDone;
            require( totalMinted == temp, "setStatus: invalid totalMinted(not finishhed)" );
        }

        _cur_at = curAt;
        _cur_done = curDone;
        _total_minted = totalMinted;
    }

    //--------------------------------------------------------
    // [external/onlyOwnerOrAgent] airdrop
    //--------------------------------------------------------
    function airdrop( uint256 num ) external onlyOwnerOrAgent {
        require( _list != address(0x0), "airdrop: not registered" );
        require( (_total_minted+num) <= _total_supply, "airdrop: invalid num" );

        IAirdrop drop = IAirdrop( _list );
        uint256 numData = drop.getTotal();
        uint256 packedData;
        uint256 numMint;
        uint256 temp;
        uint256 tokenId = _token_id_ofs + _total_minted;
        IMintable land = IMintable( LAND_ADDRESS );
        for( uint256 i=_cur_at; i<numData; i++ ){
            packedData = drop.getPackedDataAt( i );
            numMint = uint256(packedData>>160);

            if( numMint < (_cur_done+num) ){
                temp = numMint - _cur_done;
            }else{
                temp = num;
            }

            land.mintByMinter( MINT_BLOCK_ID, address(uint160(packedData&0x000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)), tokenId, tokenId+temp-1 );
            _total_minted += temp;

            if( numMint <= (_cur_done+temp) ){
                _cur_done = 0;
                _cur_at++;
            }else{
                _cur_done += temp;
            }

            if( num <= temp ){
                break;
            }

            num -= temp;
            tokenId += temp;
        }
    }

}