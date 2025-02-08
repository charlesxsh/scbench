// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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


interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
}

contract MultiWalletTokenSwapper {
    address private owner;
    address private WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapRouter private uniswapRouter;

    constructor(
        address _router
    ) {
        owner = msg.sender;
        uniswapRouter = IUniswapRouter(_router);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function setAddressWETH(address _weth) external onlyOwner {
        WETH = _weth;
    }

    function setRouterAddress(address _router) external onlyOwner {
        uniswapRouter = IUniswapRouter(_router);
    }

    function approval(address _token, uint _amount) external onlyOwner {
        require((IERC20(_token).approve(address(uniswapRouter), _amount)) , "FAILED");
    }

    function allowanceCheck(address _token, address ownerToken, address spender) view external returns(uint256){
        return IERC20(_token).allowance(ownerToken, spender);
    }
    
    // INPUT
    // tokenIn --> Token Address which you want to swap
    // tokenOut --> Token Address which you want to receive
    // amountIn --> Amount for each address that you want to swap
    // amountOut --> Minimum Amount for each which you want to receive 
    // to --> Array of addresses for which you want to perform swap
    // deadline --> Timelimit for transaction
    // zeroFlag --> Keep it as false, except when trying for USDT or if you want to set approval to zero before transaction
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint[] memory amountIn,
        uint[] memory amountOut,
        address[] memory to,
        uint256 deadline,
        bool zeroFlag
    ) external onlyOwner {
        require(amountIn.length == to.length, "Number of Address should be equal to List of Amounts");
        
        IERC20 tokenA = IERC20(tokenIn);
        address[] memory path;
        if (tokenIn == WETH || tokenOut == WETH) {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } else {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = WETH;
            path[2] = tokenOut;
        }

        uint totalAmount = 0;
        for(uint256 i=0; i < amountIn.length; i++) {
            totalAmount += amountIn[i];
        }
        if(zeroFlag){
            tokenA.approve(address(uniswapRouter), 0);
        }
        tokenA.approve(address(uniswapRouter), totalAmount);

        for(uint256 i=0; i < amountIn.length; i++) {
            
            tokenA.transferFrom(to[i], address(this), amountIn[i]);
            
            uniswapRouter.swapExactTokensForTokens(
                amountIn[i],
                amountOut[i],
                path,
                to[i],
                deadline
            );
        }
    }


    function swapETHForTokens(
        address tokenOut,
        uint256 amountOutMin,
        uint256 deadline
    ) external payable {
        address[] memory path;
        path = new address[](2);
        path[0] = WETH;
        path[1] = tokenOut;
        
        uniswapRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, deadline);
    }

    function checkBalance(address _address) external view returns (uint256) {
        return IERC20(_address).balanceOf(msg.sender);
    }
}