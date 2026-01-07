// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~50-100 gas per error | More readable code

pragma solidity ^0.8.20;

// ❌ BAD: Using require with strings
contract WithRequire {
    address public owner;
    uint256 public balance;
    
    constructor() {
        owner = msg.sender;
    }
    
    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(amount <= balance, "Insufficient balance");
        require(amount > 0, "Amount must be greater than zero");
        
        balance -= amount;
    }
    // Gas cost: ~23,500 gas (stores error strings)
}

// ✅ GOOD: Using custom errors
contract WithCustomErrors {
    address public owner;
    uint256 public balance;
    
    // Define custom errors (gas-efficient)
    error Unauthorized();
    error InsufficientBalance(uint256 requested, uint256 available);
    error InvalidAmount();
    
    constructor() {
        owner = msg.sender;
    }
    
    function withdraw(uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized();
        if (amount > balance) revert InsufficientBalance(amount, balance);
        if (amount == 0) revert InvalidAmount();
        
        balance -= amount;
    }
    // Gas cost: ~23,400 gas ⚡ Cheaper + better debugging
}

// 🚀 Benefits:
// ✅ Saves gas (no string storage)
// ✅ Better error handling with parameters
// ✅ Cleaner code
// ✅ Easier to test and debug
