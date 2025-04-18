// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import {ScientificCalculator} from "./ScientificCalculator.sol";

contract Calculator {  
    address public owner;
    address public scientificCalculatorAddress;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function setScientificCalculator(address _address) public onlyOwner {
        scientificCalculatorAddress = _address;
    }

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a + b;
        return result;
    }

    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a - b;
        return result;
    }
 
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 result = a * b;
        return result;
    }
 
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b != 0, "Cannot divide by zero");
        uint256 result = a / b;
        return result;
    }

    function calculatePower(uint256 base, uint256 exponent) public view returns (uint256) {
        // Cast the address to the ScientificCalculator contract to access its functions
        ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);

        // Call the power function from the ScientificCalculator contract
        uint256 result = scientificCalc.power(base, exponent);
        return result;
    }

    function calculateSquareRoot(uint256 number) public returns (uint256) {
        // Encode the function call with its signature and parameter
        bytes memory data = abi.encodeWithSignature("squareRoot(uint256)", number);

        // Perform a low-level call to the ScientificCalculator contract
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");
        
        // Decode the returned data to get the result
        uint256 result = abi.decode(returnData, (uint256));
        return result;
    }
}
