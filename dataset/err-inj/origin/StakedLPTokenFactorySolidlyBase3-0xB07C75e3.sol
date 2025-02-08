// File: contracts\libraries\SafeMath.sol

pragma solidity =0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts\ImpermaxERC20.sol

pragma solidity =0.5.16;


// This contract is basically UniswapV2ERC20 with small modifications
// src: https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol

contract ImpermaxERC20 {
	using SafeMath for uint;
	
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint public totalSupply;
	mapping(address => uint) public balanceOf;
	mapping(address => mapping(address => uint)) public allowance;
	
	bytes32 public DOMAIN_SEPARATOR;
	mapping(address => uint) public nonces;
	
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);

	constructor() public {}	
	
	function _setName(string memory _name, string memory _symbol) internal {
		name = _name;
		symbol = _symbol;
		uint chainId;
		assembly {
			chainId := chainid
		}
		DOMAIN_SEPARATOR = keccak256(
			abi.encode(
				keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
				keccak256(bytes(_name)),
				keccak256(bytes("1")),
				chainId,
				address(this)
			)
		);
	}

	function _mint(address to, uint value) internal {
		totalSupply = totalSupply.add(value);
		balanceOf[to] = balanceOf[to].add(value);
		emit Transfer(address(0), to, value);
	}

	function _burn(address from, uint value) internal {
		balanceOf[from] = balanceOf[from].sub(value);
		totalSupply = totalSupply.sub(value);
		emit Transfer(from, address(0), value);
	}

	function _approve(address owner, address spender, uint value) private {
		allowance[owner][spender] = value;
		emit Approval(owner, spender, value);
	}

	function _transfer(address from, address to, uint value) internal {
		balanceOf[from] = balanceOf[from].sub(value, "Impermax: TRANSFER_TOO_HIGH");
		balanceOf[to] = balanceOf[to].add(value);
		emit Transfer(from, to, value);
	}

	function approve(address spender, uint value) external returns (bool) {
		_approve(msg.sender, spender, value);
		return true;
	}

	function transfer(address to, uint value) external returns (bool) {
		_transfer(msg.sender, to, value);
		return true;
	}

	function transferFrom(address from, address to, uint value) external returns (bool) {
		if (allowance[from][msg.sender] != uint(-1)) {
			allowance[from][msg.sender] = allowance[from][msg.sender].sub(value, "Impermax: TRANSFER_NOT_ALLOWED");
		}
		_transfer(from, to, value);
		return true;
	}
	
	function _checkSignature(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s, bytes32 typehash) internal {
		require(deadline >= block.timestamp, "Impermax: EXPIRED");
		bytes32 digest = keccak256(
			abi.encodePacked(
				'\x19\x01',
				DOMAIN_SEPARATOR,
				keccak256(abi.encode(typehash, owner, spender, value, nonces[owner]++, deadline))
			)
		);
		address recoveredAddress = ecrecover(digest, v, r, s);
		require(recoveredAddress != address(0) && recoveredAddress == owner, "Impermax: INVALID_SIGNATURE");	
	}

	// keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
	bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
		_checkSignature(owner, spender, value, deadline, v, r, s, PERMIT_TYPEHASH);
		_approve(owner, spender, value);
	}
}

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: contracts\interfaces\IPoolToken.sol

pragma solidity >=0.5.0;

interface IPoolToken {

	/*** Impermax ERC20 ***/
	
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
	
	function name() external pure returns (string memory);
	function symbol() external pure returns (string memory);
	function decimals() external pure returns (uint8);
	function totalSupply() external view returns (uint);
	function balanceOf(address owner) external view returns (uint);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint value) external returns (bool);
	function transfer(address to, uint value) external returns (bool);
	function transferFrom(address from, address to, uint value) external returns (bool);
	
	function DOMAIN_SEPARATOR() external view returns (bytes32);
	function PERMIT_TYPEHASH() external pure returns (bytes32);
	function nonces(address owner) external view returns (uint);
	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
	
	/*** Pool Token ***/
	
	event Mint(address indexed sender, address indexed minter, uint mintAmount, uint mintTokens);
	event Redeem(address indexed sender, address indexed redeemer, uint redeemAmount, uint redeemTokens);
	event Sync(uint totalBalance);
	
	function underlying() external view returns (address);
	function factory() external view returns (address);
	function totalBalance() external view returns (uint);
	function MINIMUM_LIQUIDITY() external pure returns (uint);

	function exchangeRate() external returns (uint);
	function mint(address minter) external returns (uint mintTokens);
	function redeem(address redeemer) external returns (uint redeemAmount);
	function skim(address to) external;
	function sync() external;
	
	function _setFactory() external;
}

// File: contracts\PoolToken.sol

pragma solidity =0.5.16;





contract PoolToken is IPoolToken, ImpermaxERC20 {
   	uint internal constant initialExchangeRate = 1e18;
	address public underlying;
	address public factory;
	uint public totalBalance;
	uint public constant MINIMUM_LIQUIDITY = 1000;
	
	event Mint(address indexed sender, address indexed minter, uint mintAmount, uint mintTokens);
	event Redeem(address indexed sender, address indexed redeemer, uint redeemAmount, uint redeemTokens);
	event Sync(uint totalBalance);
	
	/*** Initialize ***/
	
	// called once by the factory
	function _setFactory() external {
		require(factory == address(0), "Impermax: FACTORY_ALREADY_SET");
		factory = msg.sender;
	}
	
	/*** PoolToken ***/
	
	function _update() internal {
		totalBalance = IERC20(underlying).balanceOf(address(this));
		emit Sync(totalBalance);
	}

	function exchangeRate() public returns (uint) 
	{
		uint _totalSupply = totalSupply; // gas savings
		uint _totalBalance = totalBalance; // gas savings
		if (_totalSupply == 0 || _totalBalance == 0) return initialExchangeRate;
		return _totalBalance.mul(1e18).div(_totalSupply);
	}
	
	// this low-level function should be called from another contract
	function mint(address minter) external nonReentrant update returns (uint mintTokens) {
		uint balance = IERC20(underlying).balanceOf(address(this));
		uint mintAmount = balance.sub(totalBalance);
		mintTokens = mintAmount.mul(1e18).div(exchangeRate());

		if(totalSupply == 0) {
			// permanently lock the first MINIMUM_LIQUIDITY tokens
			mintTokens = mintTokens.sub(MINIMUM_LIQUIDITY);
			_mint(address(0), MINIMUM_LIQUIDITY);
		}
		require(mintTokens > 0, "Impermax: MINT_AMOUNT_ZERO");
		_mint(minter, mintTokens);
		emit Mint(msg.sender, minter, mintAmount, mintTokens);
	}

	// this low-level function should be called from another contract
	function redeem(address redeemer) external nonReentrant update returns (uint redeemAmount) {
		uint redeemTokens = balanceOf[address(this)];
		redeemAmount = redeemTokens.mul(exchangeRate()).div(1e18);

		require(redeemAmount > 0, "Impermax: REDEEM_AMOUNT_ZERO");
		require(redeemAmount <= totalBalance, "Impermax: INSUFFICIENT_CASH");
		_burn(address(this), redeemTokens);
		_safeTransfer(redeemer, redeemAmount);
		emit Redeem(msg.sender, redeemer, redeemAmount, redeemTokens);		
	}

	// force real balance to match totalBalance
	function skim(address to) external nonReentrant {
		_safeTransfer(to, IERC20(underlying).balanceOf(address(this)).sub(totalBalance));
	}

	// force totalBalance to match real balance
	function sync() external nonReentrant update {}
	
	/*** Utilities ***/
	
	// same safe transfer function used by UniSwapV2 (with fixed underlying)
	bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
	function _safeTransfer(address to, uint amount) internal {
		(bool success, bytes memory data) = underlying.call(abi.encodeWithSelector(SELECTOR, to, amount));
		require(success && (data.length == 0 || abi.decode(data, (bool))), "Impermax: TRANSFER_FAILED");
	}
	
	// prevents a contract from calling itself, directly or indirectly.
	bool internal _notEntered = true;
	modifier nonReentrant() {
		require(_notEntered, "Impermax: REENTERED");
		_notEntered = false;
		_;
		_notEntered = true;
	}
	
	// update totalBalance with current balance
	modifier update() {
		_;
		_update();
	}
}

// File: contracts\interfaces\IBaseV1Router01.sol

pragma solidity >=0.5.0;

interface IBaseV1Router01 {
    function wftm() external pure returns (address);
    function factory() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
 
    function swapExactTokensForTokensSimple(
        uint amountIn,
        uint amountOutMin,
        address tokenFrom,
        address tokenTo,
        bool stable,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// File: contracts\interfaces\IBaseV1Pair.sol

pragma solidity >=0.5.0;

interface IBaseV1Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function stable() external view returns (bool);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
	
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint reserve0, uint reserve1, uint blockTimestampLast);

    function observationLength() external view returns (uint);
    function observations(uint) external view returns (
        uint timestamp,
        uint reserve0Cumulative,
        uint reserve1Cumulative
    );
    function currentCumulativePrices() external view returns (
        uint reserve0Cumulative,
        uint reserve1Cumulative,
        uint timestamp
    );
}

// File: contracts\interfaces\IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
	
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
}

// File: contracts\interfaces\IBaseV1Factory.sol

pragma solidity >=0.5.0;

interface IBaseV1Factory {
    function getPair(address tokenA, address tokenB, bool stable) external view returns (address pair);
}

// File: contracts\interfaces\ISolidlyVoter.sol

pragma solidity >=0.5.0;

interface ISolidlyVoter {
    function _ve() external view returns (address);
    function governor() external view returns (address);
    function emergencyCouncil() external view returns (address);
    function attachTokenToGauge(uint _tokenId, address account) external;
    function detachTokenFromGauge(uint _tokenId, address account) external;
    function emitDeposit(uint _tokenId, address account, uint amount) external;
    function emitWithdraw(uint _tokenId, address account, uint amount) external;
    function isWhitelisted(address token) external view returns (bool);
    function notifyRewardAmount(uint amount) external;
    function distribute(address _gauge) external;
    function gauges(address token) external view returns (address);
}

// File: contracts\interfaces\ISolidlyGauge3.sol

pragma solidity >=0.5.0;

interface ISolidlyGauge3 {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward() external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function left(address token) external view returns (uint);
    function isForPair() external view returns (bool);
    function earned(address account) external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

// File: contracts\libraries\SafeToken.sol

pragma solidity 0.5.16;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call.value(value)(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// File: contracts\libraries\Math.sol

pragma solidity =0.5.16;

// a library for performing various math operations
// forked from: https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/libraries/Math.sol

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: contracts\StakedLPTokenSolidlyBase3.sol

pragma solidity =0.5.16;











// updated codebase for thena v2 and pearl

contract StakedLPTokenSolidlyBase3 is PoolToken {
	using SafeToken for address;
	
	bool public constant isStakedLPToken = true;
	string public constant stakedLPTokenType = "SolidlyBase3";
	bool public constant stable = false;
	
	address public token0;
	address public token1;
	address public router;
	address public gauge;
	address public rewardsToken;
	address[] public bridgeTokens;
	uint256 public constant REINVEST_BOUNTY = 0.02e18;

	event Reinvest(address indexed caller, uint256 reward, uint256 bounty);
		
	function _initialize(
		address _underlying,
		address _token0,
		address _token1,
		address _router,
		address _voter,
		address _rewardsToken,
		address[] calldata _bridgeTokens
	) external {
		require(factory == address(0), "StakedLPToken: FACTORY_ALREADY_SET"); // sufficient check
		factory = msg.sender;
		_setName("Staked Uniswap V2", "STKD-UNI-V2");
		underlying = _underlying;
		token0 = _token0;
		token1 = _token1;
		router = _router;
		gauge = ISolidlyVoter(_voter).gauges(_underlying);
		require(gauge != address(0), "StakedLPToken: NO_GAUGE");
		rewardsToken = _rewardsToken;
		bridgeTokens = _bridgeTokens;
		_rewardsToken.safeApprove(address(_router), uint256(-1));
		_underlying.safeApprove(address(gauge), uint256(-1));
		for (uint i = 0; i < _bridgeTokens.length; i++) {
			_bridgeTokens[i].safeApprove(address(_router), uint256(-1));
		}
	}
	
	/*** PoolToken Overrides ***/
	
	function _update() internal {
		uint256 _totalBalance = ISolidlyGauge3(gauge).balanceOf(address(this));
		totalBalance = _totalBalance;
		emit Sync(_totalBalance);
	}
	
	// this low-level function should be called from another contract
	function mint(address minter) external nonReentrant update returns (uint mintTokens) {
		uint mintAmount = underlying.myBalance();
		// handle pools with deposit fees by checking balance before and after deposit
		uint256 _totalBalanceBefore = ISolidlyGauge3(gauge).balanceOf(address(this));
		ISolidlyGauge3(gauge).deposit(mintAmount);
		uint256 _totalBalanceAfter = ISolidlyGauge3(gauge).balanceOf(address(this));
		mintTokens = _totalBalanceAfter.sub(_totalBalanceBefore).mul(1e18).div(exchangeRate());

		if(totalSupply == 0) {
			// permanently lock the first MINIMUM_LIQUIDITY tokens
			mintTokens = mintTokens.sub(MINIMUM_LIQUIDITY);
			_mint(address(0), MINIMUM_LIQUIDITY);
		}
		require(mintTokens > 0, "StakedLPToken: MINT_AMOUNT_ZERO");
		_mint(minter, mintTokens);
		emit Mint(msg.sender, minter, mintAmount, mintTokens);
	}

	// this low-level function should be called from another contract
	function redeem(address redeemer) external nonReentrant update returns (uint redeemAmount) {
		uint redeemTokens = balanceOf[address(this)];
		redeemAmount = redeemTokens.mul(exchangeRate()).div(1e18);

		require(redeemAmount > 0, "StakedLPToken: REDEEM_AMOUNT_ZERO");
		require(redeemAmount <= totalBalance, "StakedLPToken: INSUFFICIENT_CASH");
		_burn(address(this), redeemTokens);
		ISolidlyGauge3(gauge).withdraw(redeemAmount);
		_safeTransfer(redeemer, redeemAmount);
		emit Redeem(msg.sender, redeemer, redeemAmount, redeemTokens);		
	}
	
	/*** Reinvest ***/
	
	function _optimalDepositA(uint256 amountA, uint256 reserveA) internal pure returns (uint256) {
		uint256 a = uint256(1997).mul(reserveA);
		uint256 b = amountA.mul(1000).mul(reserveA).mul(3988);
		uint256 c = Math.sqrt(a.mul(a).add(b));
		return c.sub(a).div(1994);
	}
	
	function approveRouter(address token, uint256 amount) internal {
		if (IERC20(token).allowance(address(this), router) >= amount) return;
		token.safeApprove(address(router), uint256(-1));
	}
	
	function swapExactTokensForTokens(address tokenIn, address tokenOut, uint256 amount) internal {
		approveRouter(tokenIn, amount);
		IBaseV1Router01(router).swapExactTokensForTokensSimple(amount, 0, tokenIn, tokenOut, false, address(this), now);
	}
	
	function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) internal returns (uint256 liquidity) {
		approveRouter(tokenA, amountA);
		approveRouter(tokenB, amountB);
		(,,liquidity) = IBaseV1Router01(router).addLiquidity(tokenA, tokenB, false, amountA, amountB, 0, 0, address(this), now);
	}
	
	function _getReward() internal returns (uint256) {
		ISolidlyGauge3(gauge).getReward();
		return rewardsToken.myBalance();
	}
	
	function getReward() external nonReentrant returns (uint256) {
		require(msg.sender == tx.origin);
		return _getReward();
	}

	function _swapWithBestBridge() internal view returns (address bestBridgeToken, uint bestIndex) {
		for (uint i = 0; i < bridgeTokens.length; i++) {
			if (token0 == bridgeTokens[i]) return (bridgeTokens[i], 0);
			if (token1 == bridgeTokens[i]) return (bridgeTokens[i], 1);
		}
		(uint256 r0, uint256 r1,) = IUniswapV2Pair(underlying).getReserves();
		address[2] memory tokens = [token0, token1];
		uint[2] memory reserves = [r0, r1];
		bestBridgeToken = bridgeTokens[0];
		bestIndex = 0;
		uint bestLiquidity = 0;
		address pairFactory = IBaseV1Router01(router).factory();
		for (uint i = 0; i < bridgeTokens.length; i++) {
			for (uint j = 0; j < 2; j++) {
				address pair = IBaseV1Factory(pairFactory).getPair(tokens[j], bridgeTokens[i], false);
				if (pair == address(0)) continue;
				uint liquidity = tokens[j].balanceOf(pair).mul(1e18).div(reserves[j]);
				if (liquidity > bestLiquidity) {
					bestLiquidity = liquidity;
					bestIndex = j;
					bestBridgeToken = bridgeTokens[i];
				}
			}
		}
		return (bestBridgeToken, bestIndex);
	}

	function reinvest() external nonReentrant update {
		require(msg.sender == tx.origin);
		// 1. Withdraw all the rewards.		
		uint256 reward = _getReward();
		if (reward == 0) return;
		// 2. Send the reward bounty to the caller.
		uint256 bounty = reward.mul(REINVEST_BOUNTY) / 1e18;
		rewardsToken.safeTransfer(msg.sender, bounty);
		// 3. Convert all the remaining rewards to token0 or token1.
		address tokenA;
		address tokenB;
		if (token0 == rewardsToken || token1 == rewardsToken) {
			(tokenA, tokenB) = token0 == rewardsToken ? (token0, token1) : (token1, token0);
		}
		else {
			(address bridgeToken, uint index) = _swapWithBestBridge();
			swapExactTokensForTokens(rewardsToken, bridgeToken, reward.sub(bounty));
			if (token0 == bridgeToken || token1 == bridgeToken) { 
				(tokenA, tokenB) = token0 == bridgeToken ? (token0, token1) : (token1, token0);
			}
			else {
				swapExactTokensForTokens(bridgeToken, index == 0 ? token0 : token1, bridgeToken.myBalance());
				(tokenA, tokenB) = index == 0 ? (token0, token1) : (token1, token0);
			}
		}
		// 4. Convert tokenA to LP Token underlyings.
		uint256 totalAmountA = tokenA.myBalance();
		assert(totalAmountA > 0);
		(uint256 r0, uint256 r1,) = IUniswapV2Pair(underlying).getReserves();
		uint256 reserveA = tokenA == token0 ? r0 : r1;
		uint256 swapAmount = _optimalDepositA(totalAmountA, reserveA);
		swapExactTokensForTokens(tokenA, tokenB, swapAmount);
		uint256 liquidity = addLiquidity(tokenA, tokenB, totalAmountA.sub(swapAmount), tokenB.myBalance());
		// 5. Stake the LP Tokens. 
		ISolidlyGauge3(gauge).deposit(liquidity);
		emit Reinvest(msg.sender, reward, bounty);
	}
	
	/*** Mirrored From uniswapV2Pair ***/

	function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) {
		(uint _reserve0, uint _reserve1, uint _blockTimestampLast) = IUniswapV2Pair(underlying).getReserves();
		reserve0 = safe112(_reserve0);
		reserve1 = safe112(_reserve1);
		blockTimestampLast = uint32(_blockTimestampLast % 2**32);
		// if no token has been minted yet mirror uniswap getReserves
		if (totalSupply == 0) return (reserve0, reserve1, blockTimestampLast);
		// else, return the underlying reserves of this contract
		uint256 _totalBalance = totalBalance;
		uint256 _totalSupply = IUniswapV2Pair(underlying).totalSupply();
		reserve0 = safe112(_totalBalance.mul(reserve0).div(_totalSupply));
		reserve1 = safe112(_totalBalance.mul(reserve1).div(_totalSupply));
		require(reserve0 > 100 && reserve1 > 100, "StakedLPToken: INSUFFICIENT_RESERVES");
	}
	
	function observationLength() external view returns (uint) {
		return IBaseV1Pair(underlying).observationLength();
	}
    function observations(uint index) external view returns (
        uint timestamp,
        uint reserve0Cumulative,
        uint reserve1Cumulative
    ) {
		return IBaseV1Pair(underlying).observations(index);
	}
    function currentCumulativePrices() external view returns (
        uint reserve0Cumulative,
        uint reserve1Cumulative,
        uint timestamp
    ) {
		return IBaseV1Pair(underlying).currentCumulativePrices();
	}

	/*** Utilities ***/
	
	function safe112(uint n) internal pure returns (uint112) {
		require(n < 2**112, "StakedLPToken: SAFE112");
		return uint112(n);
	}
}

// File: contracts\interfaces\IUniswapV2Router01.sol

pragma solidity >=0.5.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts\StakedLPTokenFactorySolidlyBase3.sol

pragma solidity =0.5.16;




// updated codebase for thena v2 and pearl

contract StakedLPTokenFactorySolidlyBase3 {
	address public router;
	address public voter;
	address public rewardsToken;
	address[] public bridgeTokens;

	mapping(address => address) public getStakedLPToken;
	address[] public allStakedLPToken;

	event StakedLPTokenCreated(address indexed token0, address indexed token1, address indexed pair, address stakedLPToken, uint);

	constructor(address _router, address _voter, address _rewardsToken, address[] memory _bridgeTokens) public {
		router = _router;
		voter = _voter;
		rewardsToken = _rewardsToken;
		bridgeTokens = _bridgeTokens;
	}

	function allStakedLPTokenLength() external view returns (uint) {
		return allStakedLPToken.length;
	}

	function createStakedLPToken(address pair) external returns (address stakedLPToken) {
		require(getStakedLPToken[pair] == address(0), "StakedLPTokenFactory: POOL_EXISTS");
		require(!IBaseV1Pair(pair).stable(), "StakedLPTokenFactory: STABLE_PAIR");		
		address token0 = IUniswapV2Pair(pair).token0();
		address token1 = IUniswapV2Pair(pair).token1();
		bytes memory bytecode = type(StakedLPTokenSolidlyBase3).creationCode;
		assembly {
			stakedLPToken := create2(0, add(bytecode, 32), mload(bytecode), pair)
		}
		StakedLPTokenSolidlyBase3(stakedLPToken)._initialize(pair, token0, token1, router, voter, rewardsToken, bridgeTokens);
		getStakedLPToken[pair] = stakedLPToken;
		allStakedLPToken.push(stakedLPToken);
		emit StakedLPTokenCreated(token0, token1, pair, stakedLPToken, allStakedLPToken.length);
	}
}