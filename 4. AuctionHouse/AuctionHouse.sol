// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract AuctionHouse {
    address immutable public i_owner;

    string public item;
    uint256 public startingPrice;
    uint public auctionEndTime;
    address private highestBidder;
    uint private highestBid;
    bool public hasAuctionEnded;

    mapping(address => uint256) public bids;
    address[] public bidders;


    constructor(string memory _item, uint256 _biddingTime, uint256 _startingPrice) {
        i_owner = msg.sender;
        item = _item;
        startingPrice = _startingPrice;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount >= startingPrice, "Bid amount must be greater than starting bid price.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        if(bids[msg.sender] > 0){
            require(amount >= bids[msg.sender] + (bids[msg.sender] * 5) / 100, "Bid must be at least 5% higher than your previous bid.");
        }

        if(bids[msg.sender] == 0){
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount;

        if (amount > highestBid){
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    function endAuctionn() external {
        require(msg.sender == i_owner, "Only the owner can end the auction.");
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!hasAuctionEnded, "Auction end already called.");
        hasAuctionEnded = true;
    }

    function getWinner() external view returns(address, uint256) {
        require(hasAuctionEnded, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }

    function getAllBidders() external view returns(address[] memory) {
        return bidders;
    }

    function withdraw() external {
        require(hasAuctionEnded, "Auction has not ended yet");
        require(msg.sender != highestBidder, "Highest bidder cannot withdraw");
        uint256 amount = bids[msg.sender];
        require(amount > 0, "No bid to withdraw");
        bids[msg.sender] = 0;

        (bool callSuccess, ) = payable(msg.sender).call{value: amount}("");
        require(callSuccess, "Call Withdraw Failed");
    }
}
