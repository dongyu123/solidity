// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

/// @notice invariant funcA ==> funcB
contract C {
    int x;
    int y;

    /// @notice modifies x
    function funcA() public {
        x = 1;
    }

    /// @notice precondition x != 0
    function funcB() public {

    }

    /// @notice modifies x
    function funcC() public {
        funcA();
        funcB();
    }

    /// @notice modifies x
    function funcD() public {
        x = 1;
        funcB();
    }

    /// @notice modifies x
    function funcE() public {
        x = 1;
        funcA();
        funcB();
    }
}

/// @notice invariant funcA ==> funcB
contract C {
    int x;

    /// @notice postcondition x == 1
    function funcA() public {
        x = 1;
    }

    /// @notice precondition x == 1
    function funcB() public {

    }

    function procedure1() public {
        funcA();
        funcB();
    }

    function procedure2() public {
        funcB();
    }
}


