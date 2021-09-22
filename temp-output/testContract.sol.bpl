// Global declarations and definitions
type address_t = int;
var __balance: [address_t]int;
var __block_number: int;
var __block_timestamp: int;
var __alloc_counter: int;
// 
// ------- Source: test/solc-verify/examples/testContract.sol -------
// 
// ------- Contract: C1 -------
// 
// State variable: x: int256
var {:sourceloc "test/solc-verify/examples/testContract.sol", 2, 5} {:message "x"} x#2: [address_t]int;
// 
// Function: funcA : function (int256)
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 4, 5} {:message "C1::funcA"} funcA#12(__this: address_t, __msg_sender: address_t, __msg_value: int, amount#4: int)
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 14, 9} {:message "Postcondition 'C1.x == amount' might not hold at end of function."} (x#2[__this] == amount#18);

{
	// TCC assumptions
	assume (__msg_sender != 0);
	// Function body starts here
	x#2 := x#2[__this := 1];
	$return0:
	// Function body ends here
}

// 
// Default constructor
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 1, 1} {:message "C1::[implicit_constructor]"} __constructor#13(__this: address_t, __msg_sender: address_t, __msg_value: int)
{
	assume (__balance[__this] >= 0);
	x#2 := x#2[__this := 0];
}

// 
// ------- Contract: C2 -------
// 
// Function: funcB : function (address,int256)
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 12, 5} {:message "C2::funcB"} funcB#34(__this: address_t, __msg_sender: address_t, __msg_value: int, a#16: address_t, amount#18: int)
{
	var {:sourceloc "test/solc-verify/examples/testContract.sol", 13, 9} {:message "c"} c#22: address_t;
	// TCC assumptions
	assume (__msg_sender != 0);
	// Function body starts here
	c#22 := a#16;
	assume {:sourceloc "test/solc-verify/examples/testContract.sol", 14, 9} {:message ""} true;
	call funcA#12(c#22, __this, 0, amount#18);
	$return1:
	// Function body ends here
}

// 
// Default constructor
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 9, 1} {:message "C2::[implicit_constructor]"} __constructor#35(__this: address_t, __msg_sender: address_t, __msg_value: int)
{
	assume (__balance[__this] >= 0);
}

