// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* created by yiyi on 14 Sep,2022. 
* 
*/
contract mypfp is ERC721Enumerable,Ownable{
    string public basicUri;
    bool public mintable = true;
    uint public maxSupply =1000;
    uint public constant START_PRICE=1 ether;
    uint public constant END_PRICE=0.1 ether;
    uint public constant AUCTION_TIME=10 minutes;
    uint public constant AUCTION_DROP_INTERVAL=10 seconds;
    uint public constant AUCTON_STEP =(START_PRICE-END_PRICE)/AUCTION_TIME/AUCTION_DROP_INTERVAL;
    uint public auction_start_time;

    constructor(string memory uri) ERC721("Azuki","AK") {
        basicUri = uri;
        auction_start_time=block.timestamp;
    }
    function getCurrentPrice() public view returns(uint){
        uint time_now = block.timestamp;
        if (time_now<auction_start_time){
            return START_PRICE;
        }else if(time_now>=auction_start_time+AUCTION_TIME){
            return END_PRICE;
        }else {
            uint steps = (time_now-auction_start_time)/AUCTION_DROP_INTERVAL;
            return START_PRICE-AUCTON_STEP*steps;
        }
    }
    receive() external payable{}
    fallback() external payable{}
    function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    function mint() external payable  {
        require(mintable,"you cannot mint for now");
        uint supply = totalSupply();
        require(supply<maxSupply,"exceed max supply");
        require(msg.value>=getCurrentPrice(),"not enough ETH");
        _safeMint(msg.sender, supply);

    }
    
    function setMintState() public onlyOwner{
        mintable = !mintable;
    }
    
    function setUri(string memory u) public onlyOwner{
        basicUri=u;
    }
    function _baseURI() internal view  override returns (string memory) {
        return basicUri;
    }
    
}
