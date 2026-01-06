// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~300-1000 gas per call | Best for arrays and structs

pragma solidity ^0.8.20;

// ❌ BAD: Using memory for read-only data
contract MemoryUsage {
    struct User {
        address wallet;
        uint256 balance;
        string name;
    }
    
    function processUsers(User[] memory users) external pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < users.length; i++) {
            total += users[i].balance;
        }
        return total;
    }
    // Gas cost: ~2,800 gas (copies data to memory)
}

// ✅ GOOD: Using calldata for read-only data
contract CalldataUsage {
    struct User {
        address wallet;
        uint256 balance;
        string name;
    }
    
    function processUsers(User[] calldata users) external pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < users.length; i++) {
            total += users[i].balance;
        }
        return total;
    }
    // Gas cost: ~1,800 gas ⚡ 35% cheaper (no copying)
}

// 📌 Key Rules:
// memory  = mutable, for internal functions, expensive
// calldata = immutable, for external functions, cheap
// storage = persistent blockchain state, most expensive
