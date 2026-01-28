// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 300-3,000+ gas per function call | Depends on data size

pragma solidity ^0.8.20;

// 📌 Key concepts:
// calldata = read-only, cheapest, for external function params
// memory   = read-write, more expensive, temporary storage
// storage  = read-write, most expensive, permanent storage

// Calldata: 4 gas per zero byte, 16 gas per non-zero byte
// Memory: 3 gas per word (32 bytes) + expansion costs

// ❌ BAD: Using memory for read-only params
contract MemoryWaste {
    function sumArray(uint256[] memory numbers) 
        external 
        pure 
        returns (uint256) 
    {
        uint256 total;
        for (uint256 i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }
    // Gas: ~3,527 for small array
    // Memory allocation + copying = expensive
}

// ✅ GOOD: Using calldata for read-only params
contract CalldataOptimized {
    function sumArray(uint256[] calldata numbers) 
        external 
        pure 
        returns (uint256) 
    {
        uint256 total;
        for (uint256 i = 0; i < numbers.length; i++) {
            total += numbers[i];
        }
        return total;
    }
    // Gas: ~2,905 for small array ⚡ 17% cheaper!
    // No memory allocation needed
}

// 🚀 BEST: Optimized with unchecked
contract FullyOptimized {
    function sumArray(uint256[] calldata numbers) 
        external 
        pure 
        returns (uint256 total) 
    {
        uint256 length = numbers.length;
        for (uint256 i = 0; i < length;) {
            total += numbers[i];
            unchecked { ++i; }
        }
    }
    // Gas: ~2,600 ⚡ Even cheaper!
}

// 📊 When to use each
contract DataLocationGuide {
    
    // ✅ Use CALLDATA when:
    // - External function parameter
    // - Read-only (don't modify)
    // - Arrays, strings, structs
    function processReadOnly(uint256[] calldata data) external pure {
        // Just reading, not modifying
        uint256 first = data[0];
    }
    
    // ✅ Use MEMORY when:
    // - Need to modify the data
    // - Building new array/struct
    // - Passing to internal function
    function processWithModify(uint256[] memory data) public pure {
        data[0] = 100;  // Modifying - needs memory
    }
    
    // ✅ Use STORAGE when:
    // - Reading from state variable
    // - Need to modify state permanently
    mapping(uint256 => uint256[]) public storedArrays;
    
    function modifyStorage(uint256 id) external {
        uint256[] storage arr = storedArrays[id];
        arr.push(42);  // Permanent change
    }
    
    // 📌 Struct example
    struct User {
        string name;
        uint256 balance;
    }
    
    // calldata for read-only
    function getUserInfo(User calldata user) 
        external 
        pure 
        returns (uint256) 
    {
        return user.balance;  // Just reading
    }
    
    // memory when modifying
    function updateUser(User memory user) 
        public 
        pure 
        returns (User memory) 
    {
        user.balance += 100;  // Modifying
        return user;
    }
}

// 💡 Advanced patterns
contract AdvancedPatterns {
    
    // Pattern 1: String parameters
    function hashString(string calldata str) 
        external 
        pure 
        returns (bytes32) 
    {
        return keccak256(bytes(str));
        // calldata ⚡ Much cheaper than memory
    }
    
    // Pattern 2: Multiple arrays
    function processPairs(
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external pure returns (uint256) {
        require(tokens.length == amounts.length, "Length mismatch");
        uint256 total;
        for (uint256 i = 0; i < amounts.length;) {
            total += amounts[i];
            unchecked { ++i; }
        }
        return total;
    }
    
    // Pattern 3: Nested structs
    struct Order {
        address user;
        uint256[] tokenIds;
        uint256[] amounts;
    }
    
    function validateOrder(Order calldata order) 
        external 
        pure 
        returns (bool) 
    {
        return order.tokenIds.length == order.amounts.length;
    }
    
    // Pattern 4: Bytes data
    function decodeData(bytes calldata data) 
        external 
        pure 
        returns (address, uint256) 
    {
        // Calldata is perfect for bytes
        return abi.decode(data, (address, uint256));
    }
}

// ⚠️ Common mistakes
contract CommonMistakes {
    
    // ❌ MISTAKE 1: memory in external pure function
    function bad1(uint256[] memory arr) external pure returns (uint256) {
        return arr.length;  // Should use calldata!
    }
    
    // ✅ CORRECT
    function good1(uint256[] calldata arr) external pure returns (uint256) {
        return arr.length;
    }
    
    // ❌ MISTAKE 2: Copying calldata to memory unnecessarily
    function bad2(string calldata str) external pure returns (uint256) {
        string memory copy = str;  // Unnecessary copy!
        return bytes(copy).length;
    }
    
    // ✅ CORRECT
    function good2(string calldata str) external pure returns (uint256) {
        return bytes(str).length;  // Work with calldata directly
    }
    
    // ❌ MISTAKE 3: Using calldata for public function
    // function bad3(uint256[] calldata arr) public { }  // ❌ Won't compile!
    // Public functions can be called internally, where calldata isn't available
    
    // ✅ CORRECT: Use memory for public, or make it external
    function good3(uint256[] memory arr) public pure returns (uint256) {
        return arr.length;
    }
}

// 📊 Gas comparison examples
contract GasComparison {
    
    // Memory version
    function withMemory(uint256[] memory data) public pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        return sum;
    }
    // Array[10]: ~3,500 gas
    // Array[100]: ~24,000 gas
    
    // Calldata version
    function withCalldata(uint256[] calldata data) external pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        return sum;
    }
    // Array[10]: ~2,900 gas ⚡ 17% cheaper
    // Array[100]: ~20,000 gas ⚡ 16% cheaper
    
    // String comparison
    function stringMemory(string memory str) public pure returns (bytes32) {
        return keccak256(bytes(str));
    }
    // "Hello World": ~1,200 gas
    
    function stringCalldata(string calldata str) external pure returns (bytes32) {
        return keccak256(bytes(str));
    }
    // "Hello World": ~900 gas ⚡ 25% cheaper
}

// 💰 Gas cost breakdown:
// Calldata byte (zero):     4 gas
// Calldata byte (non-zero): 16 gas
// Memory word (32 bytes):   3 gas + expansion
// Memory expansion: (words²) / 512 + 3 * words
//
// For 10 uint256 (320 bytes):
// Calldata: ~320-5,120 gas (depends on zeros)
// Memory: ~3,000+ gas (allocation + expansion)

// 📌 Best practices:
// ✅ Use calldata for external function params (read-only)
// ✅ Use memory when you need to modify data
// ✅ Use calldata for arrays, strings, bytes, structs
// ✅ Avoid copying from calldata to memory
// ✅ Cache calldata array length outside loop
// ✅ Use memory only when necessary
// ✅ Consider calldata even for small data

// 🎯 Decision tree:
// Is it a function parameter?
//   → Is function external?
//     → Do you modify the data?
//       → NO: Use calldata ⚡
//       → YES: Use memory
//   → Is function public/internal?
//     → Use memory (calldata not available)
// Is it a local variable?
//   → Use memory
// Is it a state variable?
//   → Use storage

// 📊 Savings estimate:
// Small array (10 items):    300-600 gas
// Medium array (50 items):   1,000-2,000 gas
// Large array (100 items):   2,000-4,000 gas
// String (100 chars):        500-1,000 gas
// Struct with arrays:        1,000-3,000 gas
