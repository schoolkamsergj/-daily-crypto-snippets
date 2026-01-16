// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Pattern: batch multiple calls in one tx (atomic by default)
contract Multicall {
    error CallFailed(uint256 index);

    struct Call {
        address target;
        uint256 value;
        bytes data;
    }

    function multicall(Call[] calldata calls) external payable returns (bytes[] memory results) {
        results = new bytes[](calls.length);

        for (uint256 i = 0; i < calls.length; ) {
            (bool ok, bytes memory res) = calls[i].target.call{value: calls[i].value}(calls[i].data);
            if (!ok) revert CallFailed(i);
            results[i] = res;
            unchecked { ++i; }
        }
    }
}
