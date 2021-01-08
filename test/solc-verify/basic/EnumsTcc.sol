// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract Enums {
    enum Dir { Up, Down, Left, Right }

    function f(Dir d) public pure {
        uint x = uint(d);
        assert(0 <= x && x < 4);
    }
}
