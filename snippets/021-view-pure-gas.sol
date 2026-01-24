// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 0 gas externally | 2,100+ gas internally when optimized

pragma solidity ^0.8.20;

// 📌 Key concepts:
// view  = reads state, doesn't modify
// pure  = doesn't read or modify state
// External calls to view/pure = FREE (no tx, just RPC call)
// Internal calls to view/pure = COSTS GAS

// ❌ BAD: Expensive view function
contract ExpensiveView {
    uint256[] public data;
    
    function sumArray() public view returns (uint256 total) {
        // Reading from storage in loop = expensive
        for (uint256 i = 0; i < data.length; i++) {
            total += data[i];  // SLOAD every iteration
        }
    }
    // Gas when called internally: ~2,100 * length
}

// ✅ GOOD: Optimized view with memory
contract OptimizedView {
    uint256[] public data;
    
    function sumArray() public view returns (uint256 total) {
        // Load to memory once
        uint256[] memory _data = data;
        uint256 length = _data.length;
        
        for (uint256 i = 0; i < length;) {
            total += _data[i];  // MLOAD instead of SLOAD
            unchecked { ++i; }
        }
    }
    // Gas when called internally: ~500 + 100 * length ⚡ Much cheaper
}

// 🚀 BEST: Pure functions for computations
contract PureFunctions {
    
    // Pure = no storage access = cheapest
    function calculateFee(uint256 amount, uint256 bps) 
        public pure returns (uint256) 
    {
        unchecked {
            return (amount * bps) / 10000;
        }
    }
    // Gas: ~200 (minimal)
    
    // View = reads constant/immutable = cheap
    uint256 public constant FEE_BPS = 100;
    
    function getFee(uint256 amount) public pure returns (uint256) {
        return (amount * FEE_BPS) / 10000;
    }
    
    // Pattern: Cache storage reads
    mapping(address => uint256) public balances;
    
    function processBalance(address user) external view returns (uint256) {
        uint256 balance = balances[user];  // One SLOAD
        
        uint256 result = balance * 2;
        result = result + balance;  // Reuse cached value
        result = result - balance;  // No extra SLOAD
        
        return result;
    }
}

// 📊 Advanced view optimizations
contract AdvancedView {
    struct User {
        uint256 balance;
        uint256 rewards;
        bool active;
    }
    
    mapping(address => User) public users;
    
    // ❌ BAD: Multiple storage reads
    function getUserDataBad(address addr) 
        external view returns (uint256, uint256, bool) 
    {
        return (
            users[addr].balance,   // SLOAD 1
            users[addr].rewards,   // SLOAD 2  
            users[addr].active     // SLOAD 3
        );
    }
    
    // ✅ GOOD: Single storage read
    function getUserDataGood(address addr) 
        external view returns (uint256, uint256, bool) 
    {
        User memory user = users[addr];  // One SLOAD
        return (user.balance, user.rewards, user.active);
    }
    
    // Pattern: Return struct instead of multiple values
    function getUserStruct(address addr) 
        external view returns (User memory) 
    {
        return users[addr];  // Most efficient
    }
}

// 💡 Best practices:
// ✅ Use view for read-only functions
// ✅ Use pure for calculations (no state)
// ✅ Cache storage reads in memory
// ✅ Return structs instead of tuple
// ✅ Load arrays to memory before loops
// ✅ Use unchecked for safe math in pure

// 📌 When view/pure costs gas:
// ❌ Called from another contract function (internal)
// ❌ Called in same transaction
// ✅ Called externally via RPC (FREE)
// ✅ Called from frontend (FREE)

// ⚠️ Don't:
// ❌ Mark as view if it can be pure
// ❌ Read storage multiple times
// ❌ Loop over storage arrays
// ❌ Call expensive view from payable function
