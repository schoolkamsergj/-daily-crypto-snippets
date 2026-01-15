// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 200-20,000+ gas | Avoid strings when possible!

pragma solidity ^0.8.20;

// ❌ BAD: Storing full strings in storage
contract StringStorage {
    string public userName;    // Very expensive!
    string public description; // Even more expensive!
    
    function setUserName(string memory name) external {
        userName = name;  // Costs 20,000+ gas per character!
    }
    // Gas cost for "Alice": ~100,000 gas
}

// ✅ GOOD: Use bytes32 for short strings
contract Bytes32Storage {
    bytes32 public userName;  // Fixed size = cheaper
    
    function setUserName(string memory name) external {
        require(bytes(name).length <= 32, "Name too long");
        userName = stringToBytes32(name);
    }
    
    function stringToBytes32(string memory str) internal pure returns (bytes32) {
        bytes memory bStr = bytes(str);
        bytes32 result;
        assembly {
            result := mload(add(bStr, 32))
        }
        return result;
    }
    // Gas cost for "Alice": ~23,000 gas ⚡ 77% cheaper
}

// 🚀 BEST: Multiple optimization strategies
contract OptimalStrings {
    
    // Strategy 1: Use bytes32 for identifiers
    mapping(address => bytes32) public userNames;  // 32 chars max
    
    // Strategy 2: Store hash instead of full string
    mapping(address => bytes32) public documentHashes;
    
    function storeDocumentHash(string calldata document) external {
        documentHashes[msg.sender] = keccak256(bytes(document));
        // Verify later: require(keccak256(bytes(doc)) == stored)
    }
    
    // Strategy 3: Use events for long strings
    event MetadataUpdated(address indexed user, string metadata);
    
    function updateMetadata(string calldata metadata) external {
        // Don't store - just emit event
        emit MetadataUpdated(msg.sender, metadata);
        // Frontend can query event logs
    }
    
    // Strategy 4: Use error codes instead of strings
    error InvalidInput(uint8 errorCode);
    // 1 = too short, 2 = too long, 3 = invalid chars
    
    function validateInput(string calldata input) external pure {
        if (bytes(input).length < 3) revert InvalidInput(1);
        if (bytes(input).length > 32) revert InvalidInput(2);
    }
    
    // Strategy 5: Efficient string comparison
    function compareStrings(string memory a, string memory b) 
        internal pure returns (bool) 
    {
        // Don't compare char by char!
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
    
    // Strategy 6: Use calldata for read-only strings
    function processString(string calldata data) external pure returns (uint256) {
        // calldata = no copy to memory
        return bytes(data).length;
    }
}

// 📊 String storage costs (approximate):
// string (32 chars) = ~640,000 gas
// bytes32           = ~20,000 gas (32x cheaper!)
// bytes32 hash      = ~20,000 gas + indexing benefit
// event emission    = ~1,000 gas (640x cheaper!)

// 📌 Best practices:
// ✅ Use bytes32 for names/symbols (≤32 chars)
// ✅ Use keccak256 hash for verification
// ✅ Emit events instead of storing
// ✅ Use error codes instead of error strings
// ✅ Use calldata for function parameters
// ✅ Store strings off-chain (IPFS) + hash on-chain

// 💡 Real-world examples:
// ERC20: name() returns string but stored as bytes32 internally
// ENS: stores namehash (bytes32), not full domain
// NFTs: tokenURI returns string but hash stored on-chain

// ⚠️ When you MUST use strings:
// ✅ ERC20/721 standard compliance
// ✅ User-facing text that varies greatly
// ✅ Data that must be queryable on-chain
