// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract AdminOnly {
    address public owner;

    uint256 public treasureAmount;
    uint256 public maxWithdrawLimit;
    uint256 public cooldownPeriod; 

    mapping(address => uint256) public withdrawalAllowance;
    mapping(address => bool) public hasWithdrawnThisCycle; 
    mapping(address => bool) public isWithdrawalApproved;  
    mapping(address => uint256) public lastWithdrawalTime;

    // Events 
    event TreasureAdded(uint256 amount);
    event TreasureWithdrawn(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;       
    }

    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
        emit TreasureAdded(amount);
    }

    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(amount <= treasureAmount, "Not enough treasure available");
        require(block.timestamp >= lastWithdrawalTime[recipient] + cooldownPeriod, "Please wait for cooldown to finish");
        require(amount <= maxWithdrawLimit, "Amount should not exceed maximum withdrawal limit");
        withdrawalAllowance[recipient] = amount;
        isWithdrawalApproved[recipient] = true; 
    }

    function withdrawTreasure(uint256 amount) public {
        if (msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            treasureAmount -= amount;
            emit TreasureWithdrawn(msg.sender, amount);
            return;
        }

        uint256 allowance = withdrawalAllowance[msg.sender];
        require(allowance > 0, "You don't have any treasure allowance");
        require(!hasWithdrawnThisCycle[msg.sender], "You have already withdrawn your treasure");
        require(allowance <= treasureAmount, "Not enough treasure in the chest");

        hasWithdrawnThisCycle[msg.sender] = true;
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;
        lastWithdrawalTime[msg.sender] = block.timestamp;
        emit TreasureWithdrawn(msg.sender, amount);
    }

    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawnThisCycle[user] = false;
        isWithdrawalApproved[user] = false;
        lastWithdrawalTime[user] = block.timestamp - cooldownPeriod; 
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getTreasureDetails() public view onlyOwner returns(uint256) {
        return treasureAmount;
    }

    function setMaxWithdrawalLimit(uint256 _maxWithdrawLimit) public onlyOwner {
        maxWithdrawLimit = _maxWithdrawLimit;
    }

    function setCooldownPeriod(uint256 _cooldownPeriod) public onlyOwner {
        cooldownPeriod = _cooldownPeriod;
     }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        _;
    }
}
