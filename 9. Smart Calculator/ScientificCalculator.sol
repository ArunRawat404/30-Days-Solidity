// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ScientificCalculator {
    function power(uint256 base, uint256 exponent) public pure returns(uint256) {
        if(exponent == 0) return 1;
        else return (base ** exponent);
    }

    /**
    * Newton's Method is an iterative approach to finding roots of functions.
    * For square roots, we solve f(x) = x^2 - number = 0, using the update formula:
    *     xₙ₊₁ = (xₙ + number / xₙ) / 2
    *
    * This function performs 10 iterations starting from an initial guess.
    * All values are treated as uint256 — input must be non-negative.
    * Note: This is an approximation, not an exact integer root.
    *
    * Example:
    *     squareRoot(10) ≈ 3 (actual sqrt ≈ 3.16)
    */
 
    function squareRoot(uint256 number) public pure returns (uint256) {
        if (number == 0) return 0;

        uint256 guess = number / 2;
        for (uint256 i = 0; i < 10; i++) {
            guess = (guess + number / guess) / 2;
        }
        return guess;
    } 
}
