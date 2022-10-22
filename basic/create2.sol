// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
// create2 is used to created a contract with salt, 
// and you can pre-calculate the address before depoly
contract TestContract {
    address public creater;
    uint public foo;
    constructor(uint _foo) payable {
        creater = msg.sender;
        foo = _foo;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


contract Factory {
    event Deployed(address addr, uint salt);
    address public createdAddr;
    address public calculatedAddr;
    bytes32 public salt;
    uint foo;
    // create a new contract using create2
    function deploy() external {
        TestContract t = new TestContract{salt:salt}(foo);
        createdAddr = address(t);
    }
    function calculateAddr() external {
        // pack the creationcode and params
        bytes memory bytecode = abi.encodePacked(type(TestContract).creationCode,abi.encode(foo));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff),address(this),salt,keccak256(bytecode)));
        calculatedAddr = address(uint160(uint(hash)));
    }
    function setSaltAndfoo() external {
        salt = keccak256(abi.encodePacked("0x11", msg.sender));
        foo =420;

    }
}
