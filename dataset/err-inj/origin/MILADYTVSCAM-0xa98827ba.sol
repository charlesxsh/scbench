// SPDX-License-Identifier: MIT
/*
A NOTORIOUS GROUP OF SCAM FARMER RUGGERS ARE LAUNCHING MILADY TV TONIGHT! THE LAUNCHED POPO LAST WEEK AND FARMED 40 ETH
THEY ARE NOTORIOUS SCAMMERS/FARMERS SAVE YOUR ETH AND DO NOT BUY!!!!!!!!!!!!!!!!!!!!!
THEIR LAST PROJECT WAS MEMECORP, THEY HAVE ALSO DONE SCAM PROJECTS SUCH AS ETH420, HUSH PROTOCOL, POPO & NOW MILADY TV ALONGSIDE MANY OTHERS!
STAY AWAY NOTORIOUS SCAMMERS!!!!!!!!!!!!!!!!!!!!!!!

*/

pragma solidity 0.8.19;

contract MILADYTVSCAM {
    mapping(address account => uint256) public balanceOf;
    mapping(address account => mapping(address spender => uint256)) public allowance;
    uint8   public constant decimals    = 9;
    uint256 public constant totalSupply = 1_000_000_000 * (10**decimals);
    string  public constant name        = "https://t.me/MiladyTVeth IS A HUGE SCAM DO NOT BUY!";
    string  public constant symbol      = "https://t.me/MiladyTVeth IS A HUGE SCAM DO NOT BUY IT! ";

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0x9d2F5B0fC29F84B6328eE8F57fC3EAE5aAAB8D74), msg.sender, totalSupply);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(msg.sender != address(0) && spender != address(0), "ERC20: Zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);

        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount,"ERC20: amount exceeds allowance");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0) && to != address(0), "ERC20: Zero address");
        require(balanceOf[from] >= amount, "ERC20: amount exceeds balance");        
        balanceOf[from] -= amount;
        balanceOf[to]   += amount;
        emit Transfer(from, to, amount);
    }
}