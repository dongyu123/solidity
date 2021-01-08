// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract FixedBytes {
    bytes32 arr;

    // Safe, we check that index is in bounds
    function getValueSafe(uint i) public view returns (bytes1) {
        if (i < arr.length) return arr[i];
        return 0;
    }

    // Safe, we check that index is in bounds
    function getValueUnsafe(uint i) public view returns (bytes1) {
        return arr[i];
    }

    // Unsafe we don't know i
    function singleByte(bytes1 param, uint i) public pure returns (bytes1) {
        assert(param.length == 1);
        return param[i];
    }

}
