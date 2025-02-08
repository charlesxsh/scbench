// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library Address {
    error AddressInsufficientBalance(address account);
    error AddressEmptyCode(address target);
    error FailedInnerCall();

    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, defaultRevert);
    }

    function functionCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, customRevert);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, defaultRevert);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, defaultRevert);
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, defaultRevert);
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        function() internal view customRevert
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, customRevert);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                if (target.code.length == 0) {
                    revert AddressEmptyCode(target);
                }
            }
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    function verifyCallResult(bool success, bytes memory returndata) internal view returns (bytes memory) {
        return verifyCallResult(success, returndata, defaultRevert);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        function() internal view customRevert
    ) internal view returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, customRevert);
        }
    }

    function defaultRevert() internal pure {
        revert FailedInnerCall();
    }

    function _revert(bytes memory returndata, function() internal view customRevert) private view {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            customRevert();
            revert FailedInnerCall();
        }
    }
}

library SafeERC20 {
    using Address for address;

    error SafeERC20FailedOperation(address token);
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /*
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        if (nonceAfter != nonceBefore + 1) {
            revert SafeERC20FailedOperation(address(token));
        }
    }
    */

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract StakingPool is Ownable, ReEntrancyGuard {
  using SafeERC20 for IERC20;
  uint256 public constant EXP_FACTOR = 1e36;

  struct PoolInfo {
    IERC20 stakeToken;
    IERC20 rewardToken;
    uint256 lastRewardTimestamp;
    uint256 accRewardPerShare;
    uint256 depositedAmount;
    uint256 rewardsAmount;
    uint256 rewardsClaimed;
    uint256 rewardReserve;
    uint256 rewardPerDayRate; // 1 == 0.0001% - smallest unit
    uint256 lockupDuration; // seconds the stake is locked for
    uint256 depositMinimum; // min per deposit
    uint256 stakeMaximum; // total stake maximum
    bool depositEnabled;
  }

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 pendingRewards;
    uint256 lockupStart;
  }  

  // mappings
  PoolInfo public poolInfo;
  mapping(address => UserInfo) public userInfo;  

  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Claim(address indexed user, uint256 amount);  

  constructor(IERC20 stakeToken, IERC20 rewardToken, uint256 rewardPerDayRate, uint256 lockupDuration, uint256 depositMinimum, uint256 stakeMaximum) {
    PoolInfo storage pool = poolInfo;
    pool.stakeToken = stakeToken;
    pool.rewardToken = rewardToken;
    pool.rewardPerDayRate = rewardPerDayRate;
    pool.lockupDuration = lockupDuration;
    pool.depositMinimum = depositMinimum;
    pool.stakeMaximum = stakeMaximum;
  }

  function setRewardPerDayRate(uint256 rate) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    updatePool();
    pool.rewardPerDayRate = rate;
  }

  function setLockupDuration(uint256 lockupDuration) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    pool.lockupDuration = lockupDuration;
  }

  function setDepositMinimum(uint256 amount) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    pool.depositMinimum = amount;
  }

  function setStakeMaximum(uint256 amount) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    pool.stakeMaximum = amount;
  }

  function setDepositEnabled(bool enabled) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    pool.depositEnabled = enabled;
  }

  function updatePool() internal {
    PoolInfo storage pool = poolInfo;
    
    if(block.timestamp <= pool.lastRewardTimestamp) {
        return;
    }

    if(pool.depositedAmount == 0) {
      pool.lastRewardTimestamp = block.timestamp;
      return;
    }

    uint256 diff = block.timestamp - pool.lastRewardTimestamp;
    uint256 rewardPerSecondRate = (pool.rewardPerDayRate * EXP_FACTOR) / 86400;
    uint256 reward = (diff * (rewardPerSecondRate / 1000000) * pool.depositedAmount) / EXP_FACTOR;

    pool.rewardsAmount = pool.rewardsAmount + reward;
    pool.accRewardPerShare = pool.accRewardPerShare + ((reward * EXP_FACTOR) / pool.depositedAmount);
    pool.lastRewardTimestamp = block.timestamp;
  }  

  function _deposit(uint256 amount) internal {
    PoolInfo storage pool = poolInfo;
    UserInfo storage user = userInfo[msg.sender];

    require(pool.depositEnabled, "Deposits are not enabled");
    require(amount > 0, "The amount can not be zero");
    require(amount >= pool.depositMinimum, "The amount is less than the deposit minimum");
    require(pool.stakeMaximum == 0 || (user.amount + amount <= pool.stakeMaximum), "The deposit is more than the stake maximum");

    updatePool();

    if(user.amount > 0) {
      uint256 pending = ((user.amount * pool.accRewardPerShare) / EXP_FACTOR) - user.rewardDebt;
      user.pendingRewards = user.pendingRewards + pending;
    }

    pool.stakeToken.safeTransferFrom(address(msg.sender), address(this), amount);
    user.amount = user.amount + amount;
    pool.depositedAmount = pool.depositedAmount + amount;
    user.rewardDebt = (user.amount * pool.accRewardPerShare) / EXP_FACTOR;
    user.lockupStart = block.timestamp;

    emit Deposit(msg.sender, amount);
  }

  function _withdraw(uint256 amount) internal {
    PoolInfo storage pool = poolInfo;
    UserInfo storage user = userInfo[msg.sender];    

    require(amount > 0, "The amount can not be zero");
    require(user.amount >= amount, "The amount is more than the stake amount");
    require(pool.lockupDuration == 0 || block.timestamp > user.lockupStart + pool.lockupDuration, "The stake lockup duration has not been reached");

    updatePool();

    uint256 pending = ((user.amount * pool.accRewardPerShare) / EXP_FACTOR) - user.rewardDebt;
    if(pending > 0) {
      user.pendingRewards = user.pendingRewards + pending;
    }

    pool.stakeToken.safeTransfer(msg.sender, amount);
    pool.depositedAmount = pool.depositedAmount - amount;
    user.amount = user.amount - amount;
    user.rewardDebt = (user.amount * pool.accRewardPerShare) / EXP_FACTOR;
    //user.lockupStart = block.timestamp;

    emit Withdraw(msg.sender, amount);
  }

  function deposit(uint256 amount) external noReentrant {
    _deposit(amount);
  }  

  function depositMax() external noReentrant {
    _deposit(poolInfo.stakeToken.allowance(msg.sender, address(this)));
  }  

  function withdraw(uint256 amount) external noReentrant {
    _withdraw(amount);
  }  

  function withdrawMax() external noReentrant {
    _withdraw(userInfo[msg.sender].amount);
  }  

  function claim() external noReentrant {
    PoolInfo storage pool = poolInfo;
    UserInfo storage user = userInfo[msg.sender];

    updatePool();

    uint256 pending = ((user.amount * pool.accRewardPerShare) / EXP_FACTOR) - user.rewardDebt;
    if(pending > 0 || user.pendingRewards > 0) {
      user.pendingRewards = user.pendingRewards + pending;
      uint256 claimed = safeRewardTransfer(msg.sender, user.pendingRewards);
      emit Claim(msg.sender, claimed);
      user.pendingRewards = user.pendingRewards - claimed;
      user.lockupStart = block.timestamp;
      pool.rewardsAmount = pool.rewardsAmount - claimed;
      pool.rewardsClaimed = pool.rewardsClaimed + claimed;
    }
    user.rewardDebt = (user.amount * pool.accRewardPerShare) / EXP_FACTOR;
  }  

  function pendingRewards(address _user) external view returns (uint256) {
    PoolInfo storage pool = poolInfo;
    UserInfo storage user = userInfo[_user];

    uint256 accRewardPerShare = pool.accRewardPerShare;
    if(block.timestamp > pool.lastRewardTimestamp && pool.depositedAmount > 0) {
      uint256 diff = block.timestamp - pool.lastRewardTimestamp;
      uint256 rewardPerSecondRate = (pool.rewardPerDayRate * EXP_FACTOR) / 86400;
      uint256 reward = (diff * (rewardPerSecondRate / 1000000) * pool.depositedAmount) / EXP_FACTOR;
      accRewardPerShare = accRewardPerShare + ((reward * EXP_FACTOR) / pool.depositedAmount); // store expanded 1e36
    }
    return (((user.amount * accRewardPerShare) / EXP_FACTOR) - user.rewardDebt) + user.pendingRewards;
  } 

  function pendingRewardsTotal(uint256 timestamp) external view returns (uint256) {
    PoolInfo storage pool = poolInfo;    
    if(timestamp == 0) {
      timestamp = block.timestamp;
    }
    uint256 accRewardPerShare = pool.accRewardPerShare;
    if(timestamp > pool.lastRewardTimestamp && pool.depositedAmount > 0) {
      uint256 diff = timestamp - pool.lastRewardTimestamp;
      uint256 rewardPerSecondRate = (pool.rewardPerDayRate * EXP_FACTOR) / 86400;
      uint256 reward = (diff * (rewardPerSecondRate / 1000000) * pool.depositedAmount) / EXP_FACTOR;
      accRewardPerShare = accRewardPerShare + ((reward * EXP_FACTOR) / pool.depositedAmount); // store expanded 1e36
    }
    uint256 poolDebt = 0;
    poolDebt = (pool.depositedAmount * pool.accRewardPerShare) / EXP_FACTOR;
    return (((pool.depositedAmount * accRewardPerShare) / EXP_FACTOR) - poolDebt) + pool.rewardsAmount;
  }

  function safeRewardTransfer(address to, uint256 amount) internal returns (uint256) {
    PoolInfo storage pool = poolInfo;
    uint256 rewardAmount = amount;
    if(rewardAmount > pool.rewardsAmount) {
      rewardAmount = pool.rewardsAmount;
    }
    if(rewardAmount > pool.rewardReserve) {
      rewardAmount = pool.rewardReserve;
    }
    pool.rewardToken.safeTransfer(to, rewardAmount);
    pool.rewardReserve = pool.rewardReserve - rewardAmount;
    return rewardAmount;
  }  

  function depositRewardReserve(uint256 amount) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    pool.rewardToken.safeTransferFrom(address(msg.sender), address(this), amount);
    pool.rewardReserve = pool.rewardReserve + amount;
  }

  function withdrawRewardReserve(uint256 amount) external onlyOwner {
    PoolInfo storage pool = poolInfo;
    require(pool.rewardReserve >= amount, "Amount is more than the reward reserve");
    pool.rewardReserve = pool.rewardReserve - amount;
    pool.rewardToken.safeTransfer(address(owner()), amount);
  }  
}