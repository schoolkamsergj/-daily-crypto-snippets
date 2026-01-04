// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~2,100 per SLOAD | Deployment: ~21,000 gas

pragma solidity ^0.8.20;

// ❌ BAD: Regular storage variable
contract BeforeOptimization {
    uint256 public minimumUSD = 5e18; // Uses storage slot
    address public owner;              // Uses storage slot
    
    constructor() {
        owner = msg.sender;
    }
    // Deployment cost: ~859,000 gas
}

// ✅ GOOD: Using constant & immutable
contract AfterOptimization {
    uint256 public constant MINIMUM_USD = 5e18; // Embedded in bytecode
    address public immutable i_owner;           // Embedded in bytecode
    
    constructor() {
        i_owner = msg.sender;
    }
    // Deployment cost: ~840,000 gas ⬇️ 19,000 saved
}
