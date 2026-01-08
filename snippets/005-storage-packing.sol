// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~20,000 gas per slot | Critical for storage-heavy contracts

pragma solidity ^0.8.20;

// ❌ BAD: Poor variable ordering (uses 4 slots)
contract UnpackedStorage {
    uint256 totalSupply;    // Slot 0 (32 bytes)
    address owner;          // Slot 1 (20 bytes) ❌ Wastes 12 bytes
    uint256 maxSupply;      // Slot 2 (32 bytes)
    bool paused;            // Slot 3 (1 byte)  ❌ Wastes 31 bytes
    
    // Total: 4 storage slots = 80,000 gas for initialization
}

// ✅ GOOD: Optimized packing (uses 2 slots)
contract PackedStorage {
    uint256 totalSupply;    // Slot 0 (32 bytes)
    uint256 maxSupply;      // Slot 1 (32 bytes)
    address owner;          // Slot 2 (20 bytes)
    bool paused;            // Slot 2 (1 byte) ✅ Packed together!
    
    // Total: 3 storage slots = 60,000 gas ⚡ 25% cheaper
}

// 🚀 BEST: Maximum packing with smaller types
contract OptimalStorage {
    uint128 totalSupply;    // Slot 0 (16 bytes)
    uint128 maxSupply;      // Slot 0 (16 bytes) ✅ Same slot!
    
    address owner;          // Slot 1 (20 bytes)
    uint32 timestamp;       // Slot 1 (4 bytes)
    uint32 lastUpdate;      // Slot 1 (4 bytes)
    bool paused;            // Slot 1 (1 byte)
    bool initialized;       // Slot 1 (1 byte)
    
    // Total: 2 storage slots = 40,000 gas ⚡ 50% cheaper!
}

// 📌 Storage slot rules:
// 1 slot = 32 bytes
// address = 20 bytes
// uint256 = 32 bytes (full slot)
// uint128 = 16 bytes (fits 2 per slot)
// bool = 1 byte
// Group small types together!
