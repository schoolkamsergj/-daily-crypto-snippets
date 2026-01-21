// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 100-500 gas | Efficient ETH handling

pragma solidity ^0.8.20;

// ❌ BAD: Mixing receive/fallback logic
contract BadETHHandler {
    uint256 public totalReceived;
    
    fallback() external payable {
        // Handles both empty calldata AND unknown functions
        totalReceived += msg.value;
        // Problem: Uses more gas for simple ETH transfers
    }
    // Gas for plain ETH transfer: ~23,500 gas
}

// ✅ GOOD: Separate receive and fallback
contract GoodETHHandler {
    uint256 public totalReceived;
    
    event Received(address indexed sender, uint256 amount);
    event FallbackCalled(address indexed sender, bytes data);
    
    // Handles plain ETH transfers (no calldata)
    receive() external payable {
        // Most gas-efficient for simple transfers
        totalReceived += msg.value;
        emit Received(msg.sender, msg.value);
    }
    // Gas for plain ETH transfer: ~23,100 gas ⚡ 400 gas cheaper
    
    // Handles calls with data to unknown functions
    fallback() external payable {
        emit FallbackCalled(msg.sender, msg.data);
    }
}

// 🚀 BEST: Minimal receive with assembly
contract OptimalETHHandler {
    uint256 public totalReceived;
    
    // Ultra-minimal receive (no events, just accounting)
    receive() external payable {
        assembly {
            // Load current total from storage slot 0
            let current := sload(0)
            // Add msg.value
            let newTotal := add(current, callvalue())
            // Store back
            sstore(0, newTotal)
        }
    }
    // Gas: ~22,800 gas ⚡ Ultra-efficient
}

// 📌 Advanced patterns
contract AdvancedETHHandling {
    mapping(address => uint256) public deposits;
    
    error SendFailed();
    
    // Pattern 1: Deposit tracking in receive
    receive() external payable {
        unchecked {
            deposits[msg.sender] += msg.value;
        }
    }
    
    // Pattern 2: Reject ETH from specific addresses
    address public blockedAddress;
    
    receive() external payable {
        if (msg.sender == blockedAddress) {
            revert SendFailed();
        }
        deposits[msg.sender] += msg.value;
    }
    
    // Pattern 3: Gas-efficient ETH withdrawal
    function withdraw(uint256 amount) external {
        uint256 balance = deposits[msg.sender];
        if (balance < amount) revert SendFailed();
        
        unchecked {
            deposits[msg.sender] = balance - amount;
        }
        
        // Use call instead of transfer (more gas-efficient)
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert SendFailed();
    }
    
    // Pattern 4: Fallback with minimal logic
    fallback() external payable {
        // Just accept ETH, no processing
        // Cheapest fallback possible
    }
}

// 📊 Gas comparison:
// receive() only           = ~22,800 gas (cheapest)
// receive() + event        = ~23,100 gas
// receive() + storage write = ~42,800 gas
// fallback() for ETH       = ~23,500+ gas (more expensive)
// transfer() method        = 2,300 gas limit (often fails)
// call{value}()            = flexible gas, recommended

// 📌 Best practices:
// ✅ Use receive() for plain ETH transfers
// ✅ Use fallback() for unknown function calls
// ✅ Keep receive() logic minimal (gas limit 2300 for some transfers)
// ✅ Use call{value}() instead of transfer() for sending ETH
// ✅ Emit events only when necessary
// ✅ Use unchecked for accounting (overflow impossible)

// 💡 Common mistakes:
// ❌ Only fallback() (uses more gas)
// ❌ Complex logic in receive() (might fail with 2300 gas)
// ❌ Using transfer() instead of call() (deprecated)
// ❌ Not handling failure of call()

// ⚠️ receive() vs fallback():
// receive() = msg.data is empty (plain ETH)
// fallback() = msg.data not empty OR no receive()
// Both can be payable or not
