// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
///@title Zenogakki Smart Contract for Dutch Auction


interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    )external;
}
contract DutchAuction{
    uint private constant duration = 5 hours;
    uint private constant disocuntDuration = 5 minutes;
    IERC721 public immutable nft;
    address payable public immutable seller;
    uint public immutable nftId;
    uint256 public immutable startingPrice;
    uint256 public immutable endPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public  immutable discountRate;
    uint256 public durationInterval;

constructor(
    uint256 _startingPrice,
    uint256 _discountPrice,
    uint256 _endPrice,
    address _nft,
    uint _nftId
){
    seller = payable( msg.sender );
    startingPrice = _startingPrice;
    endPrice = _endPrice;
    discountRate = _discountPrice;
    startAt = block.timestamp;
    expiresAt = block.timestamp + duration;
    require(
        _startingPrice >= _discountPrice,
        "starting price is less than disount" 
        );
        nft = IERC721(_nft);
        nftId = _nftId;

  }
function getPrice() public view returns (uint) {
    
    if(expiresAt < block.timestamp){
        return endPrice;
    }
  uint256 minutesElapsed = (block.timestamp - startAt) / ( 60 * 30);
    return startingPrice - (minutesElapsed * discountRate);

  }
  function buy() external payable {
      require(block.timestamp < expiresAt , "auction expired");
      uint price = getPrice();
      require(msg.value >= price , "ETH < price");
      nft.transferFrom( seller, msg.sender, nftId );

      //refunding the buyer if he sends too much eth 
      uint refund = msg.value - price;
      if(refund > 0){
          payable( msg.sender ).transfer( refund );
      }
      selfdestruct(seller);
  }

}