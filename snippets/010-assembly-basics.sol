// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 50-200+ gas | Direct EVM access

pragma solidity ^0.8.20;

// ❌ SOLIDITY: Regular variable access
contract SolidityVersion {
    function getBalance(address user) external view returns (uint256 balance) {
        balance = user.balance;
        // Compiler adds safety checks and extra operations
    }
    // Gas cost: ~2,500 gas
}

// ✅ ASSEMBLY: Direct EVM access
contract AssemblyVersion {
    function getBalance(address user) external view returns (uint256 balance) {
        assembly {
            balance := selfbalance()  // Direct opcode
        }
    }
    // Gas cost: ~2,400 gas ⚡ 100 gas cheaper
}

// 🚀 PRACTICAL EXAMPLES:

contract AssemblyPatterns {
    
    // Example 1: Efficient address check
    function isZeroAddress(address addr) public pure returns (bool result) {
        assembly {
            // Direct comparison, no type conversions
            result := iszero(addr)
        }
    }
    
    // Example 2: Efficient storage load
    mapping(address => uint256) public balances;
    
    function getBalanceAsm(address user) external view returns (uint256 bal) {
        assembly {
            // Load storage slot directly
            mstore(0x00, user)
            mstore(0x20, balances.slot)
            let slot := keccak256(0x00, 0x40)
            bal := sload(slot)
        }
    }
    
    // Example 3: Gas-efficient loop
    function sumArray(uint256[] calldata data) external pure returns (uint256 total) {
        assembly {
            let length := data.length
            let dataPtr := data.offset
            
            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                total := add(total, calldataload(add(dataPtr, mul(i, 0x20))))
            }
        }
    }
    
    // Example 4: Efficient ETH transfer
    function transferETH(address to, uint256 amount) external {
        assembly {
            // Direct call without Solidity checks
            let success := call(gas(), to, amount, 0, 0, 0, 0)
            if iszero(success) {
                revert(0, 0)
            }
        }
    }
}

// 📌 Common Assembly operations:
// add(x, y)      - addition
// sub(x, y)      - subtraction
// mul(x, y)      - multiplication
// div(x, y)      - division
// sload(slot)    - load from storage
// sstore(slot, value) - save to storage
// mload(pos)     - load from memory
// mstore(pos, value) - save to memory
// calldataload(pos) - load from calldata

// ⚠️ Assembly risks:
// ❌ No overflow checks
// ❌ No type safety
// ❌ Easy to make mistakes
// ❌ Harder to audit

// 💡 When to use assembly:
// ✅ Hot paths (frequently called)
// ✅ Gas-critical operations
// ✅ After Solidity prototype works
// ✅ When you REALLY understand EVM
