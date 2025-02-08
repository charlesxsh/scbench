// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IVaultInterface {
    function execute(
        address,
        bytes memory
    ) external payable returns (bytes memory);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
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
            uint256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

interface IsparkSavingsInterface {
    function wstETH() external view returns (address);

    function savingsAsset() external view returns (address);

    function getDai() external view returns (address);

    function getGem() external view returns (address);

    function getGemJoin() external view returns (address);
}

contract MakerDaoPSMSparkStakeMonitor {
    using SafeMath for uint256;
    address public owner;
    address public daiStakePool;
    address public makerDaoSparkSavingsStrategy;
    address public chainlinkDaiBaseUSD;
    address public chainlinkUsdcBaseUSD;
    address public DAI;
    address public PSMUSDC;
    address public USDC;

    constructor(address _owner) {
        owner = _owner;
        chainlinkDaiBaseUSD = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
        chainlinkUsdcBaseUSD = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
        makerDaoSparkSavingsStrategy = 0x6Dae9515DEb20F9875B4A383D353a97E0A6815E4; //0x71122Cd26c5f1E18826652708C3e00D1cf837DA4
        PSMUSDC = IsparkSavingsInterface(makerDaoSparkSavingsStrategy)
            .getGemJoin(); //0x0A59649758aa4d66E25f08Dd01271e891fe52199;
        USDC = IsparkSavingsInterface(makerDaoSparkSavingsStrategy).getGem(); //0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        daiStakePool = IsparkSavingsInterface(makerDaoSparkSavingsStrategy)
            .savingsAsset(); //0x83F20F44975D03b1b09e64809B757c47f942BEeA; // sdai
        DAI = IsparkSavingsInterface(makerDaoSparkSavingsStrategy).getDai(); // 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    function setMakerDaoSparkSavingsStrategy(
        address _makerDaoSparkSavingsStrategy
    ) external {
        require(
            msg.sender == owner,
            " only owner set lido spark staked Strategy"
        );
        makerDaoSparkSavingsStrategy = _makerDaoSparkSavingsStrategy;
    }

    function getPSMUSDCLiquidity() public view returns (uint256) {
        uint256 _usdcCash;
        _usdcCash = getTokenBalance(USDC, PSMUSDC);
        return _usdcCash;
    }

    function isPSMUSDCLiquidityInsufficient(
        uint256 _USDCAmountThreshold
    ) public view returns (bool) {
        uint256 _USDCCash;
        _USDCCash = getPSMUSDCLiquidity();
        if (_USDCAmountThreshold >= _USDCCash) {
            return true;
        }
        return false;
    }

    function hasSparkStaked(address _vault) public view returns (bool) {
        uint256 _balance;

        _balance = IERC20(daiStakePool).balanceOf(_vault);

        if (_balance > 0) {
            return true;
        }
        return false;
    }

    function getTokenBalance(
        address underlying,
        address vault
    ) public view returns (uint256) {
        return IERC20(underlying).balanceOf(vault);
    }

    function getPriceChainLink(
        address _chainlinkAggregator
    ) public view returns (uint256) {
        /*
        (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        )
        */
        (, uint256 _price, , , ) = AggregatorV3Interface(_chainlinkAggregator)
            .latestRoundData();
        return _price;
    }

    function getDaiPriceFromChainLink() public view returns (uint256) {
        uint256 _price;
        _price = getPriceChainLink(chainlinkDaiBaseUSD);
        return _price;
    }

    function getUsdcPriceFromChainLink() public view returns (uint256) {
        uint256 _price;
        _price = getPriceChainLink(chainlinkUsdcBaseUSD);
        return _price;
    }

    function isDaiPriceUnanchoredFromChainLink(
        uint256 _anchorPrice
    ) public view returns (bool) {
        /*
        (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        )
        */
        uint256 _price;
        _price = getDaiPriceFromChainLink();
        if (_price <= _anchorPrice) {
            return true;
        }
        return false;
    }

    function isUsdcPriceUnanchoredFromChainLink(
        uint256 _anchorPrice
    ) public view returns (bool) {
        /*
        (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
        )
        */
        uint256 _price;
        _price = getUsdcPriceFromChainLink();
        if (_price <= _anchorPrice) {
            return true;
        }
        return false;
    }

    function encodeExitAllInput()
        internal
        pure
        returns (bytes memory encodedInput)
    {
        return abi.encodeWithSignature("exitAll()");
    }

    function executeExitAll(
        address _vault
    ) public view returns (bool canExec, bytes memory execPayload) {
        bytes memory args = encodeExitAllInput();
        execPayload = abi.encodeWithSelector(
            IVaultInterface(_vault).execute.selector,
            makerDaoSparkSavingsStrategy,
            args
        );
        return (true, execPayload);
    }

    function checker(
        address _vault,
        uint256 _anchorDaiPriceThreshold,
        uint256 _anchorUsdcPriceThreshold,
        uint256 _psmusdcCashThreshold
    ) external view returns (bool canExec, bytes memory execPayload) {
        if (hasSparkStaked(_vault)) {
            if (isDaiPriceUnanchoredFromChainLink(_anchorDaiPriceThreshold)) {
                return executeExitAll(_vault);
            }
            if (isUsdcPriceUnanchoredFromChainLink(_anchorUsdcPriceThreshold)) {
                return executeExitAll(_vault);
            }
            if (isPSMUSDCLiquidityInsufficient(_psmusdcCashThreshold)) {
                return executeExitAll(_vault);
            }
        }
        return (false, bytes("monitor is ok"));
    }
}