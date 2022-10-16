// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
// call and delegate call
// 被调用的合约C
contract C {
    uint public num;
    address public sender;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}
contract B{
    uint public num;
    address public sender;
    // 通过call来调用C的setVars()函数，不会改变合约B里的状态变量
    function callSetVars(address _addr, uint _num) public payable {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
    // 通过delegatecall来调用C的setVars()函数，将改变合约B里的状态变量，不会改变C的
    function delegatecallSetVars(address _addr, uint _num) external payable{
        // delegatecall setVars()
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
