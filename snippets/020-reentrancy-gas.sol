// SPDX-License-Identifier: MIT
// Category: Gas Optimization + Security
// Gas Saved: Prevents reentrancy attacks | Efficient state updates

pragma solidity ^0.8.20;

// ❌ BAD: Vulnerable to reentrancy + inefficient
contract VulnerableWithdraw {
    mapping(address => uint256) public balances;
    
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
        // ❌ WRONG ORDER: External call BEFORE state update
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        
        balances[msg.sender] = 0;  // Too late! Attacker can reenter
    }
}

// ✅ GOOD: CEI pattern (Checks-Effects-Interactions)
contract SafeCEI {
    mapping(address => uint256) public balances;
    
    error InsufficientBalance();
    error TransferFailed();
    
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
        // 1. CHECKS
        if (amount == 0) revert InsufficientBalance();
        
        // 2. EFFECTS (update state FIRST)
        balances[msg.sender] = 0;
        
        // 3. INTERACTIONS (external calls LAST)
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    // Gas: ~30,000 | Secure + efficient
}

// 🚀 BEST: CEI + ReentrancyGuard + unchecked
contract OptimalCEI {
    mapping(address => uint256) public balances;
    uint256 private _locked = 1;
    
    error ReentrancyDetected();
    error InsufficientBalance();
    error TransferFailed();
    
    modifier nonReentrant() {
        if (_locked != 1) revert ReentrancyDetected();
        _locked = 2;
        _;
        _locked = 1;
    }
    
    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;  // Safe: can't overflow
        }
    }
    
    function withdraw(uint256 amount) external nonReentrant {
        uint256 balance = balances[msg.sender];
        
        // 1. CHECKS
        if (balance < amount) revert InsufficientBalance();
        
        // 2. EFFECTS (use unchecked - we already checked)
        unchecked {
            balances[msg.sender] = balance - amount;
        }
        
        // 3. INTERACTIONS
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
}

// 📌 CEI Pattern Rules:
// 1. CHECKS   - require/if checks, validations
// 2. EFFECTS  - state variable updates
// 3. INTERACTIONS - external calls, ETH transfers

// 💡 Why CEI saves gas:
// ✅ Prevents reentrancy without mutex in simple cases
// ✅ Clearer code = easier optimization
// ✅ Combined with unchecked = max efficiency
// ✅ One SSTORE instead of multiple

// ⚠️ Common mistakes:
// ❌ External call before state update
// ❌ Multiple state updates after external call
// ❌ Reading old state after external call
// ❌ Not using nonReentrant when needed
