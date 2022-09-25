// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
contract TokenLocker is Ownable,IERC20{
    ERC20 public token;
    uint public lockDuration;
    string public name;
    string public symbol;
    mapping(address =>uint) public balanceOf;
    mapping(address => uint) public lockEnd;
    uint public totalSupply;

    error NotSupported();

    constructor(address _token, string memory _name, string memory _symbol) Ownable(){
        name=_name;
        symbol=_symbol;
        token = ERC20(_token);
        totalSupply=0;
    }
    function initialize(uint _lockDuration) public onlyOwner{
        lockDuration = _lockDuration;
    }

    function deposit(uint amount) public{
        lockEnd[msg.sender] = block.timestamp+lockDuration;
        balanceOf[msg.sender]+=amount;
        totalSupply+=amount;
        bool isTrans = token.transferFrom(msg.sender,address(this),amount);
        require(isTrans,"transfer failed");
        emit Transfer(msg.sender,address(this),amount);

    }

    function withdraw(uint amount) public{
        require(block.timestamp>lockEnd[msg.sender],"still locking");
        require(balanceOf[msg.sender]>=amount,"exceed balance");
        balanceOf[msg.sender]-=amount;
        totalSupply-=amount;
        bool isTrans = token.transfer(msg.sender,amount);
        require(isTrans,"transfer failed");
        emit Transfer(address(this), msg.sender, amount);

    }
    function decimals() public view returns(uint8){
        return token.decimals();
    }
    /// @dev Lock claim tokens are non-transferrable: ERC-20 transfer is not supported
    function transfer(address, uint256) external pure override returns (bool) {
        revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 allowance is not supported
  function allowance(address, address)
    external
    pure
    override
    returns (uint256)
  {
    revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 approve is not supported
  function approve(address, uint256) external pure override returns (bool) {
    revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 transferFrom is not supported
  function transferFrom(
    address,
    address,
    uint256
  ) external pure override returns (bool) {
    revert NotSupported();
  }
}
