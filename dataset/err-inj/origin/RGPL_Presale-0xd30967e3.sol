//SPDX-License-Identifier: MIT Licensed
pragma solidity 0.8.19;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract RGPL_Presale {
    using SafeMath for uint256;

    IToken public saleToken =
        IToken(0xD4fD2c744Ea8B867Cfee008D2b8CDfDF01aAc43d);
    IToken public USDT = IToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    AggregatorV3Interface public priceFeedEth;

    address payable public owner;

    uint256 public tokenPerUsd = 35714000000; //35.714 tokens for $1
    uint256 public preSaleStartTime;
    uint256 public soldToken;
    uint256 public amountRaisedEth;
    uint256 public amountRaisedUSDT;
    uint256 public minimumDollar = 1000000; //min buy USDT 500
    uint256 public minimumETH = 0.00060 ether; //min buy eth
    uint256 public constant divider = 100;

    bool public presaleStatus;
    bool public isWhitelistOpen = false;

    struct user {
        uint256 Eth_balance;
        uint256 usdt_balance;
        uint256 token_balance;
    }

    mapping(address => user) public users;
    mapping(address => bool) public whitelist;

    modifier onlyOwner() {
        require(msg.sender == owner, "PRESALE: Not an owner");
        _;
    }

    // modifier onlyWhitelisted() {
    //     require(
    //         isWhitelistOpen && whitelist[msg.sender],
    //         "User not whitelisted"
    //     );
    //     _;
    // }

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event WithdrawTokens(
        address indexed _token,
        address indexed _to,
        uint256 _amount
    );

    constructor() {
        owner = payable(0x043eAC2ac2C14C4809Ea096c917eD3D0830dEf6E);
        priceFeedEth = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        preSaleStartTime = block.timestamp;
        presaleStatus = true;
    }

    receive() external payable {
        buyTokenEth();
    }

    // to get real time price of Eth
    function getLatestPriceEth() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedEth.latestRoundData();
        return uint256(price);
    }

    function toggleWhitelist(bool _isOpen) public onlyOwner {
        isWhitelistOpen = _isOpen;
    }

    function addToWhitelist(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory _users) public onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = false;
        }
    }

    // to buy token during preSale time with Eth => for web3 use

    function buyTokenEth() public payable {
        require(presaleStatus == true, "Presale : Presale is finished");
        require(msg.value >= minimumETH, "Presale : Unsuitable Amount");
        require(soldToken <= tokenForSale(), "All Sold");

        if (isWhitelistOpen) {
            require(whitelist[msg.sender], " you are not whitelisted");
        }

        uint256 numberOfTokens;
        numberOfTokens = EthToToken(msg.value);
        saleToken.transferFrom(owner, msg.sender, numberOfTokens);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedEth = amountRaisedEth + (msg.value);
        users[msg.sender].Eth_balance =
            users[msg.sender].Eth_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    function reserSoldTokensAmount() external onlyOwner {
        soldToken = 0;
        }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(presaleStatus == true, "Presale : Presale is finished");
        require(amount >= minimumDollar, "Minimum Amount is $1");
        require(soldToken <= tokenForSale(), "All Sold");

        if (isWhitelistOpen) {
            require(whitelist[msg.sender], " you are not whitelisted");
        }

        USDT.transferFrom(msg.sender, address(this), amount);

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount);

        saleToken.transferFrom(owner, msg.sender, numberOfTokens);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedUSDT = amountRaisedUSDT + (amount);
        users[msg.sender].usdt_balance =
            users[msg.sender].usdt_balance +
            (amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
    }

    // to check percentage of token sold
    function getProgress() public view returns (uint256 _percent) {
        uint256 remaining = tokenForSale() -
            (soldToken / (10 ** (saleToken.decimals())));
        remaining = (remaining * (divider)) / (tokenForSale());
        uint256 hundred = 100;
        return hundred - (remaining);
    }

    function stopPresale(bool state) external onlyOwner {
        presaleStatus = state;
    }

    // to check number of token for given Eth
    function EthToToken(uint256 _amount) public view returns (uint256) {
        uint256 EthToUsd = (_amount * (getLatestPriceEth())) / (1e18);
        uint256 numberOfTokens = (EthToUsd * (tokenPerUsd)) / (1e8);
        return numberOfTokens;
    }

    // to check number of token for given usdt
    function usdtToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (tokenPerUsd)) / (1e6);
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _price) external onlyOwner {
        tokenPerUsd = _price;
    }

    // to change preSale time duration
    function setPreSaleTime(uint256 _startTime) external onlyOwner {
        preSaleStartTime = _startTime;
    }

    // transfer ownership
    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // change tokens
    function changeToken(address _token) external onlyOwner {
        saleToken = IToken(_token);
    }

    // change minimum buy
    function changeMinimumLimits(
        uint256 _inDollar,
        uint256 _inEth
    ) external onlyOwner {
        minimumDollar = _inDollar;
        minimumETH = _inEth;
    }

    //change USDT
    function changeUSDT(address _USDT) external onlyOwner {
        USDT = IToken(_USDT);
    }

    // to draw funds for liquidity
    function transferFundsEth(uint256 _value) external onlyOwner {
        owner.transfer(_value);
    }

    // to draw out tokens
    function transferTokens(IToken token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to get contract Eth balance
    function contractBalanceEth() external view returns (uint256) {
        return address(this).balance;
    }

    //to get contract USDT balance
    function contractBalanceUSDT() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    // to get contract token balance
    function getContractTokenApproval() external view returns (uint256) {
        return saleToken.allowance(owner, address(this));
    }

    function tokenForSale() public view returns (uint) {
        return saleToken.allowance(owner, address(this));
    }

    function tokensToEther(uint256 tokenAmount) public view returns (uint256) {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        uint256 ethEquivalent = (tokenAmount * 1e18) / EthToToken(1e18);
        return ethEquivalent;
    }

    function withdrawTokens(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        IToken token = IToken(tokenAddress);
        if (presaleStatus) {
            // Sale is active, do not allow withdrawals
            revert("Cannot withdraw tokens during active sale");
        } else {
            uint256 contractBalance = token.balanceOf(address(this));
            require(
                contractBalance >= amount,
                "Insufficient token balance in contract"
            );

            token.transfer(owner, amount);
            emit WithdrawTokens(tokenAddress, owner, amount);
        }
    }
}