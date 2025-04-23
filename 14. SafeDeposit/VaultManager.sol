// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IDepositBox} from "./IDepositBox.sol";
import {BasicDepositBox} from "./BasicDepositBox.sol";
import {PremiumDepositBox} from "./PremiumDepositBox.sol";
import {TimeLockedDepositBox} from "./TimeLockedDepositBox.sol";

contract VaultManager {
    // Maps each user's address to an array of their deposit box contract addresses
    mapping(address => address[]) private userDepositBoxes;

    // Stores user-defined names for deposit boxes (mapped by box address)
    mapping(address => string) private boxNames;

    event BoxCreated(address indexed owner, address indexed boxAddress, string boxType);
    event BoxNamed(address indexed boxAddress, string name);

    // Deploys a new BasicDepositBox and assigns it to the caller
    function createBasicBox() external returns (address) {
        BasicDepositBox box = new BasicDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Basic");
        return address(box);
    }

    // Deploys a new PremiumDepositBox and assigns it to the caller
    function createPremiumBox() external returns (address) {
        PremiumDepositBox box = new PremiumDepositBox();
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "Premium");
        return address(box);
    }

    // Deploys a new TimeLockedDepositBox with the specified lock duration
    function createTimeLockedBox(uint256 lockDuration) external returns (address) {
        TimeLockedDepositBox box = new TimeLockedDepositBox(lockDuration);
        userDepositBoxes[msg.sender].push(address(box));
        emit BoxCreated(msg.sender, address(box), "TimeLocked");
        return address(box);
    }

    // Allows the owner to assign a custom name to one of their boxes
    function nameBox(address boxAddress, string calldata name) external {
        // Convert the box address to the deposit box interface for interaction
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        boxNames[boxAddress] = name;
        emit BoxNamed(boxAddress, name);
    }

    // Allows the owner to store a secret in their box
    function storeSecret(address boxAddress, string calldata secret) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.storeSecret(secret);
    }

    // Transfers ownership of a box to a new owner and updates internal mappings
    function transferBoxOwnership(address boxAddress, address newOwner) external {
        IDepositBox box = IDepositBox(boxAddress);
        require(box.getOwner() == msg.sender, "Not the box owner");

        box.transferOwnership(newOwner);

        // Remove the box from the old owner's list (order is not preserved)
        address[] storage boxes = userDepositBoxes[msg.sender];
        for (uint i = 0; i < boxes.length; i++) {
            if (boxes[i] == boxAddress) {
                boxes[i] = boxes[boxes.length - 1];
                boxes.pop();
                break;
            }
        }

        // Add the box to the new owner's list
        userDepositBoxes[newOwner].push(boxAddress);
    }

    // Returns all deposit boxes owned by a user
    function getUserBoxes(address user) external view returns (address[] memory) {
        return userDepositBoxes[user];
    }

    // Returns the custom name assigned to a deposit box
    function getBoxName(address boxAddress) external view returns (string memory) {
        return boxNames[boxAddress];
    }

    // Returns key metadata about a deposit box
    function getBoxInfo(address boxAddress) external view returns (
        string memory boxType,
        address owner,
        uint256 depositTime,
        string memory name
    ) {
        IDepositBox box = IDepositBox(boxAddress);
        return (
            box.getBoxType(),
            box.getOwner(),
            box.getDepositTime(),
            boxNames[boxAddress]
        );
    }
}
