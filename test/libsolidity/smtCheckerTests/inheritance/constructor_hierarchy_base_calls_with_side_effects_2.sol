pragma experimental SMTChecker;

contract A {
	uint public x;
	constructor(uint a) { x = a; }
}

contract B is A {
	constructor(uint b) A(b) {
	}

	function f() internal returns (uint) {
		x = x + 1;
		return x;
	}
}

abstract contract Z is A {
	uint k;
	constructor(uint z) {
		k = z;
	}
}

contract C is Z, B {
	constructor() B(f()) Z(f()) {
		assert(x == 1);
		assert(k == 2);
		assert(x == k); // should fail
	}
}
// ----
// Warning 6328: (382-396): CHC: Assertion violation happens here.\nCounterexample:\nk = 2, x = 1\n\n\n\nTransaction trace:\nC.constructor()
