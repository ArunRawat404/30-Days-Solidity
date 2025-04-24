// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract BasicVoting {
    // Structure to hold proposal details
    struct Proposal {
        string name;           // Name or title of the proposal
        uint256 voteCount;     // Number of votes received
        uint256 startTime;     // Timestamp when voting starts
        uint256 endTime;       // Timestamp when voting ends
        bool executed;         // Flag to check if proposal has been executed
    }

    Proposal[] public proposals; // Dynamic array to store all proposals

    // Tracks whether an address has voted on a specific proposal
    mapping(address => mapping(uint => bool)) public hasVoted;

    // Function to create a new proposal with a given name and voting duration
    function createProposal(string memory name, uint duration) public {
        proposals.push(Proposal({
            name: name,
            voteCount: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            executed: false
        }));
    }

    // Allows a user to vote on a specific proposal
    function vote(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Too early");             // Voting hasn't started yet
        require(block.timestamp <= proposal.endTime, "Too late");                // Voting period has ended
        require(!hasVoted[msg.sender][proposalId], "Already voted");            // Prevent double voting

        hasVoted[msg.sender][proposalId] = true; // Mark voter as having voted
        proposal.voteCount++;                    // Increment the vote count
    }

    // Function to execute a proposal after the voting period is over
    function executeProposal(uint proposalId) public {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Too early");         // Ensure voting period has ended
        require(!proposal.executed, "Already executed");                 // Ensure it's not already executed

        proposal.executed = true; // Mark proposal as executed

        // Some execution logic here (e.g., implement proposal action)
    }
}
