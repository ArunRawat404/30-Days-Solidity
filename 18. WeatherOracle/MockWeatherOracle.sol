// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Import Chainlink's AggregatorV3Interface to simulate a standard oracle feed (like price feeds or, here, rainfall data).
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// Import OpenZeppelin's Ownable contract to restrict sensitive functions to the contract owner.
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockWeatherOracle is AggregatorV3Interface, Ownable {
    // Number of decimals for the rainfall data (set to 0 since rainfall is in whole millimeters).
    uint8 private _decimals;
    // Description of the oracle feed.
    string private _description;
    // Unique identifier for each data round.
    uint80 private _roundId;
    // Timestamp of the latest update.
    uint256 private _timestamp;
    // Block number when the last update occurred.
    uint256 private _lastUpdateBlock;

    constructor() Ownable(msg.sender) {
        _decimals = 0;
        _description = "MOCK/RAINFALL/USD";
        _roundId = 1;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // Return the number of decimals for rainfall data.
    function decimals() external view override returns (uint8) {
        return _decimals;
    }    

    // Return the description of the feed.
    function description() external view override returns (string memory) {
        return _description;
    }

    // Return a static version number.
    function version() external pure override returns (uint256) {
        return 1;
    }

    // Return simulated data for a specific round.
    function getRoundData(uint80 _roundId_) external view override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId_, _rainfall(), _timestamp, _timestamp, _roundId_);
    }

    // Return the latest simulated data.
    function latestRoundData() external view override 
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (_roundId, _rainfall(), _timestamp, _timestamp, _roundId);
    }

    // function to calculate pseudo-random rainfall.
    function _rainfall() public view returns (int256) {
        uint256 blocksSinceLastUpdate = block.number - _lastUpdateBlock;
        uint256 randomFactor = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            blocksSinceLastUpdate
        ))) % 1000; // Random number between 0 and 999

        return int256(randomFactor);
    }

    // Internal function to update roundId and timestamps (simulate a new data reading).
    function _updateRandomRainfall() private {
        _roundId++;
        _timestamp = block.timestamp;
        _lastUpdateBlock = block.number;
    }

    // Public function to force a new random rainfall update (anyone can call).
    function updateRandomRainfall() external {
        _updateRandomRainfall();
    }
}
