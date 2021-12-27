contract C1 {
    mapping (address => int) balances;
    int totalSupply;

    /// @notice modifies balances[msg.sender]
    /// @notice modifies balances[receiver]
    function funcA(address receiver, int amount) public {
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
    }

    constructor() {
        totalSupply = 7000000000 * (10**18);
        balances[msg.sender] = totalSupply; // Give the creator all initial tokens
    }
}

/// @notice invariant __verifier_sum_int(C1.balances) == C1.totalSupply
contract C2 {
    function funcB(address a, address receiver, int amount) public {
        C1 c = new C1();
        c.funcA(receiver, amount);
    }
}