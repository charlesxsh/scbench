/**
 * BRRR.LIVE - Building generational wealth, together!
 *
 * With $BRRR we band together to build generational wealth for a random holder every day, forever.
 * Provably fair & fully on-chain.
 *
 *
 * DOUBLE YOUR BRRR BY PLAYING AGAINST OTHER PLAYERS
 *
 *
 * Website: https://brrr.live
 * Twitter: https://twitter.com/brrr_live
 * Telegram: https://t.me/brrrdotlive 
 * 
 * 
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



contract BrrrPvp {
    using SafeMath for uint256;

    IERC20 brrrToken;
    address public owner;
    address payable public mainPoolAddress;
    uint public minBet;
    uint public maxPlayers;
    uint public current_game;
    bool public game_active;
    uint counter = 1;
    uint _finalSellTax = 5;
    mapping(uint => address[]) public GameToPlayers;

    mapping(uint => mapping(address => uint)) GameToPlayerBets;

    mapping(uint => uint) public GameToPool;

    mapping(uint => address) public GameToWinner;


    constructor() {
        owner = msg.sender;
        game_active = false;
        maxPlayers = 3;
        minBet = 100000 * 10** 9;
        brrrToken = IERC20(address(0x4140d800e6c98281884b86e967719b62203d4403));
        mainPoolAddress = payable(address(0x4140d800e6c98281884b86e967719b62203d4403));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    receive() external payable {
    }

    function playerAllowance(address addy) external view returns (uint)
    {
        return brrrToken.allowance(addy, address(this));
    }
    function playerIndex(address addy) external view returns (uint)
    {
        for(uint i = 0; i < GameToPlayers[current_game].length; i++){
            if(GameToPlayers[current_game][i] == addy)
            {
                return i;
            } 
        }
        return 100;
    }

    function TotalplayersInGame(uint game_id) external view returns (uint)
    {
        return GameToPlayers[game_id].length;
    }

    function playersInGame(uint game_id) external view returns (address[] memory)
    {
        return GameToPlayers[game_id];
    }

    function poolInGame(uint game_id) external view returns (uint)
    {
        return GameToPool[game_id];
    }

    function winnerOfGame(uint game_id) external view returns (address)
    {
        return GameToWinner[game_id];
    }

    function playerBetsInGame(uint game_id, address addy) external view returns (uint)
    {
        return GameToPlayerBets[game_id][addy];
    }

    function toggleGame() external onlyOwner() {
        game_active = !game_active;
    }

    function setTokenAddress(address payable _tokenAddress) external onlyOwner() {
       brrrToken = IERC20(address(_tokenAddress));
    }

    function updateMaxPlayers(uint maxp) external onlyOwner() {
       maxPlayers = maxp;
    }

    function updateMinBet(uint minb) external onlyOwner() {
       minBet = minb;
    }


    function setMainPoolAddress(address payable _tokenAddress) external onlyOwner() {
       mainPoolAddress = payable(address(_tokenAddress));
    }

    function leaveGame(uint index) external
    {
        require(game_active == true,"The game is currently inactive, try again later");
        require(index <= GameToPlayers[current_game].length,"Wrong Index 1");
        require(GameToPlayers[current_game][index] == msg.sender,"Wrong index 2");
        require(GameToPlayerBets[current_game][msg.sender] > 0,"You have not joined the current game");

        if(GameToPlayers[current_game].length == 1) 
        {
            delete GameToPlayers[current_game];
        }
        else 
        {
            GameToPlayers[current_game][index] = GameToPlayers[current_game][GameToPlayers[current_game].length - 1];
            GameToPlayers[current_game].pop();
        }

        uint amount = GameToPlayerBets[current_game][msg.sender];

        GameToPlayerBets[current_game][msg.sender] = 0;
        GameToPool[current_game] -= amount;
        brrrToken.transfer(msg.sender, amount);
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function joinGame(uint amount) external
    {
        require(game_active == true,"The game is currently inactive, try again later");
        require(GameToPlayers[current_game].length <= maxPlayers,"Max players reached");
        require(GameToPlayerBets[current_game][msg.sender] == 0,"You have already joined the current game");
        require(amount >= minBet,"You need at least 100K $BRRR to join the game");
        
        bool success = brrrToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Could not transfer token. Missing approval");

        GameToPlayers[current_game].push(msg.sender);
        uint taxAmount = amount.mul(_finalSellTax).div(100);
        GameToPlayerBets[current_game][msg.sender] = (amount - taxAmount);
        GameToPool[current_game] += (amount - taxAmount);

        if(GameToPlayers[current_game].length == maxPlayers)
        {
            address payable winner = payable(GameToPlayers[current_game][randomNumber()]);
            uint reward = GameToPlayerBets[current_game][winner] * 2;

            if(GameToPool[current_game] < reward)
            {
                reward = GameToPool[current_game];
            }

            GameToWinner[current_game] = winner;
            brrrToken.transfer(winner, reward);
            
            uint brrrBalance = brrrToken.balanceOf(address(this));
            if(brrrBalance > 0)
            {
                brrrToken.transfer(mainPoolAddress, brrrBalance / 2);
                brrrBalance = brrrToken.balanceOf(address(this));
                if(brrrBalance > 0)
                {
                    brrrToken.transfer(address(0x0000dead), brrrBalance);
                }
            }
            current_game++;  
        }

    }

    function emergencyTokenWithdrawal() external onlyOwner {
        uint brrrBalance = brrrToken.balanceOf(address(this));
        brrrToken.transfer(msg.sender, brrrBalance);
    }

    function emergencyWithdrawal() external onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance } ("");
        require(success, "Transfer failed.");
    }

    function randomNumber() internal returns (uint) 
    {
        counter++;
        uint random = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, counter, GameToPlayers[current_game].length, gasleft()))) % GameToPlayers[current_game].length;
        return random;
    }

  
}