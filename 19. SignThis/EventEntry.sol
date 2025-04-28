// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract EventEntry {
    string public eventName;
    address public organizer;
    uint256 public eventDate;
    uint256 public maxAttendees;
    uint256 public attendeeCount;
    bool public isEventActive;

    mapping(address => bool) public hasAttended;

    // Emitted once during deployment
    event EventCreated(string name, uint256 date, uint256 maxAttendees);
    event AttendeeCheckedIn(address attendee, uint256 timestamp);
    event EventStatusChanged(bool isActive);

    constructor(string memory _eventName, uint256 _eventDate_unix, uint256 _maxAttendees) {
        eventName = _eventName;
        eventDate = _eventDate_unix;
        maxAttendees = _maxAttendees;
        organizer = msg.sender;
        isEventActive = true;

        emit EventCreated(_eventName, _eventDate_unix, _maxAttendees);
    }

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "Only the event organizer can call this function");
        _;
    }

    function setEventStatus(bool _isActive) external onlyOrganizer {
        isEventActive = _isActive;
        emit EventStatusChanged(_isActive);
    }

    // Generates a unique hash based on the contract address, event name, and attendee address
    function getMessageHash(address _attendee) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), eventName, _attendee));
    }

    // Returns Ethereum-specific signed message hash (EIP-191 format) for signature verification
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    // Verifies if the given signature was signed by the organizer for the attendee.
    function verifySignature(address _attendee, bytes memory _signature) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_attendee);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        // recovers the signer address from the signature, and checks if it matches the organizer.
        return recoverSigner(ethSignedMessageHash, _signature) == organizer;
    }

    // This function recovers the Ethereum address that signed a given message hash with a provided signature.
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        // Verify that the signature length is exactly 65 bytes, which is the standard length for Ethereum signatures.
        require(_signature.length == 65, "Invalid signature length");

        // Ethereum signatures are composed of three components: r, s (both 32 bytes), and v (1 byte). These components are used to uniquely identify the signer.
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Using inline assembly to extract the three components from the signature.
        // The `mload` operation loads 32 bytes from the provided memory address.
        // While extracting a single byte like 'v', it still loads a full 32-byte chunk,

        assembly {
            // Load 'r' from the signature (bytes 32-63).
            r := mload(add(_signature, 32))
            // Load 's' from the signature (bytes 64-95).
            s := mload(add(_signature, 64))
            // Load 'v' from the signature (byte 96).
            v := byte(0, mload(add(_signature, 96)))
        }

        // The value of 'v' in an Ethereum signature can either be 27 or 28. Some systems might use 0 or 1, so we adjust it if needed.
        if (v < 27) {
            v += 27; // Adjust the 'v' to be either 27 or 28.
        }

        // Ensure that the value of 'v' is either 27 or 28, as these are the only valid values for Ethereum signatures.
        require(v == 27 || v == 28, "Invalid signature 'v' value");

        // The ecrecover function is a built-in Ethereum function that verifies the signature.
        // It takes the message hash (_ethSignedMessageHash), and the signature components (r, s, v).
        // It returns the address of the signer who signed the message.
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function checkIn(bytes memory _signature) external {
        require(isEventActive, "Event is not active");
        require(block.timestamp <= eventDate + 1 days, "Event has ended");
        require(!hasAttended[msg.sender], "Attendee has already checked in");
        require(attendeeCount < maxAttendees, "Maximum attendees reached");
        require(verifySignature(msg.sender, _signature), "Invalid signature");

        hasAttended[msg.sender] = true;
        attendeeCount++;

        emit AttendeeCheckedIn(msg.sender, block.timestamp);
    }
}
