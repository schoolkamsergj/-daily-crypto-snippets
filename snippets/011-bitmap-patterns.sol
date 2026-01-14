// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: ~20,000 gas per flag | Store 256 flags in 1 slot!

pragma solidity ^0.8.20;

// ❌ BAD: Separate bool variables (256 storage slots!)
contract SeparateBools {
    mapping(address => bool) public hasRole1;
    mapping(address => bool) public hasRole2;
    mapping(address => bool) public hasRole3;
    // ... 256 mappings = 256 × 20,000 gas = 5,120,000 gas!
    
    function grantRole(address user, uint8 roleId) external {
        if (roleId == 1) hasRole1[user] = true;      // 20,000 gas
        else if (roleId == 2) hasRole2[user] = true; // 20,000 gas
        else if (roleId == 3) hasRole3[user] = true; // 20,000 gas
    }
}

// ✅ GOOD: Bitmap pattern (1 storage slot for 256 flags!)
contract BitmapRoles {
    // One uint256 can store 256 boolean flags
    mapping(address => uint256) public roles;
    
    function grantRole(address user, uint8 roleId) external {
        // Set bit at position roleId to 1
        roles[user] |= (1 << roleId);
    }
    // Gas cost: ~20,000 gas (same as 1 bool, but stores 256!)
    
    function revokeRole(address user, uint8 roleId) external {
        // Set bit at position roleId to 0
        roles[user] &= ~(1 << roleId);
    }
    
    function hasRole(address user, uint8 roleId) external view returns (bool) {
        // Check if bit at position roleId is 1
        return (roles[user] & (1 << roleId)) != 0;
    }
    
    function hasAnyRole(address user, uint256 rolesMask) external view returns (bool) {
        // Check multiple roles at once!
        return (roles[user] & rolesMask) != 0;
    }
}

// 🚀 BEST: Advanced bitmap operations
contract AdvancedBitmap {
    mapping(address => uint256) public permissions;
    
    // Role constants (bit positions)
    uint256 constant ROLE_ADMIN = 1 << 0;      // Bit 0
    uint256 constant ROLE_MINTER = 1 << 1;     // Bit 1
    uint256 constant ROLE_BURNER = 1 << 2;     // Bit 2
    uint256 constant ROLE_PAUSER = 1 << 3;     // Bit 3
    
    function grantMultipleRoles(address user, uint256 rolesMask) external {
        // Set multiple roles at once
        permissions[user] |= rolesMask;
    }
    
    function revokeMultipleRoles(address user, uint256 rolesMask) external {
        // Remove multiple roles at once
        permissions[user] &= ~rolesMask;
    }
    
    function hasAllRoles(address user, uint256 required) external view returns (bool) {
        // Check if user has ALL required roles
        return (permissions[user] & required) == required;
    }
    
    function toggleRole(address user, uint8 roleId) external {
        // Flip bit (0→1 or 1→0)
        permissions[user] ^= (1 << roleId);
    }
    
    function countRoles(address user) external view returns (uint256 count) {
        // Count number of active roles (popcount)
        uint256 bits = permissions[user];
        while (bits != 0) {
            count++;
            bits &= bits - 1;  // Remove rightmost 1
        }
    }
}

// 📌 Bitmap operations:
// |   (OR)  - Set bit to 1 (add flag)
// &   (AND) - Check if bit is 1 (has flag)
// ~   (NOT) - Invert all bits
// ^   (XOR) - Toggle bit (flip 0↔1)
// <<  (Left shift)  - Multiply by 2^n
// >>  (Right shift) - Divide by 2^n

// 💡 Real-world examples:
// ✅ User permissions (admin, minter, burner...)
// ✅ Feature flags (enabled/disabled features)
// ✅ NFT traits (rare, legendary, animated...)
// ✅ Whitelist/blacklist status
// ✅ Quest completion tracking

// ⚠️ Limitations:
// ❌ Max 256 flags per uint256
// ❌ Need to use mapping for more users
// ❌ Slightly harder to read than bool
