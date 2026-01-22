// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: Depends on use case | Choose right data structure

pragma solidity ^0.8.20;

// ❌ BAD: Using array when mapping is better
contract BadArrayUsage {
    address[] public whitelist;
    
    function addToWhitelist(address user) external {
        whitelist.push(user);  // Gas: 20,000-40,000
    }
    
    function isWhitelisted(address user) external view returns (bool) {
        // O(n) search - VERY expensive!
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == user) return true;
        }
        return false;
    }
    // Gas for checking 100 users: ~200,000+ gas ❌
}

// ✅ GOOD: Using mapping for lookups
contract GoodMappingUsage {
    mapping(address => bool) public whitelist;
    
    function addToWhitelist(address user) external {
        whitelist[user] = true;  // Gas: ~22,000
    }
    
    function isWhitelisted(address user) external view returns (bool) {
        return whitelist[user];  // Gas: ~2,100 (constant time!)
    }
    // Gas for checking: ~2,100 gas ⚡ 100x cheaper
}

// 🚀 BEST: Hybrid approach when you need both
contract HybridApproach {
    mapping(address => bool) public isWhitelisted;
    address[] public whitelistArray;  // Only if you NEED to iterate
    
    function addToWhitelist(address user) external {
        if (isWhitelisted[user]) return;  // Skip if already added
        
        isWhitelisted[user] = true;
        whitelistArray.push(user);
    }
    
    function checkWhitelist(address user) external view returns (bool) {
        return isWhitelisted[user];  // Fast O(1) lookup
    }
    
    function getAllWhitelisted() external view returns (address[] memory) {
        return whitelistArray;  // When you need all addresses
    }
}

// 📊 Detailed comparison
contract ComparisonExamples {
    
    // Use Case 1: User balances (many lookups)
    mapping(address => uint256) public balances;  // ✅ Perfect
    // uint256[] balances;  // ❌ Wrong - can't lookup by address
    
    // Use Case 2: Top 10 leaderboard (small, ordered)
    address[10] public topUsers;  // ✅ Fixed size array OK
    // mapping(uint256 => address) public topUsers;  // ❌ Overkill
    
    // Use Case 3: Token IDs owned by user
    mapping(address => uint256[]) public tokensOwned;  // ✅ Dynamic array per user
    
    // Use Case 4: Unique items list
    mapping(uint256 => bool) public exists;
    uint256[] public itemsList;  // ✅ Both needed
    
    function addItem(uint256 id) external {
        if (exists[id]) return;
        exists[id] = true;
        itemsList.push(id);
    }
}

// 📌 Decision matrix:

// Use MAPPING when:
// ✅ Need fast lookups (O(1))
// ✅ Key-value pairs
// ✅ Checking existence
// ✅ Large dataset
// ✅ Sparse data (not all keys used)
// Examples: balances, whitelist, ownership

// Use ARRAY when:
// ✅ Need to iterate all items
// ✅ Order matters
// ✅ Small dataset (<100 items)
// ✅ Need length() function
// ✅ Sequential access
// Examples: small lists, ordered data, history

// Use BOTH when:
// ✅ Need fast lookup AND iteration
// ✅ Can afford extra storage
// ✅ Items rarely removed
// Example: whitelist with admin panel

// 💡 Gas costs:
// mapping write:    ~22,000 gas (new key)
// mapping read:     ~2,100 gas
// array push:       ~20,000-40,000 gas (grows)
// array read [i]:   ~2,100 gas
// array length:     ~2,100 gas
// iterate array[100]: ~200,000 gas

// ⚠️ Common mistakes:
// ❌ Using array for existence checks
// ❌ Using mapping when order matters
// ❌ Iterating large arrays on-chain
// ❌ Not using mapping for user data
// ❌ Storing index in mapping (just use array)

// 🚀 Advanced patterns:
contract AdvancedPatterns {
    // Pattern 1: Enumerable mapping
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _holderAtIndex;
    uint256 public holderCount;
    
    function addHolder(address user) internal {
        if (_balances[user] == 0) {
            _holderAtIndex[holderCount] = user;
            holderCount++;
        }
        _balances[user] += 1;
    }
    
    // Pattern 2: Packed array (bitmap)
    uint256[256] public bitmap;  // 256 * 256 bits = 65,536 flags
    
    function setBit(uint256 index) external {
        uint256 bucket = index / 256;
        uint256 bit = index % 256;
        bitmap[bucket] |= (1 << bit);
    }
}
