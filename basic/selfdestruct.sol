// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
// all the ether in this contruct will be sent to a certain address
contract deleteThisContract {
    constructor(){}
    receive() external payable {}
    function deleteThis() external {
        selfdestruct(payable(msg.sender));
    }
}
