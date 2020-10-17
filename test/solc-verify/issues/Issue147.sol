pragma solidity >=0.5.0 <0.6.0;

contract Thing {
    string public id;
}

contract otherThing {
    function f(Thing t) public view returns(string memory)
    {
        string memory s = t.id();
        return s;
    }
}