// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

contract Calculator {
    function add(int x, int y) public pure returns (int) {
        return x + y;
    }

    function subtract(int x, int y) public pure returns (int) {
        return x - y;
    }

    function multiply(int x, int y) public pure returns (int) {
        return x * y;
    }

    function divide(int x, int y) public pure returns (int) {
        return x / y;
    }

    function modulo(int x, int y) public pure returns (int) {
        return x % y;
    }

    function power(int base, uint exponent) public pure returns (int) {
        return (
            (base < 0 && exponent % 2 != 0) ? 
            -int(uint(-base) ** exponent) : 
             int(uint((base < 0 ? -base : base)) ** exponent)
        );
    }

    function calculate(int x, int[] calldata y, 
        function(int, int) external pure returns (int)[] calldata op) 
    public pure returns (int z) {
        unchecked {
            require(y.length == op.length, "Arrays not equal");
            z = x;
            for (uint i; i < y.length; ++i) z = op[i](z, y[i]);
        }
    }
}