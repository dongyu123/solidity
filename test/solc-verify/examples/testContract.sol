contract C {
    int x;
    int y;

    function funcA() public {
        x = 1;
    }
}

contract C2 {
    address a;
    function funcB(address a) public {
        C c = C(a);
        c.funcA();
    }

    function funcC() public {
        a.call(abi.encode(bytes4(bytes32(keccak256("funcA")))));
        // a.delegatecall(abi.encode(bytes4(bytes32(keccak256("funcA")))));
    }
}