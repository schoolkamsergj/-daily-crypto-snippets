// SPDX-License-Identifier: MIT
// Category: Gas Optimization
// Gas Saved: 10,000-50,000+ gas on deployment | One-time savings

pragma solidity ^0.8.20;

// ❌ BAD: Expensive constructor
contract ExpensiveConstructor {
    address public owner;
    uint256 public createdAt;
    string public name;
    uint256[] public initialData;
    
    constructor(string memory _name, uint256[] memory data) {
        owner = msg.sender;           // 20,000 gas
        createdAt = block.timestamp;  // 20,000 gas
        name = _name;                 // 40,000+ gas (string storage!)
        
        for (uint256 i = 0; i < data.length; i++) {
            initialData.push(data[i]); // 20,000+ per item
        }
    }
    // Deployment: 150,000+ gas
}

// ✅ GOOD: Optimized constructor
contract OptimizedConstructor {
    address public immutable owner;      // Immutable = cheaper
    uint256 public immutable createdAt;
    bytes32 public nameHash;             // Hash instead of string
    
    constructor(string memory _name) {
        owner = msg.sender;              // Stored in bytecode
        createdAt = block.timestamp;     // Stored in bytecode
        nameHash = keccak256(bytes(_name)); // 20,000 vs 40,000+
        
        // Don't initialize arrays in constructor if possible
    }
    // Deployment: ~60,000 gas ⚡ 60% cheaper
}

// 🚀 BEST: Maximum optimization
contract MaxOptimizedConstructor {
    address public immutable OWNER;
    uint256 public immutable CREATED_AT;
    
    // Use constants when possible (baked into bytecode)
    uint256 public constant MAX_SUPPLY = 1_000_000;
    uint256 public constant FEE_BPS = 100;
    
    constructor() payable {
        OWNER = msg.sender;
        CREATED_AT = block.timestamp;
    }
    // Deployment: ~45,000 gas ⚡ Ultra-minimal
}

// 📊 Constructor patterns
contract ConstructorPatterns {
    
    // Pattern 1: Immutable for one-time set values
    address public immutable token;
    address public immutable factory;
    
    constructor(address _token, address _factory) {
        token = _token;      // Stored in code, not storage
        factory = _factory;  // Cheaper to read later
    }
    
    // Pattern 2: Constants for fixed values
    uint256 public constant DECIMALS = 18;
    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH = 
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    
    // Pattern 3: Lazy initialization
    mapping(address => uint256) public balances;
    bool private initialized;
    
    constructor() {
        // Minimal constructor
    }
    
    function initialize(address[] calldata users, uint256[] calldata amounts) 
        external 
    {
        require(!initialized, "Already initialized");
        initialized = true;
        
        for (uint256 i = 0; i < users.length;) {
            balances[users[i]] = amounts[i];
            unchecked { ++i; }
        }
    }
}

// 💡 Advanced optimization
contract AdvancedConstructor {
    
    // Pack multiple values in constructor
    address public immutable owner;
    uint96 public immutable createdAtPacked;  // Fits timestamp
    
    constructor() {
        owner = msg.sender;
        createdAtPacked = uint96(block.timestamp);
        // Both fit in same storage access pattern
    }
    
    // Use error instead of require in constructor
    error InvalidParameter();
    
    constructor(address addr) {
        if (addr == address(0)) revert InvalidParameter();
        owner = addr;
    }
}

// 📌 Optimization checklist:
// ✅ Use immutable instead of storage variables
// ✅ Use constant for fixed values
// ✅ Store hash instead of string
// ✅ Avoid loops in constructor
// ✅ Use custom errors instead of require
// ✅ Pack values when possible
// ✅ Consider lazy initialization
// ✅ Mark constructor payable if it can receive ETH

// 💰 Gas comparison:
// Storage variable:    20,000 gas (write) + 2,100 (read)
// Immutable variable:  3,000 gas (deploy) + 3 gas (read)
// Constant:            0 gas (deploy) + 3 gas (read)
// String storage:      40,000+ gas
// bytes32 hash:        20,000 gas

// ⚠️ Trade-offs:
// Immutable = can't change after deploy
// Constant = must be known at compile time
// Lazy init = need extra function call
// Hash = need to verify off-chain
