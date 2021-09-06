// Global declarations and definitions
type address_t = int;
var __balance: [address_t]int;
var __block_number: int;
var __block_timestamp: int;
var __alloc_counter: int;
// 
// ------- Source: test/solc-verify/examples/testContract.sol -------
// 
// ------- Contract: C -------
// 
// State variable: x: int256
var {:sourceloc "test/solc-verify/examples/testContract.sol", 2, 5} {:message "x"} x#2: [address_t]int;
// 
// State variable: y: int256
var {:sourceloc "test/solc-verify/examples/testContract.sol", 3, 5} {:message "y"} y#4: [address_t]int;
// 
// Function: funcA : function ()
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 6, 5} {:message "C::funcA"} funcA#13(__this: address_t, __msg_sender: address_t, __msg_value: int)
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 6, 5} {:message "Function might modify balances illegally"} (__balance == old(__balance));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 6, 5} {:message "Function might modify 'x' illegally"} (x#2[__this] == (if true then x#2[__this] else old(x#2[__this])));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 6, 5} {:message "Function might modify 'y' illegally"} (y#4[__this] == old(y#4[__this]));

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
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 1, 1} {:message "C::[implicit_constructor]"} __constructor#14(__this: address_t, __msg_sender: address_t, __msg_value: int)
{
	assume (__balance[__this] >= 0);
	x#2 := x#2[__this := 0];
	y#4 := y#4[__this := 0];
}

// 
// ------- Contract: C2 -------
// 
// State variable: x: int256
var {:sourceloc "test/solc-verify/examples/testContract.sol", 12, 5} {:message "x"} x#16: [address_t]int;
// 
// State variable: y: int256
var {:sourceloc "test/solc-verify/examples/testContract.sol", 13, 5} {:message "y"} y#18: [address_t]int;
// 
// State variable: addr: contract C
var {:sourceloc "test/solc-verify/examples/testContract.sol", 14, 5} {:message "addr"} addr#20: [address_t]address_t;
// 
// Function: funcB : function ()
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 16, 5} {:message "C2::funcB"} funcB#29(__this: address_t, __msg_sender: address_t, __msg_value: int)
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 16, 5} {:message "Function might modify balances illegally"} (__balance == old(__balance));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 16, 5} {:message "Function might modify 'x' illegally"} (x#16[__this] == old(x#16[__this]));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 16, 5} {:message "Function might modify 'y' illegally"} (y#18[__this] == old(y#18[__this]));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 16, 5} {:message "Function might modify 'addr' illegally"} (addr#20[__this] == old(addr#20[__this]));

{
	// TCC assumptions
	assume (__msg_sender != 0);
	// Function body starts here
	assume {:sourceloc "test/solc-verify/examples/testContract.sol", 17, 9} {:message ""} true;
	call funcA#13(addr#20[__this], __this, 0);
	$return1:
	// Function body ends here
}

type int_arr_ptr = int;
type {:datatype} int_arr_type;
function {:constructor} int_arr#constr(arr: [int]int, length: int) returns (int_arr_type);
var mem_arr_int: [int_arr_ptr]int_arr_type;
procedure {:inline 1} {:message "call"} __call(__this: address_t, __msg_sender: address_t, __msg_value: int)
	returns (__result: bool, __calldata: int_arr_ptr)
{
	// TODO: call fallback
	if (*) {
	__balance := __balance[__this := (__balance[__this] + __msg_value)];
	__result := true;
	}
	else {
	__result := false;
	}

}

function {:builtin "((as const (Array Int Int)) 0)"} default_int_int() returns ([int]int);
function keccak256(int_arr_ptr) returns (int);
// 
// Function: funcC : function (address)
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 20, 5} {:message "C2::funcC"} {:skipped} funcC#56(__this: address_t, __msg_sender: address_t, __msg_value: int, a#31: address_t);
	modifies x#16, y#18, addr#20;
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 20, 5} {:message "Function might modify balances illegally"} (__balance == old(__balance));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 20, 5} {:message "Function might modify 'x' illegally"} (x#16[__this] == old(x#16[__this]));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 20, 5} {:message "Function might modify 'y' illegally"} (y#18[__this] == old(y#18[__this]));
	ensures {:sourceloc "test/solc-verify/examples/testContract.sol", 20, 5} {:message "Function might modify 'addr' illegally"} (addr#20[__this] == old(addr#20[__this]));


// 
// Default constructor
procedure {:sourceloc "test/solc-verify/examples/testContract.sol", 11, 1} {:message "C2::[implicit_constructor]"} __constructor#57(__this: address_t, __msg_sender: address_t, __msg_value: int)
{
	assume (__balance[__this] >= 0);
	x#16 := x#16[__this := 0];
	y#18 := y#18[__this := 0];
	addr#20 := addr#20[__this := 0];
}

