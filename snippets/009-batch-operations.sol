// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~21,000 gas per transaction | Batch multiple operations

pragma solidity ^0.8.20;

// ❌ BAD: Individual transactions
contract IndividualOps {
    mapping(address => uint256) public balances;
    
    // Each call costs 21,000 gas base + execution
    function updateBalance(address user, uint256 amount) external {
        balances[user] = amount;
    }
    
    // To update 5 users:
    // 5 transactions × 21,000 = 105,000 gas wasted on base costs
}

// ✅ GOOD: Batch operations
contract BatchOps {
    mapping(address => uint256) public balances;
    
    // Update multiple users in ONE transaction
    function batchUpdateBalances(
        address[] calldata users,
        uint256[] calldata amounts
    ) external {
        require(users.length == amounts.length, "Length mismatch");
        
        for (uint256 i = 0; i < users.length;) {
            balances[users[i]] = amounts[i];
            unchecked { ++i; }
        }
    }
    
    // To update 5 users:
    // 1 transaction × 21,000 = 21,000 gas base cost
    // Saves 84,000 gas! ⚡
}

// 🚀 BEST: Advanced batch patterns
contract OptimalBatch {
    mapping(address => uint256) public balances;
    
    // Batch with different operations
    function batchMixed(
        address[] calldata transferTo,
        uint256[] calldata amounts,
        address[] calldata resetUsers
    ) external {
        // Batch transfers
        uint256 length = transferTo.length;
        for (uint256 i = 0; i < length;) {
            balances[transferTo[i]] += amounts[i];
            unchecked { ++i; }
        }
        
        // Batch resets
        length = resetUsers.length;
        for (uint256 i = 0; i < length;) {
            balances[resetUsers[i]] = 0;
            unchecked { ++i; }
        }
    }
    
    // Batch with early exit on error
    function safeBatchUpdate(
        address[] calldata users,
        uint256[] calldata amounts
    ) external returns (bool) {
        if (users.length != amounts.length) return false;
        
        for (uint256 i = 0; i < users.length;) {
            if (amounts[i] > 1000 ether) return false;  // Validation
            balances[users[i]] = amounts[i];
            unchecked { ++i; }
        }
        return true;
    }
}

// 📌 Benefits of batching:
// ✅ Saves 21,000 gas per avoided transaction
// ✅ Faster execution (one tx vs many)
// ✅ Atomic operations (all succeed or all fail)
// ✅ Better UX (one confirmation)

// ⚠️ Watch out for:
// ❌ Gas limit (max ~30M gas per block)
// ❌ Array too large = out of gas
// ❌ One failure = entire batch reverts

// 💡 Pro tip: Add max length check
// require(users.length <= 100, "Batch too large");
