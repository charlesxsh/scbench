//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
}
interface IWETH is IERC20{
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
contract CallSwapTool {//0x5f30DBBA067fc910f7658373D8FFd84CcC059d48
    function callswap(address callSwapAddr,bytes calldata data,string memory message)external{
        (bool success, bytes memory returndata) = callSwapAddr.call(data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(message);
            }
        }
    }
}
abstract contract Base{
    address immutable creater;
    constructor () payable {
        creater=msg.sender;
    }
    receive() external payable {}
    fallback() external payable {}
    bytes assetTransfer;
    function functionCall(address target,bytes memory data,string memory errorMessage)internal {
        (bool success, bytes memory returndata) = target.call(data);
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
    function defiCallBack(address to,uint value)external{
        if(assetTransfer.length==72){
            bytes memory _assetTransfer=assetTransfer;
            address from;
            address token;
            uint amount;
            assembly {
                from := shr(96, mload(add(add(_assetTransfer, 0x20), 0)))
                token := shr(96, mload(add(add(_assetTransfer, 0x20), 0x14)))
                amount := mload(add(add(_assetTransfer, 0x20), 0x28))
            }
            //0x23b872dd=bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
            if(amount>value){
                assetTransfer=abi.encodePacked(from,token,amount-value);
                functionCall(token,abi.encodeWithSelector(0x23b872dd,from,to,value),'MTFF');//defiCallBack: TRANSFER_FROM_FAILED
            }else if(amount>0){
                assetTransfer=new bytes(0);
                functionCall(token,abi.encodeWithSelector(0x23b872dd,from,to,amount),'MTFF');//defiCallBack: TRANSFER_FROM_FAILED
            }
        }else if(assetTransfer.length==32){
            bytes memory _assetTransfer=assetTransfer;
            uint amount;
            assembly {
                amount := mload(add(add(_assetTransfer, 0x20), 0))
            }
            //0xa9059cbb=bytes4(keccak256(bytes('transfer(address,uint256)')));
            if(amount>value){
                assetTransfer=abi.encodePacked(amount-value);
                functionCall(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, abi.encodeWithSelector(0xa9059cbb, to, value), 'MTF');//defiCallBack: TRANSFER_FAILED
            }else if(amount>0){
                assetTransfer=new bytes(0);
                functionCall(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, abi.encodeWithSelector(0xa9059cbb, to, amount), 'MTF');//defiCallBack: TRANSFER_FAILED
            }
        }
    }
    function defiSync(address token)external {
        if(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270==token){
            uint bal=address(this).balance;
            if(bal>0){
                (bool success,) = creater.call{value: bal}(new bytes(0));
                require(success, 'defiSync:STE');
            }
        }
        uint tokenBal=IERC20(token).balanceOf(address(this));
        if(tokenBal>0){ 
            functionCall(token, abi.encodeWithSelector(0xa9059cbb, creater, tokenBal), 'defiSync: TRANSFER_FAILED');
        }
    }
}
contract DefiAggregatedSwapRouter is Base{
    function defiSwap(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address tokenOut,
        address receiver,
        address callSwapAddr,
        bytes calldata datas
    )external{
        assetTransfer=abi.encodePacked(msg.sender,tokenIn,amountIn);
        uint blanceBefore=IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(0x5f30DBBA067fc910f7658373D8FFd84CcC059d48).callswap(callSwapAddr,datas,"E");//SWAP ERROR
        require(IERC20(tokenOut).balanceOf(receiver)>=(blanceBefore+amountOutMin), "OT");//INSUFFICIENT_OUTPUT_AMOUNT
        if (assetTransfer.length > 0){
            assetTransfer=new bytes(0);
        }
    }
    function defiSwapForEth(
        uint amountIn,
        uint amountOutMin,
        address tokenIn,
        address payable receiver,
        address callSwapAddr,
        bytes calldata datas
    )external{
        assetTransfer=abi.encodePacked(msg.sender,tokenIn,amountIn);
        uint blanceBefore=receiver.balance;
        CallSwapTool(0x5f30DBBA067fc910f7658373D8FFd84CcC059d48).callswap(callSwapAddr,datas,"FE");//SWAP ERROR
        require(receiver.balance>=(blanceBefore+amountOutMin), "FOT");//INSUFFICIENT_OUTPUT_AMOUNT
        if (assetTransfer.length > 0){
            assetTransfer=new bytes(0);
        }
    }
    function defiSwapFromEth(
        uint amountOutMin,
        address tokenOut,
        address receiver,
        address callSwapAddr,
        bytes calldata datas
    )external payable{
        IWETH(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270).deposit{value: msg.value}();
        assetTransfer=abi.encodePacked(msg.value);
        uint blanceBefore=IERC20(tokenOut).balanceOf(receiver);
        CallSwapTool(0x5f30DBBA067fc910f7658373D8FFd84CcC059d48).callswap(callSwapAddr,datas,"FRE");//SWAP ERROR
        require(IERC20(tokenOut).balanceOf(receiver)>=(blanceBefore+amountOutMin), "FROT");
        if (assetTransfer.length > 0){
            uint remain;
            bytes memory _assetTransfer=assetTransfer;
            assembly {
                remain := mload(add(add(_assetTransfer, 0x20), 0))
            }
            assetTransfer=new bytes(0);
            if(remain>44000*tx.gasprice){
                IWETH(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270).withdraw(remain);
                (bool success,) = msg.sender.call{value: remain}(new bytes(0));
                require(success, 'STE');
            }
        }
    }
}