// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/// @title IERC721 — Minimal interface for ERC721 compliant contracts
interface IERC721 {
    // Emitted when ownership of any NFT changes via transfer
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // Emitted when the owner approves another address to transfer a specific NFT
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // Emitted when the owner enables or disables an operator to manage all their NFTs
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // Returns the number of NFTs owned by an address
    function balanceOf(address owner) external view returns (uint256);

    // Returns the owner of a specific tokenId
    function ownerOf(uint256 tokenId) external view returns (address);

    // Approves another address to transfer the given tokenId
    function approve(address to, uint256 tokenId) external;

    // Returns the address approved to transfer the given tokenId
    function getApproved(uint256 tokenId) external view returns (address);

    // Approves or revokes permission for an operator to manage all caller's NFTs
    function setApprovalForAll(address operator, bool approved) external;

    // Checks if an operator is approved to manage all of an owner’s assets
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    // Transfers tokenId from one address to another without safety checks
    function transferFrom(address from, address to, uint256 tokenId) external;

    // Safely transfers tokenId, checking that the recipient can handle ERC721 tokens
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    // Safely transfers tokenId with additional data payload
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

/// @title IERC721Receiver — Interface for contracts receiving safe ERC721 transfers
interface IERC721Receiver {
    /// @return The selector to confirm the token transfer
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract SimpleNFT is IERC721 {
    string public name;
    string public symbol;

    uint256 private _tokenIdCounter = 1;

    // Maps each tokenId to its owner’s address
    mapping(uint256 => address) private _owners;

    // Maps each owner’s address to their NFT balance
    mapping(address => uint256) private _balances;

    // Maps each tokenId to the approved address allowed to transfer it
    mapping(uint256 => address) private _tokenApprovals;

    // Maps each owner to operator approvals (true if operator is approved to manage all of owner’s NFTs)
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Maps each tokenId to its metadata URI (e.g., image, name, description)
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view override returns (uint256) {
            require(owner != address(0), "Zero address");
            return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token doesn't exist");
        return owner;
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "Already owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(operator != msg.sender, "Self approval");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "Not owner");
        require(to != address(0), "Zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        // The delete keyword in Solidity is used to reset a variable to its default value.
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        // Ensure recipient can handle ERC721 tokens
        require(_checkOnERC721Received(from, to, tokenId, data), "Not ERC721Receiver");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _owners[tokenId];
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        // If `to` is a contract (has bytecode), we need to verify that it implements the ERC721Receiver interface.
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                // Check if the return value matches the expected interface selector
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch {
                // If the call fails (reverts or throws), recipient is not compliant
                return false;
            }
        }
        // If `to` is an EOA (Externally Owned Account), it's safe to send the NFT
        return true;
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not authorized");
        _safeTransfer(from, to, tokenId, data);
    }
    
    function mint(address to, string memory uri) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token doesn't exist");
        return _tokenURIs[tokenId];
    }
}
