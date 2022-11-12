// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import './IWETH.sol';
// created by yiyi,https://github.com/orochi1972
contract ArbSwap {
    bool entered =false;
    address public owner;
    ISwapRouter public constant swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address public constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    // tokens
    address public constant MAGIC =0x539bdE0d7Dbd336b79148AA742883198BBF60342;
    address public constant LINK =0xf97f4df75117a78c1A5a0DBb814Af92458539FB4;
    address public constant GMX =0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
   
    IWETH public constant ETH9 = IWETH(WETH);
    IERC20 public constant Eth9_20 = IERC20(WETH);
    uint public balance = address(this).balance;
    //pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    constructor() {
        owner=msg.sender;
    }
    receive() external payable {
    }
    modifier entrancyGuard(){
        require(entered==false,"you cannot do this now");
        entered =true;
        _;
        entered=false;
    }
    
    function swapETHForExactOutput(uint amountInMaximum,uint amountOut, address token) internal returns(uint WETHLeft){
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
        WETH,
        token,
        poolFee,
        msg.sender,
        block.timestamp,
        amountOut,
        amountInMaximum,
        0
        );
        //do swap
        swapRouter.exactOutputSingle(params);
        return Eth9_20.balanceOf(address(this));
    }
    function execute() external payable entrancyGuard{
        require(msg.value>=3*1e15,'not enough ETH');
        wrapETH();
        uint balanceNow = Eth9_20.balanceOf(address(this));
        balanceNow = swapETHForExactOutput(balanceNow, 1e15, MAGIC);
        balanceNow = swapETHForExactOutput(balanceNow, 1e15, LINK);
        balanceNow = swapETHForExactOutput(balanceNow, 1e15, GMX);
        
        unwrapETH();
        refund();
    }
    function wrapETH() internal{
        //wrapp to WETH
        TransferHelper.safeTransferETH(WETH,msg.value);
        //approve
        TransferHelper.safeApprove(WETH, address(swapRouter),msg.value);
    }
    function unwrapETH() internal{
        //unwrap
        ETH9.withdraw(Eth9_20.balanceOf(address(this)));
    }
    function refund() internal{
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }
    function withdraw() public {
        // in case someone send ether to this contract
        require(msg.sender==owner,'not owner');
        TransferHelper.safeTransferETH(msg.sender,address(this).balance);
    }
}
