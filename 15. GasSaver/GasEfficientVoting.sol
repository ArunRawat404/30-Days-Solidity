// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GasEfficientVoting {
    // Use uint8 for small numbers to save gas (max 255 proposals)
    uint8 public proposalCount;

    // Compact struct using small-sized types for optimal storage packing
    struct Proposal {
        bytes32 name;          // Fixed-size name to reduce dynamic memory costs
        uint32 voteCount;      // Supports up to ~4.3 billion votes
        uint32 startTime;      // Unix timestamp (valid until year 2106)
        uint32 endTime;        // Unix timestamp
        bool executed;         // Flag to indicate if the proposal is executed
    }

    // Mapping instead of array for O(1) access to proposals by ID
    mapping(uint8 => Proposal) public proposals;

    // Bit-level voter registry: 1 bit per proposal to track if voted
    // Each address maps to a uint256 (256-bit field)
    // For example: if user voted on proposal 2 => 0b000...100 (bit 2 set)
    mapping(address => uint256) private voterRegistry;

    // Optional: Tracks number of unique voters per proposal
    mapping(uint8 => uint32) public proposalVoterCount;

    // Events
    event ProposalCreated(uint8 indexed proposalId, bytes32 name);
    event Voted(address indexed voter, uint8 indexed proposalId);
    event ProposalExecuted(uint8 indexed proposalId);

    // === Core Functions ===

    /**
     * @dev Create a new proposal
     * @param name The proposal name (pass as bytes32 for gas efficiency)
     * @param duration Voting duration in seconds
     */
    function createProposal(bytes32 name, uint32 duration) external {
        require(duration > 0, "Duration must be > 0");

        // Increment counter - cheaper than .push() on an array
        uint8 proposalId = proposalCount;
        proposalCount++;

        // Construct in memory and assign to storage to save gas
        Proposal memory newProposal = Proposal({
            name: name,
            voteCount: 0,
            startTime: uint32(block.timestamp),
            endTime: uint32(block.timestamp) + duration,
            executed: false
        });

        proposals[proposalId] = newProposal;

        emit ProposalCreated(proposalId, name);
    }

    /**
     * @dev Vote on a proposal
     * @param proposalId The proposal ID
     */
    function vote(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");

        uint32 currentTime = uint32(block.timestamp);
        require(currentTime >= proposals[proposalId].startTime, "Voting not started");
        require(currentTime <= proposals[proposalId].endTime, "Voting ended");

        // Retrieve voter's bitfield
        uint256 voterData = voterRegistry[msg.sender];

        // Mask with 1 << proposalId to isolate that bit (e.g., 1 << 3 = 0b1000)
        uint256 mask = 1 << proposalId;

        // Check if user has already voted by ANDing with the mask
        require((voterData & mask) == 0, "Already voted");

        // Mark that proposal as voted by ORing the mask into the bitfield
        voterRegistry[msg.sender] = voterData | mask;

        // Increment vote counters
        proposals[proposalId].voteCount++;
        proposalVoterCount[proposalId]++;

        emit Voted(msg.sender, proposalId);
    }

    /**
     * @dev Execute a proposal after voting ends
     * @param proposalId The proposal ID
     */
    function executeProposal(uint8 proposalId) external {
        require(proposalId < proposalCount, "Invalid proposal");
        require(block.timestamp > proposals[proposalId].endTime, "Voting not ended");
        require(!proposals[proposalId].executed, "Already executed");

        proposals[proposalId].executed = true;

        emit ProposalExecuted(proposalId);

        // In a real contract, execution logic would go here
    }

    // === View Functions ===

    /**
     * @dev Check if an address has voted for a proposal
     * Uses bit masking to check if the bit at index proposalId is set
     */
    function hasVoted(address voter, uint8 proposalId) external view returns (bool) {
        return (voterRegistry[voter] & (1 << proposalId)) != 0;
    }

    /**
     * @dev Get full details of a proposal
     * Returns proposal details and whether it's currently active
     */
    function getProposal(uint8 proposalId) external view returns (
        bytes32 name,
        uint32 voteCount,
        uint32 startTime,
        uint32 endTime,
        bool executed,
        bool active
    ) {
        require(proposalId < proposalCount, "Invalid proposal");

        Proposal storage proposal = proposals[proposalId];

        return (
            proposal.name,
            proposal.voteCount,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            (block.timestamp >= proposal.startTime && block.timestamp <= proposal.endTime)
        );
    }
} 
