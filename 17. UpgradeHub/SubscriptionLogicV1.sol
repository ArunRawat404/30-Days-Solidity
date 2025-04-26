// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./SubscriptionStorageLayout.sol";

contract SubscriptionLogicV1 is SubscriptionStorageLayout {
    function addPlan(uint8 planId, uint256 price, uint256 duration) external {
        planPrices[planId] = price;
        planDuration[planId] = duration;
    }

    function subscribe(uint8 planId) external payable {
        require(planPrices[planId] > 0, "Invalid plan");
        require(msg.value >= planPrices[planId], "Insufficient payment");

        Subscription storage sub = subscriptions[msg.sender];
        if (block.timestamp < sub.expiry) {
            sub.expiry += planDuration[planId];
        } else {
            sub.expiry = block.timestamp + planDuration[planId];
        }

        sub.planId = planId;
        sub.paused = false;
    }

    function isActive(address user) external view returns (bool) {
        Subscription storage sub = subscriptions[user];
        return (block.timestamp < sub.expiry && !s.paused);
    }
}
