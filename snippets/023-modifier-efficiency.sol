// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 200-500 gas per call | Reduces contract size

pragma solidity ^0.8.20;

// ❌ BAD: Heavy modifier (code copied to each function)
contract HeavyModifier {
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        require(owner != address(0), "Owner not set");
        require(tx.origin == msg.sender, "No contracts");
        _;
    }
    
    function action1() external onlyOwner { }
    function action2() external onlyOwner { }
    function action3() external onlyOwner { }
    // Each function gets ALL modifier code = contract bloat
}

// ✅ GOOD: Lightweight modifier
contract LightweightModifier {
    address public owner;
    
    error Unauthorized();
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    function action1() external onlyOwner { }
    function action2() external onlyOwner { }
    // Minimal modifier = smaller bytecode
}

// 🚀 BEST: Internal function instead of modifier
contract InternalFunction {
    address public owner;
    
    error Unauthorized();
    
    function _checkOwner() private view {
        if (msg.sender != owner) revert Unauthorized();
    }
    
    function action1() external {
        _checkOwner();
        // function logic
    }
    
    function action2() external {
        _checkOwner();
        // function logic
    }
    // Code reuse = smaller contract size ⚡
}

// 📊 Modifier patterns comparison
contract ModifierPatterns {
    address public owner;
    mapping(address => bool) public admins;
    
    error Unauthorized();
    error Paused();
    
    bool public paused;
    
    // Pattern 1: Simple check modifier (OK)
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    // Pattern 2: Multiple conditions (use internal instead)
    function _checkAdmin() private view {
        if (!admins[msg.sender] && msg.sender != owner) {
            revert Unauthorized();
        }
    }
    
    // Pattern 3: State-changing modifier (AVOID)
    // ❌ BAD
    modifier trackCalls() {
        callCount++;  // State change in modifier = confusing
        _;
    }
    uint256 public callCount;
    
    // ✅ GOOD - explicit in function
    function betterApproach() external {
        unchecked { callCount++; }
        // logic here
    }
    
    // Pattern 4: whenNotPaused (lightweight OK)
    modifier whenNotPaused() {
        if (paused) revert Paused();
        _;
    }
    
    // Pattern 5: Reentrancy guard (worth the gas)
    uint256 private _locked = 1;
    
    modifier nonReentrant() {
        require(_locked == 1, "Reentrant");
        _locked = 2;
        _;
        _locked = 1;
    }
}

// 💡 Advanced: Modifier with parameters
contract ParameterizedModifier {
    mapping(address => mapping(bytes32 => bool)) public permissions;
    
    error MissingPermission(bytes32 role);
    
    // ❌ Modifier with parameters = more bytecode
    modifier hasRole(bytes32 role) {
        if (!permissions[msg.sender][role]) {
            revert MissingPermission(role);
        }
        _;
    }
    
    // ✅ Internal function is better
    function _checkRole(bytes32 role) private view {
        if (!permissions[msg.sender][role]) {
            revert MissingPermission(role);
        }
    }
    
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant MINTER = keccak256("MINTER");
    
    function mint() external {
        _checkRole(MINTER);
        // mint logic
    }
}

// 📌 Best practices:
// ✅ Keep modifiers simple (1-2 checks max)
// ✅ Use custom errors in modifiers
// ✅ Use internal functions for complex checks
// ✅ Use private view functions for reusable checks
// ✅ Avoid state changes in modifiers
// ✅ Avoid modifiers with parameters

// 💰 Gas impact:
// Simple modifier:     +50-100 gas per function
// Complex modifier:    +200-500 gas per function  
// Internal function:   +24 gas (JUMP opcode)
// Code size:           Modifier = N × size, Function = 1 × size

// ⚠️ When modifiers are OK:
// ✅ Simple auth check (onlyOwner)
// ✅ Pause mechanism (whenNotPaused)
// ✅ Reentrancy guard (critical)
// ✅ Used only 1-2 times

// ⚠️ Use internal functions when:
// ✅ Complex logic (3+ checks)
// ✅ Used many times (5+ functions)
// ✅ Has parameters
// ✅ State modifications
