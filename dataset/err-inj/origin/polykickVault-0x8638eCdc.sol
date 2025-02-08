// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.19;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: Projects/PolyKick/Contracts/Polykick_V2/Polykick_Vault_V1.sol



// Polykick Vault V1

pragma solidity 0.8.19;


contract polykickVault {
    address public owner;
    address public ILO;

    uint256 private operationID;
    uint256 public constant oneMonth = 30 days;

    /* @dev: Check if contract owner */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner!");
        _;
    }

    /* @dev: Check if ILO contract */
    modifier onlyILO() {
        require(ILO != address(0), "Set ILO");
        require(msg.sender == ILO, "Not ILO!");
        _;
    }


    struct Vault {
        uint256 operationID;
        address owner;
        IERC20 token;
        uint256 tokenAmount;
        uint256 unclaimed;
        uint256 claimed;
        uint256 timeLock;
        bool firstClaim;
    }

    struct BuyerInfo {
        uint256 lockedAmount;
        uint256 claimedAmount;
        uint256 timeLeftForFirstClaim;
        uint256 timeLeftForAllClaims;
    }

    // mapping(address => bool) public isAdmin;
    mapping(uint256 => Vault) public buyers;
    mapping(uint256 => Vault) public sellers;
    mapping(address => uint256[]) public operationIDs;
    mapping(IERC20 => uint256) public tradingStart;

    event buyerVaultDeposit(
        uint256 operationID,
        address buyer,
        IERC20 token,
        uint256 amount,
        uint256 daysLocked
    );
    event sellerVaultDeposit(
        uint256 operationID,
        address seller,
        IERC20 token,
        uint256 amount
    );
    event iloChanged(address indexed oldILO, address indexed newILO);
    event ChangeOwner(address newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0x0), "Zero address");
        emit ChangeOwner(_newOwner);
        owner = _newOwner;
    }

    function setILO(address _ILO) external onlyOwner {
        require(_ILO != address(0), "Address zero!");
        emit iloChanged(ILO, _ILO);
        ILO = _ILO;
    }

    function tradingStarted(IERC20 _token) external onlyOwner{
        require(tradingStart[_token] == 0, "Trading has started");
        tradingStart[_token] = block.timestamp;
    }

    function depositToBuyerVault(
        address _buyer,
        IERC20 _token,
        uint256 _amount,
        uint256 _lockDays
    ) external onlyILO {
        operationID++;
        operationIDs[_buyer].push(operationID);
        buyers[operationID] = Vault(
            operationID,
            _buyer,
            _token,
            _amount, // tokenAmount
            _amount, // unclaimed
            0, // claimed
            (_lockDays * 1 days) /*+ block.timestamp*/,
            false
        );
        emit buyerVaultDeposit(operationID, _buyer, _token, _amount, _lockDays);
    }

    function depositToSellerVault(
        address _seller,
        IERC20 _token,
        uint256 _amount
    ) external onlyILO {
        operationID++;
        operationIDs[_seller].push(operationID);
        sellers[operationID] = Vault(
            operationID,
            _seller,
            _token,
            _amount,
            _amount,
            0,
            0,
            false
        );
        emit sellerVaultDeposit(operationID, _seller, _token, _amount);
    }

    function withdrawFromBuyerVault(address _buyer, IERC20 _token) external {
        uint256 startOfLock = tradingStart[_token];
        require(startOfLock != 0, "Trading start not set for token");
        uint256 buyerLock = 0;
        uint256[] memory ids = operationIDs[_buyer];
        for (uint256 i = 0; i < ids.length; i++) {
            Vault storage vault = buyers[ids[i]];
            buyerLock = vault.timeLock + startOfLock;
            if (vault.claimed == vault.tokenAmount) {
                revert("All buyer tokens claimed");
            }
            if (vault.token == _token) {
                require(
                    block.timestamp >= buyerLock - oneMonth,
                    "First claim not due!"
                );

                uint256 withdrawableAmount;
                if (block.timestamp >= buyerLock) {
                    // If the full time lock has passed, allow the owner to withdraw all tokens
                    withdrawableAmount = vault.unclaimed;
                } else {
                    require(!vault.firstClaim, "Second claim not due!");
                    // If only half the time lock has passed, allow the owner to withdraw half the tokens
                    withdrawableAmount = vault.unclaimed / 2;
                    vault.firstClaim = true;
                }

                require(
                    vault.token.balanceOf(address(this)) >= withdrawableAmount,
                    "Not enough tokens in contract!"
                );

                vault.unclaimed -= withdrawableAmount;
                vault.claimed += withdrawableAmount;
                vault.token.transfer(vault.owner, withdrawableAmount);

                return;
            }
        }
        revert("No vault found for this token!");
    }

    function withdrawFromSellerVault(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        uint256[] memory ids = operationIDs[_to];
        for (uint256 i = 0; i < ids.length; i++) {
            Vault storage vault = sellers[ids[i]];
            if (vault.claimed == vault.tokenAmount) {
                revert("All seller tokens claimed");
            }
            if (vault.token == _token) {
                require(
                    vault.token.balanceOf(address(this)) >= _amount,
                    "Not enough tokens in contract!"
                );

                vault.unclaimed -= _amount;
                vault.claimed += _amount;
                vault.token.transfer(vault.owner, _amount);
                return;
            }
        }
        revert("No vault found for this token!");
    }

    // View address vault per operation ID
    function getVaultsForAddress(address _address)
        public
        view
        returns (Vault[] memory)
    {
        uint256[] memory ids = operationIDs[_address];
        Vault[] memory vaults = new Vault[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            if (buyers[id].owner == _address) {
                vaults[i] = buyers[id];
            } else if (sellers[id].owner == _address) {
                vaults[i] = sellers[id];
            }
        }

        return vaults;
    }

    function getBuyerInfo(address _buyer, address _token)
        public
        view
        returns (BuyerInfo[] memory)
    {
        uint256[] memory ids = operationIDs[_buyer];
        BuyerInfo[] memory buyerInfos = new BuyerInfo[](ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            Vault storage vault = buyers[ids[i]];

            if (vault.token == IERC20(_token)) {
                BuyerInfo memory buyerInfo;

                buyerInfo.lockedAmount = vault.unclaimed;
                buyerInfo.claimedAmount = vault.claimed;

                if (vault.firstClaim) {
                    buyerInfo.timeLeftForFirstClaim = 0; // Already claimed
                } else {
                    if (block.timestamp >= vault.timeLock - oneMonth) {
                        buyerInfo.timeLeftForFirstClaim = 0; // Can claim now
                    } else {
                        buyerInfo.timeLeftForFirstClaim =
                            (vault.timeLock - oneMonth) -
                            block.timestamp; // Time left for the first claim
                    }
                }

                if (block.timestamp >= vault.timeLock) {
                    buyerInfo.timeLeftForAllClaims = 0; // Can claim all now
                } else {
                    buyerInfo.timeLeftForAllClaims =
                        vault.timeLock -
                        block.timestamp; // Time left for all claims
                }

                buyerInfos[i] = buyerInfo;
            }
        }

        return buyerInfos;
    }
}

                /*********************************************************
                    Proudly Developed by Jaafar Krayem Copyright 2023
                **********************************************************/