pragma solidity >=0.5.0;

contract Issue66 {
	string a;
	string b;

  function f() public view {
		string storage c = a;
		string memory d = b;
		d = string(c);
	}
}