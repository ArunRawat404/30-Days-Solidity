// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Defines external contract behavior without implementation
interface IDepositBox {
    function getOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    // calldata = read-only input data for external functions, cheaper than memory and can't be modified.
    function storeSecret(string calldata secret) external;
    function getSecret() external view returns (string memory);
    function getBoxType() external pure returns (string memory);
    function getDepositTime() external view returns (uint256);
}
