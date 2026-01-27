// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 20,000+ gas per avoided slot | Critical optimization

pragma solidity ^0.8.20;

// 📌 Key concept: EVM storage uses 32-byte (256-bit) slots
// Reading slot (SLOAD): 2,100 gas (warm) / 2,100 gas (cold)
// Writing slot (SSTORE): 20,000 gas (new) / 5,000 gas (update)
// Packing saves SSTORE operations = massive gas savings

// ❌ BAD: Wasting storage slots (uses 3 slots)
contract UnpackedStorage {
    uint128 a;    // Slot 0 (wastes 16 bytes)
    uint256 b;    // Slot 1 (needs full slot)
    uint128 c;    // Slot 2 (wastes 16 bytes)
    
    function setAll(uint128 _a, uint256 _b, uint128 _c) external {
        a = _a;   // 20,000 gas
        b = _b;   // 20,000 gas
        c = _c;   // 20,000 gas
        // Total: 60,000 gas
    }
}

// ✅ GOOD: Packed storage (uses 2 slots)
contract PackedStorage {
    uint128 a;    // Slot 0 (first 16 bytes)
    uint128 c;    // Slot 0 (last 16 bytes) - PACKED!
    uint256 b;    // Slot 1
    
    function setAll(uint128 _a, uint256 _b, uint128 _c) external {
        a = _a;   // 20,000 gas
        c = _c;   // Part of same slot (no extra SSTORE)
        b = _b;   // 20,000 gas
        // Total: ~40,000 gas ⚡ 33% cheaper!
    }
}

// 🚀 BEST: Optimal packing with struct
contract OptimalPacking {
    
    // Struct automatically packs
    struct UserData {
        address user;      // 20 bytes
        uint48 timestamp;  // 6 bytes
        uint48 amount;     // 6 bytes
        // Total: 32 bytes = 1 slot! ✅
    }
    
    mapping(uint256 => UserData) public users;
    
    function setUser(uint256 id, address _user, uint48 _time, uint48 _amt) 
        external 
    {
        users[id] = UserData(_user, _time, _amt);
        // Only 1 SSTORE = 20,000 gas
    }
}

// 📊 Storage slot examples
contract SlotExamples {
    
    // Example 1: Perfect packing (1 slot)
    address owner;     // 20 bytes
    uint96 balance;    // 12 bytes
    // Total: 32 bytes = 1 slot ✅
    
    // Example 2: Boolean packing (1 slot)
    bool flag1;        // 1 byte
    bool flag2;        // 1 byte
    bool flag3;        // 1 byte
    address addr;      // 20 bytes
    uint80 data;       // 10 bytes
    // Total: 33 bytes = 2 slots (1 byte wasted)
    
    // Example 3: Array breaks packing
    uint128 x;         // Slot 0
    uint256[] items;   // Slot 1 (length), data elsewhere
    uint128 y;         // Slot 2 (can't pack with x!)
    
    // Example 4: Mapping breaks packing
    uint128 a;              // Slot 0
    mapping(address => uint256) balances;  // Slot 1
    uint128 b;              // Slot 2 (can't pack!)
}

// 💡 Advanced packing patterns
contract AdvancedPacking {
    
    // Pattern 1: Timestamp + flags (1 slot)
    struct Event {
        uint128 timestamp;  // Enough until year 10^29
        uint64 amount;      // Up to 18.4 ETH
        uint32 userId;      // 4 billion users
        uint16 eventType;   // 65k event types
        bool processed;     // 1 byte
        // Total: 32 bytes = 1 slot!
    }
    
    // Pattern 2: Bitpacking for flags (1 slot)
    uint256 public flags;  // 256 boolean flags in 1 slot!
    
    function setFlag(uint8 index) external {
        flags |= (1 << index);  // Set bit
    }
    
    function getFlag(uint8 index) external view returns (bool) {
        return (flags & (1 << index)) != 0;  // Read bit
    }
    
    // Pattern 3: Color packing (RGB in 1 slot)
    struct Color {
        uint8 r;    // Red
        uint8 g;    // Green
        uint8 b;    // Blue
        uint8 a;    // Alpha
        // Only 4 bytes, leaves 28 bytes for other data
    }
    
    // Pattern 4: Price + decimals (packed)
    struct Token {
        address tokenAddress;  // 20 bytes
        uint64 price;          // 8 bytes
        uint32 decimals;       // 4 bytes
        // Total: 32 bytes = 1 slot
    }
}

// 📌 Packing rules
contract PackingRul
