// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract PollStation {
    string[] public candidateNames;
    
    mapping(string => uint256) voteCount;

    mapping(string => bool) public candidateExists;
    mapping(address => bool) public hasVoted;

    function addCandidateNames(string memory _candidateName) public {
        require(!candidateExists[_candidateName], "Candidate already exists.");
        candidateNames.push(_candidateName);
        candidateExists[_candidateName] = true;
        voteCount[_candidateName] = 0;
    }

    function getCandidateNames() public view returns(string[] memory) {
        return candidateNames;
    }

    function vote(string memory _candidateName) public {
        require(candidateExists[_candidateName], "Candidate does not exist.");
        require(!hasVoted[msg.sender], "You have already voted.");
        hasVoted[msg.sender] = true;
        voteCount[_candidateName] += 1;
        
    }

    function getVote(string memory _candidateName) public view returns(uint256) {
        return voteCount[_candidateName];
    }

    function getAllVotes() public view returns(string[] memory, uint256[] memory) {
        uint[] memory votes = new uint256[](candidateNames.length);
        for (uint256 i = 0; i < candidateNames.length; i++) {
            votes[i] = voteCount[candidateNames[i]];
        }
        return (candidateNames, votes);
    }
}
