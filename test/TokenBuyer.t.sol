pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract TokenBuyerTest is Test {
	uint256 testNumber;

	function setUp() public {
		testNumber = 42;
	}

	function test_NumberIs42() public {
		assertEq(testNumber, 42);
	}

	function testFail_Subtract43() public {
		testNumber -= 43;
	}
}
