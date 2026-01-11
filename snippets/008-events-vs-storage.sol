// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~19,000+ gas per record | Use events for historical data

pragma solidity ^0.8.20;

// ❌ BAD: Storing historical data in storage
contract WithStorage {
    struct Transaction {
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }
    
    Transaction[] public history;  // Very expensive!
    
    function transfer(address to, uint256 amount) external {
        // Store in array costs ~20,000+ gas
        history.push(Transaction({
            from: msg.sender,
            to: to,
            amount: amount,
            timestamp: block.timestamp
        }));
    }
    // Gas cost per transfer: ~45,000 gas
}

// ✅ GOOD: Using events for historical data
contract WithEvents {
    // Events are stored in logs, not in contract storage
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    
    function transfer(address to, uint256 amount) external {
        // Emit event costs only ~375 gas per indexed parameter
        emit Transfer(msg.sender, to, amount, block.timestamp);
    }
    // Gas cost per transfer: ~26,000 gas ⚡ 73% cheaper!
}

// 🚀 BEST: Hybrid approach - storage only when needed
contract OptimalPattern {
    mapping(address => uint256) public balances;  // Current state
    
    // Events for history (frontend can query)
    event BalanceChanged(address indexed user, uint256 newBalance, uint256 timestamp);
    event LargeTransfer(address indexed from, address indexed to, uint256 amount);
    
    function updateBalance(address user, uint256 newBalance) external {
        balances[user] = newBalance;  // Storage for current state
        emit BalanceChanged(user, newBalance, block.timestamp);  // Event for history
        
        // Emit special event only when needed
        if (newBalance > 1000 ether) {
            emit LargeTransfer(msg.sender, user, newBalance);
        }
    }
}

// 📌 When to use Events:
// ✅ Historical records (transactions, changes)
// ✅ Data for frontend/analytics
// ✅ Audit trails
// ✅ Notifications

// 📌 When to use Storage:
// ✅ Current state (balances, ownership)
// ✅ Data needed by smart contract logic
// ✅ Data that must be queryable on-chain

// 💡 Pro tip: Use "indexed" for up to 3 parameters
// Makes events searchable by those parameters
