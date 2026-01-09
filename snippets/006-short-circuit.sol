// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 100-2,100 gas per check | Order matters!

pragma solidity ^0.8.20;

// ❌ BAD: Expensive check first
contract BadOrdering {
    mapping(address => bool) public whitelist;
    
    function isAllowed(address user, uint256 amount) external view returns (bool) {
        // ❌ Reads storage FIRST (expensive: 2,100 gas)
        // Even if amount is 0, we still pay for storage read
        return whitelist[user] && amount > 0;
    }
    // Average gas: ~2,200 gas
}

// ✅ GOOD: Cheap check first
contract GoodOrdering {
    mapping(address => bool) public whitelist;
    
    function isAllowed(address user, uint256 amount) external view returns (bool) {
        // ✅ Check cheap condition FIRST (3 gas)
        // If amount is 0, we skip expensive storage read!
        return amount > 0 && whitelist[user];
    }
    // Average gas: ~100 gas when amount = 0 ⚡ 95% cheaper
}

// 🚀 BEST: Advanced short-circuit patterns
contract OptimalChecks {
    mapping(address => bool) public blacklist;
    mapping(address => uint256) public balances;
    
    function canTransfer(address from, uint256 amount) external view returns (bool) {
        // Order: cheapest → most expensive
        return 
            amount > 0 &&                    // 1. Memory check (3 gas)
            amount <= 1000 ether &&          // 2. Memory check (3 gas)
            !blacklist[from] &&              // 3. Storage read (2,100 gas)
            balances[from] >= amount;        // 4. Storage read (2,100 gas)
        
        // If any cheap check fails, expensive ones are skipped!
    }
}

// 📌 Rules for && (AND):
// Put cheapest checks FIRST
// - Memory/calldata checks (3-5 gas)
// - Simple comparisons (< > ==)
// - Storage reads LAST (2,100+ gas)

// 📌 Rules for || (OR):
// Put most likely TRUE condition FIRST
// If first is true, rest are skipped
