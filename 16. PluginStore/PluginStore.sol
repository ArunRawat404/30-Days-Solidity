// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PluginStore {
    // === Player Profile Data ===
    struct PlayerProfile {
        string name;
        string avatar;
    }

    // Maps user address to their profile data
    mapping(address => PlayerProfile) public profiles;

    // === Plugin System ===

    // Maps a plugin name/key to its contract address
    mapping(string => address) public plugins;

    // ========== Core Profile Logic ==========

    /**
     * @dev Allows a player to set their name and avatar
     */
    function setProfile(string memory _name, string memory _avatar) external {
        profiles[msg.sender] = PlayerProfile(_name, _avatar);
    }

    /**
     * @dev Returns profile information for a user
     */
    function getProfile(address user) external view returns (string memory, string memory) {
        PlayerProfile memory profile = profiles[user];
        return (profile.name, profile.avatar);
    }

    // ========== Plugin Management ==========

    /**
     * @dev Registers a plugin by associating a key with its contract address
     */
    function registerPlugin(string memory key, address pluginAddress) external {
        plugins[key] = pluginAddress;
    }

    /**
     * @dev Returns the contract address for a given plugin key
     */
    function getPlugin(string memory key) external view returns (address) {
        return plugins[key];
    }

    // ========== Plugin Execution ==========

    /**
     * @dev Executes a plugin function that changes state
     * @param key Registered plugin key
     * @param functionSignature The function to call (e.g., "setAchievement(address,string)")
     * @param user The user to pass as argument
     * @param argument The string argument to pass to the plugin
     */
    function runPlugin(
        string memory key,
        string memory functionSignature,
        address user,
        string memory argument
    ) external {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user, argument);
        (bool success, ) = plugin.call(data);
        require(success, "Plugin execution failed");
    }

    /**
     * @dev Executes a read-only plugin function using staticcall
     * @param key Registered plugin key
     * @param functionSignature The view function to call (e.g., "getAchievement(address)")
     * @param user The user to query
     */
    function runPluginView(
        string memory key,
        string memory functionSignature,
        address user
    ) external view returns (string memory) {
        address plugin = plugins[key];
        require(plugin != address(0), "Plugin not registered");

        bytes memory data = abi.encodeWithSignature(functionSignature, user);
        (bool success, bytes memory result) = plugin.staticcall(data);
        require(success, "Plugin view call failed");

        return abi.decode(result, (string));
    }
}
