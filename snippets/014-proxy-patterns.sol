// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Minimal EIP-1967-style proxy (educational)
contract EIP1967MinimalProxy {
    // keccak256("eip1967.proxy.implementation") - 1
    bytes32 private constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    error NotAdmin();
    address public admin;

    constructor(address impl, bytes memory initData) payable {
        admin = msg.sender;
        _setImplementation(impl);
        if (initData.length > 0) {
            (bool ok,) = impl.delegatecall(initData);
            require(ok, "init failed");
        }
    }

    function upgradeTo(address newImpl) external {
        if (msg.sender != admin) revert NotAdmin();
        _setImplementation(newImpl);
    }

    function _implementation() internal view returns (address impl) {
        assembly { impl := sload(IMPLEMENTATION_SLOT) }
    }

    function _setImplementation(address impl) internal {
        assembly { sstore(IMPLEMENTATION_SLOT, impl) }
    }

    fallback() external payable {
        address impl = _implementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let ok := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch ok
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    receive() external payable {}
}
