// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

contract C {

    function super() pure public{

    }

    function g() pure public {
        super();
    }
}
