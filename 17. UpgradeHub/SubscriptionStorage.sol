// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./SubscriptionStorageLayout.sol";

contract SubscriptionStorage is SubscriptionStorageLayout {
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _logicContract) {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    /**
     * @notice Upgrade to a new logic contract.
     * Only the owner can call this.
     */
    function upgradeTo(address _newLogic) external onlyOwner {
        logicContract = _newLogic;
    }

    /**
     * @notice Special function to accept plain ETH transfers.
     * Allows the contract to receive Ether without any calldata.
     */
    receive() external payable {}

    /**
     * @notice Special function triggered when an unknown function is called.
     * Forwards the call to the logic contract using delegatecall,
     * so the logic code executes but uses the proxy's storage and context.
     */
    fallback() external payable {
        address impl = logicContract;
        require(impl != address(0), "Logic contract not set");
    
        // Assembly block: allows writing low-level EVM instructions directly for optimized and manual control
        assembly {
            // Copy the calldata (function + arguments) into memory starting at position 0
            calldatacopy(0, 0, calldatasize())

            // Delegate call to the logic contract
            // - Runs the logic contract's code
            // - Uses the proxy contract's storage, msg.sender, and msg.value
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // Copy the return data from the logic contract's execution
            returndatacopy(0, 0, returndatasize())

            // If delegatecall failed, revert and return the error
            switch result
            case 0 { revert(0, returndatasize()) }
            // If delegatecall succeeded, return the response to the original caller
            default { return(0, returndatasize()) }
        }
    }
}
