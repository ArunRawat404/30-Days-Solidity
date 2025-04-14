// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract EtherPiggyBank {
    address public bankManager;
    uint256 public maxWithdrawLimit;
    uint256 public cooldownPeriod; 

    address[] public members;
    mapping(address => bool) public registeredMembers;

    mapping(address => uint256) balance;
    mapping(address => uint256) public lastWithdrawalTime;

    constructor() {
        bankManager = msg.sender;
        members.push(msg.sender);
    }

    function addMembers(address _member) public onlyBankManager {
        require(_member != address(0), "Invalid address");
        require(_member != msg.sender, "Bank Manager is already a member");
        require(!registeredMembers[_member], "Member already registered");

        registeredMembers[_member] = true;
        members.push(_member);
    }   

    function getMembers() public view returns(address[] memory) {
        return members;
    }

    // function deposit(uint256 _amount) public onlyRegisteredMember {
    //     require(_amount > 0, "Invalid amount");
    //     balance[msg.sender] += _amount;
    // }

    // function withdraw(uint256 _amount) public onlyRegisteredMember {
    //     require(_amount > 0, "Invalid amount");
    //     require(balance[msg.sender] >= _amount, "Insufficient balance");
    //     balance[msg.sender] -= _amount;
    // }

    function depositAmountEther() public payable onlyRegisteredMember {
        require(msg.value > 0, "Invalid amount");
        balance[msg.sender] += msg.value;
    }

    function withdrawAmountEther(uint256 _amount) public onlyRegisteredMember {
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance");

        // Ensure the contract has enough Ether to send
        require(address(this).balance >= _amount, "Contract has insufficient balance");
        require(_amount <= maxWithdrawLimit, "Withdrawal amount should not exceed maximum withdrawal limit");
        require(block.timestamp >= lastWithdrawalTime[msg.sender] + cooldownPeriod, "Please wait for cooldown to finish");

        (bool callSuccess, ) = payable(msg.sender).call{value: _amount}("");
        require(callSuccess, "Withdrawal Failed");

        balance[msg.sender] -= _amount;
        lastWithdrawalTime[msg.sender] = block.timestamp;
    }

    function getBalance(address _member) public view returns(uint256) {
        require(_member != address(0), "Invalid address");
        return balance[_member];
    }

    function setMaxWithdrawalLimit(uint256 _maxWithdrawLimit) public onlyBankManager {
        require(_maxWithdrawLimit > 0, "Limit must be greater than 0");
        maxWithdrawLimit = _maxWithdrawLimit;
    }

    function setCooldownPeriod(uint256 _cooldownPeriod) public onlyBankManager {
        cooldownPeriod = _cooldownPeriod;
     }

    modifier onlyBankManager() {
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }

    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }
}