contract C1 {
    int x;

    function funcA(int amount) public {
        x = 1;
    }
}

contract C2 {

    /// @notice postcondition C1.x == amount
    function funcB(address a, int amount) public {
        C1 c = C1(a);
        c.funcA(amount);
    }
}