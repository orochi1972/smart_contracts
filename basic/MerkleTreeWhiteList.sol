// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
//https://lab.miguelmota.com/merkletreejs/example.  calculate the proof
contract Dogemoon is ERC20{
    address owner;
    bytes32 immutable public root; // only need to store root hash to verify all WLs
    mapping(address => bool) public mintedAddress;
    constructor(bytes32 _root) ERC20("DogeMoon", "DM") {
        owner =msg.sender;
        root=_root;
        _mint(msg.sender, 1000*1e18);
    }
    function verifyWhiteList(bytes32 leaf, bytes32[] calldata proof) public view returns(bool){
        return MerkleProof.verify(proof, root, leaf);
    }
//hash
    function _leaf(address account) internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(account));
    }

    function mint(uint256 amount, bytes32[] calldata p) external{
        require(verifyWhiteList(_leaf(msg.sender),p),'!wrong');
        _mint(msg.sender, amount);
        mintedAddress[msg.sender]=true;

    }

}
