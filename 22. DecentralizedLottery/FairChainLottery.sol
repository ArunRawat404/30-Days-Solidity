// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// VRFConsumerBaseV2Plus — Base contract from Chainlink that provides the fulfillRandomWords function.
// Chainlink calls this function automatically when randomness is fulfilled.
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

// VRFV2PlusClient — Utility library from Chainlink to help build and encode randomness requests.
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract FairChainLottery is VRFConsumerBaseV2Plus {
    // Enum to represent the different states of the lottery
    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;

    address payable[] public players; 
    address public recentWinner;      
    uint256 public entryFee;          

    // Chainlink VRF configuration parameters
    // The subscription ID linked to your Chainlink VRF account. It must be funded with LINK tokens.
    uint256 public subscriptionId;
    // The key hash identifies a specific Chainlink VRF job (or gas lane) on the network.
    bytes32 public keyHash;
    // The maximum amount of gas that the fulfillRandomWords callback can consume.
    uint32 public callbackGasLimit = 100000;
    // The number of block confirmations the VRF coordinator should wait before responding.
    uint16 public requestConfirmations = 3;
    // Number of random values to request. Here, we only need one random number.
    uint32 public numWords = 1;
    // Stores the request ID from the latest VRF request. Useful for tracking.
    uint256 public latestRequestId;

    constructor(
        // The VRF Coordinator contract address for the target blockchain network.
        address vrfCoordinator,
        uint256 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Can't start yet");
        lotteryState = LOTTERY_STATE.OPEN;
    }
        
    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;

        // Creates a local memory struct named req
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            // Converts extra arguments into bytes format expected by Chainlink VRF.
            // Setting nativePayment: true means we’ll pay for the VRF request using the blockchain’s native token (e.g., ETH) instead of LINK.
            extraArgs: VRFV2PlusClient._argsToBytes(
                VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
            )
        });

        latestRequestId = s_vrfCoordinator.requestRandomWords(req);
    }

    //  This function is Automatically Called by Chainlink
    function fulfillRandomWords(uint256, uint256[] calldata randomWords) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready to pick winner");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        delete players;
        // or we can reset the players array by doing this also: players = new address payable[](0); 

        lotteryState = LOTTERY_STATE.CLOSED;

        (bool success, ) = winner.call{value: address(this).balance}("");
        require(success, "Failed to send ETH to winner");
    }   

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}
