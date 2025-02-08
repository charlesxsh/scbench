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

// File: Projects/PolyKick/Contracts/Polykick_V2/Polykick_ILO_V2.sol



/* Polykick ILO V2 */

pragma solidity 0.8.19;


interface polyFactory {
    function polyKickDAO() external view returns (address);

    function allowedCurrencies(IERC20 _token)
        external
        view
        returns (string memory, uint8);
}

interface polyVault {
    function depositToBuyerVault(
        address,
        IERC20,
        uint256,
        uint256
    ) external;

    function depositToSellerVault(
        address,
        IERC20,
        uint256
    ) external;

    function withdrawFromBuyerVault(address, IERC20) external;
}

contract PolyKick_ILO {
    polyFactory public factoryContract;
    polyVault public vaultContract;

    address public constant burn = 0x000000000000000000000000000000000000dEaD;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    uint256 earlySale;

    IERC20 public token;
    uint8 public tokenDecimals;
    uint256 public tokenAmount;
    IERC20 public currency;
    uint8 public currencyDecimals;
    uint256[] public prices;
    uint256[] public amountLimits;
    uint256[] public phaseSoldAmounts;
    uint256 public maxPrices;
    uint256 public softCap;
    uint256 public duration;
    uint256 public startTime;
    uint256 public maxAmount;
    uint256 public minAmount;
    uint256 public maxC;
    uint256 public minC;
    uint256 public salesCount;
    uint256 public buyersCount;

    address public seller;
    address public polyWallet;
    address public polyKickDAO;

    uint256 public sellerVault;
    uint256 public soldAmounts;
    uint256 public notSold;
    uint256 public tokensBurned;
    uint256 public raisedAmount;

    uint256 private pkPercentage;
    uint256 private toPolykick;
    uint256 private toExchange;
    uint256 public percentageToLock = 30;
    uint256 public sellerPercentageToLock = 90;

    bool public success = false;
    bool public canceled = false;
    bool public fundsReturn = false;
    bool public isPreInitiated = false;
    bool public isInitiated = false;
    bool public isWhitelistRequired = false;

    address[] public buyersList;

    struct buyerVault {
        uint256 tokenAmount;
        uint256 currencyPaid;
        uint256 txCount;
        bool isClaimed;
    }

    mapping(address => bool) public isWhitelisted;
    mapping(address => buyerVault) public buyer;
    mapping(address => bool) public isBuyer;
    mapping(address => bool) public isAdmin;

    event iloInitiated(bool status);
    event approveILO(string Result);
    event successfulILO(
        string Results,
        uint256 TokensSold,
        uint256 TokensRemaining,
        uint256 TokensBurned,
        uint256 RaisedAmount
    );
    event tokenSale(uint256 CurrencyAmount, uint256 TokenAmount);
    event tokenWithdraw(address indexed buyer, uint256 amount);
    event CurrencyReturned(address Buyer, uint256 Amount);
    event discountSet(uint256 Discount, bool Status);
    event whiteList(address Buyer, bool Status);

    /* @dev: Check if Admin */
    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == true, "Not Admin!");
        _;
    }
    /* @dev: Check if contract owner */
    modifier onlyOwner() {
        require(msg.sender == polyWallet, "Not Owner!");
        _;
    }

    /*
    @dev: prevent reentrancy when function is executed
*/
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor(
        address _factory,
        address _seller,
        address _polyKick,
        IERC20 _token,
        uint8 _tokenDecimals,
        uint256 _tokenAmount,
        IERC20 _currency,
        uint256 _price,
        uint256 _softCap,
        uint256 _pkPercentage,
        uint256 _toPolykick,
        uint256 _toExchange
    ) {
        factoryContract = polyFactory(_factory);
        seller = _seller;
        polyWallet = _polyKick;
        token = _token;
        tokenDecimals = _tokenDecimals;
        tokenAmount = _tokenAmount;
        currency = _currency;
        prices.push(_price);
        softCap = _softCap;
        pkPercentage = _pkPercentage;
        toPolykick = _toPolykick;
        toExchange = _toExchange;
        _status = _NOT_ENTERED;
        notSold = _tokenAmount;
        isAdmin[polyWallet] = true;
    }

    function setPrices(uint256[] memory _prices, uint256[] memory _amountLimits)
        external
        onlyAdmin
    {
        require(isPreInitiated == true, "Pre Initiate required");
        require(
            _prices.length == _amountLimits.length + 1,
            "The length of amountLimits must be one less than the length of prices"
        );
        require(_prices.length <= maxPrices, "Max Prices reached");

        // Calculate the sum of _amountLimits
        uint256 totalLimits = 0;
        for (uint256 i = 0; i < _amountLimits.length; i++) {
            totalLimits += _amountLimits[i];
        }

        // Calculate the final amountLimit
        uint256 finalLimit = tokenAmount - totalLimits;

        // Append finalLimit to the _amountLimits array
        uint256[] memory newAmountLimits = new uint256[](
            _amountLimits.length + 1
        );
        for (uint256 i = 0; i < _amountLimits.length; i++) {
            newAmountLimits[i] = _amountLimits[i];
        }
        newAmountLimits[newAmountLimits.length - 1] = finalLimit;

        // Update the prices and amountLimits state variables
        prices = _prices;
        amountLimits = newAmountLimits;

        for (uint256 i = 0; i < prices.length; i++) {
            phaseSoldAmounts.push(0);
        }
    }

    function updateCurrentPrice(uint256 _newPrice) external onlyAdmin {
        uint256 oldPrice = getPrice();
        uint256 priceIndex = getPhase();

        // Ensure the new price is within the specified range
        require(
            _newPrice >= (oldPrice * 97) / 100 &&
                _newPrice <= (oldPrice * 110) / 100,
            "New price must be within 3% lower and 10% higher than the old price"
        );

        prices[priceIndex] = _newPrice;
    }

    function preInitiateILO(
        uint256 _min,
        uint256 _max,
        uint256 _maxPrices, // price rounds
        uint256 _percentageToLock,
        address _vault,
        bool _isWhitelistRequired
    ) external onlyAdmin {
        require(!isInitiated, "ILO initiated");
        polyKickDAO = factoryContract.polyKickDAO();
        setCurrencyDecimals();
        minBuyMax(_min, _max, prices[0], currencyDecimals);
        maxPrices = _maxPrices;
        percentageToLock = _percentageToLock;
        isWhitelistRequired = _isWhitelistRequired;
        vaultContract = polyVault(_vault);
        isPreInitiated = true;
    }

    function initiateILO(uint256 _days, uint256 _sellerPercentageToLock) external onlyAdmin {
        require(!canceled, "ILO was canceled");
        require(isPreInitiated == true, "PreInitiate first");
        require(prices.length == maxPrices, "set prices");
        duration = (_days * 1 days) + block.timestamp;
        startTime = block.timestamp;
        sellerPercentageToLock = _sellerPercentageToLock;
        isInitiated = true;
        emit iloInitiated(isInitiated);
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startTime;
        uint256 phaseDuration = duration / prices.length;

        for (uint256 i = 0; i < prices.length; i++) {
            // Move to the next phase if the time has elapsed or the amount limit has been reached for the current phase
            if (
                timeElapsed >= (i + 1) * phaseDuration ||
                phaseSoldAmounts[i] >= amountLimits[i]
            ) {
                continue; // Skip to the next iteration of the loop
            }

            // If none of the above conditions are met, then return the price of the current phase
            return prices[i];
        }

        // If no price was returned in the loop, return the last price
        return prices[prices.length - 1];
    }

    function getAllPrices() public view returns (uint256[] memory) {
        return prices;
    }

    function getPhase() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startTime;
        uint256 phaseDuration = duration / prices.length;

        for (uint256 i = 0; i < prices.length; i++) {
            if (
                timeElapsed >= (i + 1) * phaseDuration ||
                phaseSoldAmounts[i] >= amountLimits[i]
            ) {
                continue; // Skip to the next iteration of the loop
            }

            return i;
        }
        return prices.length - 1; // return last phase if none of the conditions are met
    }

    function addAdmin(address _newAdmin) external onlyOwner {
        require(_newAdmin != address(0), "Adrs 0!");
        require(!isAdmin[_newAdmin], "Admin exist");
        isAdmin[_newAdmin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(isAdmin[_admin], "No admin");
        isAdmin[_admin] = false;
    }

    function setPolyDAO(address _DAO) external onlyOwner {
        require(_DAO != address(0), "Adrs 0");
        polyKickDAO = _DAO;
    }

    function setPolyVault(address _vault) external onlyOwner {
        require(_vault != address(0), "Adrs 0");
        vaultContract = polyVault(_vault);
    }

    function isActive() public view returns (bool) {
        if (duration < block.timestamp) {
            return false;
        } else {
            return true;
        }
    }

    function minBuyMax(
        uint256 minAmt,
        uint256 maxAmt,
        uint256 _price,
        uint8 _dcml
    ) internal {
        uint256 min = minAmt * 10**_dcml;
        uint256 max = maxAmt * 10**_dcml;
        minAmount = (min / _price) * 10**tokenDecimals;
        maxAmount = (max / _price) * 10**tokenDecimals;
        minC = minAmt;
        maxC = maxAmt;
    }

    function setCurrencyDecimals() internal {
        (, uint8 returnedDecimals) = factoryContract.allowedCurrencies(
            currency
        );
        currencyDecimals = returnedDecimals;
    }

    function getRaised() public view returns (uint256 _raised) {
        if (sellerVault != 0) {
            _raised = sellerVault / (10**currencyDecimals);
        } else {
            _raised = raisedAmount / (10**currencyDecimals);
        }
        return _raised;
    }

    function iloInfo()
        public
        view
        returns (
            uint256 tokensSold,
            uint256 tokensRemaining,
            uint256 burned,
            uint256 sales,
            uint256 participants,
            uint256 raised
        )
    {
        if (tokensBurned != 0) {
            burned = tokensBurned / (10**tokenDecimals);
        } else {
            burned = 0;
        }
        raised = getRaised();
        if (raised == 0) {
            raised = raisedAmount / (10**currencyDecimals);
        }
        return (
            soldAmounts / (10**tokenDecimals),
            notSold / (10**tokenDecimals),
            burned,
            salesCount,
            buyersCount,
            raised
        );
    }

    function addToWhiteList(address[] memory _allowed) external onlyAdmin {
        for (uint256 i = 0; i < _allowed.length; i++) {
            require(_allowed[i] != address(0x0), "Adrs 0");
            isWhitelisted[_allowed[i]] = true;
        }
    }

    function extendILO(uint256 _duration) external onlyAdmin {
        require(duration != 0, "ILO ended");
        fundsReturn = true;
        duration = _duration + block.timestamp;
    }

    function isSoftCap() public view returns (bool) {
        if (soldAmounts < softCap) {
            return true;
        } else {
            return false;
        }
    }

    function buyTokens(uint256 _amountToPay, bool isSigned)
        external
        nonReentrant
    {
        require(isSigned == true, "Sign message"); // When set to true it means that user accept the lock of 30%
        if (isWhitelistRequired == true) {
            require(isWhitelisted[msg.sender] == true, "Not whitelisted");
        }
        require(isActive(), "ILO not active!");

        uint256 amount = _amountToPay * 10**tokenDecimals;
        uint256 finalAmount;

        finalAmount = amount / getPrice(); //pricePerToken;
        require(
            buyer[msg.sender].tokenAmount + finalAmount <= maxAmount,
            "Limit reached"
        );
        if (buyer[msg.sender].txCount == 0) {
            require(finalAmount >= minAmount, "under minimum");
        }
        require(finalAmount <= maxAmount, "over maximum");

        emit tokenSale(_amountToPay, finalAmount);
        require(
            currency.allowance(msg.sender, address(this)) >= _amountToPay,
            "currency allowance"
        );
        require(
            currency.transferFrom(msg.sender, address(this), _amountToPay),
            "currency balance"
        );
        uint256 currentPhase = getPhase();
        phaseSoldAmounts[currentPhase] += finalAmount;
        sellerVault += _amountToPay;
        buyer[msg.sender].tokenAmount += finalAmount;
        buyer[msg.sender].currencyPaid += _amountToPay;
        soldAmounts += finalAmount;
        notSold -= finalAmount;
        if (isBuyer[msg.sender] != true) {
            isBuyer[msg.sender] = true;
            buyersList.push(msg.sender);
            buyersCount++;
        }
        salesCount++;
        buyer[msg.sender].txCount++;
    }

    function iloApproval() external onlyAdmin {
        require(!isActive(), "ILO not ended!");
        if (soldAmounts >= softCap) {
            duration = 0;
            success = true;
            tokensBurned = notSold;
            token.transfer(burn, notSold);
            emit successfulILO(
                "ILO Succeed",
                soldAmounts,
                notSold,
                tokensBurned,
                sellerVault
            );
        } else {
            duration = 0;
            success = false;
            fundsReturn = true;
            sellerVault = 0;
            emit approveILO("ILO Failed");
        }
    }

    function succeedILO() external onlyAdmin {
        uint256 tenPercent = (softCap * 10) / 100;
        require(soldAmounts >= softCap - tenPercent, "softCap not reached");
        duration = 0;
        success = true;
        tokensBurned = notSold;
        token.transfer(burn, notSold);
        emit successfulILO(
            "ILO Succeed",
            soldAmounts,
            notSold,
            tokensBurned,
            sellerVault
        );
    }

    function setMinMax(uint256 _minAmount, uint256 _maxAmount)
        external
        onlyAdmin
    {
        minBuyMax(_minAmount, _maxAmount, getPrice(), currencyDecimals);
    }

    function withdrawTokens(address _buyer) public nonReentrant {
        require(isBuyer[_buyer] == true, "Not a Buyer");
        require(success == true, "ILO Failed");
        uint256 buyerAmount = (buyer[_buyer].tokenAmount * 70) / 100;
        uint256 thirtyPercent = buyer[_buyer].tokenAmount - buyerAmount;
        emit tokenWithdraw(_buyer, buyerAmount);
        token.transfer(_buyer, buyerAmount);
        token.transfer(address(vaultContract), thirtyPercent);
        vaultContract.depositToBuyerVault(_buyer, token, thirtyPercent, 60);
        buyer[_buyer].tokenAmount = 0;
        isBuyer[_buyer] = false;
        buyer[_buyer].isClaimed = true;
    }

    function returnFunds(address _buyer) public nonReentrant {
        require(isBuyer[_buyer] == true, "Not Buyer");
        require(success == false && fundsReturn == true, "ILO Succeed!");
        uint256 buyerAmount = buyer[_buyer].currencyPaid;
        emit CurrencyReturned(_buyer, buyerAmount);
        currency.transfer(_buyer, buyerAmount);
        buyer[_buyer].currencyPaid -= buyerAmount;
        buyer[_buyer].tokenAmount = 0;
        isBuyer[_buyer] = false;
        buyer[_buyer].isClaimed = true;
    }

    function distributeTokens(uint256 start, uint256 end) external onlyAdmin {
        require(end <= buyersList.length, "Beyond range");
        require(start <= end, "Invalid range");

        if (success == true) {
            for (uint256 i = start; i < end; i++) {
                address _buyer = buyersList[i];
                if (
                    isBuyer[_buyer] == true && buyer[_buyer].isClaimed == false
                ) {
                    withdrawTokens(_buyer);
                }
            }
        } else if (fundsReturn == true) {
            for (uint256 i = start; i < end; i++) {
                address _buyer = buyersList[i];
                if (
                    isBuyer[_buyer] == true && buyer[_buyer].isClaimed == false
                ) {
                    returnFunds(_buyer);
                }
            }
        }
    }

    function vaultWithdraw() external {
        vaultContract.withdrawFromBuyerVault(msg.sender, token);
    }

    function sellerWithdraw() external nonReentrant {
        require(msg.sender == seller, "Not seller");
        require(!isActive(), "ILO active!");
        if (success == true) {
            require(sellerVault != 0, "claimed!");
            raisedAmount = sellerVault;
            uint256 polyKickAmount = (sellerVault * pkPercentage) / 100;
            uint256 totalPolykick = polyKickAmount + toPolykick;
            uint256 sellerAmount = sellerVault - totalPolykick - toExchange;
            uint256 toLockVault = (sellerAmount * sellerPercentageToLock) / 100;
            uint256 finalSellerAmount = sellerAmount - toLockVault;
            if (toExchange > 0) {
                currency.transfer(polyWallet, toExchange);
            }
            currency.transfer(polyKickDAO, polyKickAmount);
            currency.transfer(polyKickDAO, toPolykick);
            currency.transfer(address(vaultContract), toLockVault);
            vaultContract.depositToSellerVault(
                msg.sender,
                currency,
                toLockVault
            );
            currency.transfer(seller, finalSellerAmount);
        } else if (success == false) {
            token.transfer(seller, token.balanceOf(address(this)));
        }
        sellerVault = 0;
    }

    function emergencyRefund(uint256 _confirm) external onlyOwner {
        require(success != true, "ILO successful");
        require(isActive(), "ILO ended");
        require(_confirm == 369, "Wrong!");
        success = false;
        fundsReturn = true;
        sellerVault = 0;
        duration = 0;
        emit approveILO("ILO Failed");
    }

    function getBuyerTokenAmounts()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory tokenAmounts = new uint256[](buyersList.length);
        address[] memory buyerAddresses = new address[](buyersList.length);

        for (uint256 i = 0; i < buyersList.length; i++) {
            uint256 _tokenAmount = buyer[buyersList[i]].tokenAmount;
            tokenAmounts[i] = _tokenAmount / (10**tokenDecimals); // Remove 18 decimals
            buyerAddresses[i] = buyersList[i];
        }

        return (buyerAddresses, tokenAmounts);
    }

    function getUnclaimedBalances()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory tokenAmounts = new uint256[](buyersList.length);
        address[] memory buyerAddresses = new address[](buyersList.length);

        for (uint256 i = 0; i < buyersList.length; i++) {
            uint256 _tokenAmount = buyer[buyersList[i]].tokenAmount;
            if (_tokenAmount > 0) {
                tokenAmounts[i] = _tokenAmount / (10**tokenDecimals); // Remove 18 decimals
                buyerAddresses[i] = buyersList[i];
            }
        }

        return (buyerAddresses, tokenAmounts);
    }

    function cancelILO() external onlyOwner{
        require(!isActive(),"ILO is active!");
        token.transfer(polyWallet, tokenAmount);
        canceled = true;
    }

    function getBuyerCurrencyAmounts()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory currencyAmounts = new uint256[](buyersList.length);
        address[] memory buyerAddresses = new address[](buyersList.length);

        for (uint256 i = 0; i < buyersList.length; i++) {
            uint256 _currencyAmount = buyer[buyersList[i]].currencyPaid;
            currencyAmounts[i] = _currencyAmount / (10**currencyDecimals); // Remove 6 decimals
            buyerAddresses[i] = buyersList[i];
        }

        return (buyerAddresses, currencyAmounts);
    }

    /*
   @dev: Withdraw any ERC20 token sent by mistake or extra currency amounts
*/
    function erc20Withdraw(IERC20 _token) external onlyOwner {
        uint256 amountAvailable;
        if (_token == currency) {
            amountAvailable = _token.balanceOf(address(this)) - sellerVault;
            require(amountAvailable > 0, "No extra!");
            _token.transfer(polyWallet, amountAvailable);
        } else if (_token == token) {
            amountAvailable = _token.balanceOf(address(this)) - tokenAmount;
            require(amountAvailable > 0, "No extra!");
            _token.transfer(polyWallet, amountAvailable);
        } else {
            amountAvailable = _token.balanceOf(address(this));
            _token.transfer(polyWallet, amountAvailable);
        }
    }

    /*
   @dev: people who send Matic by mistake to the contract can withdraw them
*/
    mapping(address => uint256) public balanceReceived;

    function wrongSend() public payable {
        assert(
            balanceReceived[msg.sender] + msg.value >=
                balanceReceived[msg.sender]
        );
        balanceReceived[msg.sender] += msg.value;
    }

    function withdrawWrongTransaction(address payable _to, uint256 _amount)
        public
    {
        require(_amount <= balanceReceived[msg.sender], "funds!.");
        assert(
            balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount
        );
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }

    receive() external payable {
        wrongSend();
    }
}

                /*********************************************************
                   Proudly Developed by Jaafar Krayem Copyright 2023
                **********************************************************/

// File: Projects/PolyKick/Contracts/Polykick_V2/IDeployer.sol



/* Polykick deployer interface */

pragma solidity ^0.8.19;


interface IDeployer {
    function _startILO(
        address _factory,
        address _seller,
        address _polyKick,
        IERC20 _token,
        uint8 _tokenDecimals,
        uint256 _tokenAmount,
        IERC20 _currency,
        uint256 _price,
        uint256 _softCap,
        uint256 _pkPercentage,
        uint256 _toPolykick,
        uint256 _toExchange
    ) external returns (address);
}


                /*********************************************************
                  Proudly Developed by Jaafar Krayem Copyright 2023
                **********************************************************/
// File: Projects/PolyKick/Contracts/Polykick_V2/Polykick_Deployer.sol



/* Polykick ILO contract deployer */

pragma solidity ^0.8.19;



contract Deployer is IDeployer {

    address public owner;
    address public factory;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner!");
        _;
    }

    modifier onlyFactory() {
        require(factory != address(0), "Factory is addres 0");
        require(msg.sender == factory, "Not Factory!");
        _;
    }

    function setFactory(address _factory) external onlyOwner{
        require(_factory != address(0), "Zero address");
        factory = _factory;
    }

    function _startILO(
        address _factory,
        address _seller,
        address _polyKick,
        IERC20 _token,
        uint8 _tokenDecimals,
        uint256 _tokenAmount,
        IERC20 _currency,
        uint256 _price,
        uint256 _softCap,
        uint256 _pkPercentage,
        uint256 _toPolykick,
        uint256 _toExchange
    ) external override onlyFactory returns (address) {
        PolyKick_ILO newILO = new PolyKick_ILO(
            _factory,
            _seller,
            _polyKick,
            _token,
            _tokenDecimals,
            _tokenAmount,
            _currency,
            _price,
            _softCap,
            _pkPercentage,
            _toPolykick,
            _toExchange
        );
        return address(newILO);
    }
}

                /*********************************************************
                  Proudly Developed by Jaafar Krayem Copyright 2023
                **********************************************************/