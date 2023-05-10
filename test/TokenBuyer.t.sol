pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TokenBuyer.sol";

contract DummyTest is Test {
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

contract TokenBuyerTest is Test {
	TokenBuyer tokenBuyer;
	address payable universalRouterAddress;
	address permit2Address;
	address payable feeCollector; 
	uint96 feePercentBps;

	function setUp() public {
		universalRouterAddress = payable(0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B);
		permit2Address = address(0x000000000022D473030F116dDEE9F6B43aC78BA3);
		feeCollector = payable(0x000000000022D473030F116dDEE9F6B43aC78BA3);
		feePercentBps = 200;

		tokenBuyer = new TokenBuyer(
			universalRouterAddress,
			permit2Address,
			feeCollector,
			feePercentBps
		);
	}

	function test_ContractInitialization() public {
		assertEq(tokenBuyer.universalRouter(), universalRouterAddress);
		assertEq(tokenBuyer.permit2(), permit2Address);
		assertEq(tokenBuyer.feeCollector(), feeCollector);
		assertEq(tokenBuyer.feePercentBps(), feePercentBps);
	}
}
