// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal Merkle proof verify (calldata). Similar idea to OZ verifyCalldata.
library MerkleVerify {
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf)
        internal pure returns (bool)
    {
        bytes32 h = leaf;
        for (uint256 i = 0; i < proof.length; ) {
            bytes32 p = proof[i];
            h = (h < p) ? keccak256(abi.encodePacked(h, p)) : keccak256(abi.encodePacked(p, h));
            unchecked { ++i; }
        }
        return h == root;
    }
}

contract MerkleAllowlist {
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    error AlreadyClaimed();
    error InvalidProof();

    constructor(bytes32 root) { merkleRoot = root; }

    function claim(bytes32[] calldata proof) external {
        if (claimed[msg.sender]) revert AlreadyClaimed();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleVerify.verifyCalldata(proof, merkleRoot, leaf)) revert InvalidProof();
        claimed[msg.sender] = true;
    }
}
