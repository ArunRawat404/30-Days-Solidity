// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title FriendsPlugin
 * @dev Stores and retrieves a user's friends list. Meant to be called via PluginStore.
 */
contract FriendsPlugin {
    // user => list of friends
    mapping(address => address[]) public friendsList;

    // Add a friend to the user's list (called via PluginStore)
    function addFriend(address user, address friendAddress) public {
        friendsList[user].push(friendAddress);
    }

    // Get the user's list of friends
    function getFriends(address user) public view returns (address[] memory) {
        return friendsList[user];
    }
}
