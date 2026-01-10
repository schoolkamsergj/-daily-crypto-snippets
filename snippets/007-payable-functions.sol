// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~24 gas per call | Works for any function

pragma solidity ^0.8.20;

// ❌ BAD: Non-payable function (default)
contract NonPayable {
    address public owner;
    uint256 public counter;
    
    constructor() {
        owner = msg.sender;
    }
    
    function incrementCounter() external {
        // Compiler adds check: require(msg.value == 0)
        // This check costs ~24 gas
        counter++;
    }
    // Gas cost: ~43,524 gas
}

// ✅ GOOD: Payable function (no ETH check)
contract WithPayable {
    address public owner;
    uint256 public counter;
    
    constructor() {
        owner = msg.sender;
    }
    
    function incrementCounter() external payable {
        // No msg.value check = saves 24 gas
        // Note: Function can still be called with 0 ETH
        counter++;
    }
    // Gas cost: ~43,500 gas ⚡ 24 gas cheaper
}

// 🚀 BEST: Strategic payable usage
contract OptimalPayable {
    address public owner;
    
    // ✅ Owner-only functions should be payable
    // Owner is trusted, no risk of accidental ETH send
    function setOwner(address newOwner) external payable {
        require(msg.sender == owner);
        owner = newOwner;
    }
    
    // ❌ Public functions should NOT be payable
    // Risk: Users might accidentally send ETH
    function publicFunction() external {
        // Keep non-payable for safety
    }
}

// 📌 When to use payable:
// ✅ Owner/admin functions (trusted callers)
// ✅ Internal helper functions
// ✅ Functions that accept ETH anyway
// ❌ Public functions (users might lose ETH)
// ❌ Critical functions (keep safety checks)

// 💡 Pro tip: Use payable for all onlyOwner functions
// Saves 24 gas per call with zero risk
