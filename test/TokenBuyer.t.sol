pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {TokenBuyer} from "src/TokenBuyer.sol";
import {MockERC20} from "src/mock/MockERC20.sol";

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
	MockERC20 internal token;

	address payable universalRouterAddress;
	address permit2Address;
	address payable feeCollector;
	address zeroAddress;

	uint256 feeCollectorPrivateKey; 
	uint256 baseFeeEther;
	uint96 feePercentBps;

	function setUp() public {
		feeCollectorPrivateKey = 0xFEEC011EC402;
		feeCollector = payable(vm.addr(feeCollectorPrivateKey));
		universalRouterAddress = payable(0xEf1c6E67703c7BD7107eed8303Fbe6EC2554BF6B);
		permit2Address = address(0x000000000022D473030F116dDEE9F6B43aC78BA3);
		feePercentBps = 200;
		baseFeeEther = 0.0005 ether;
		zeroAddress = address(0);

		tokenBuyer = new TokenBuyer(
			universalRouterAddress,
			permit2Address,
			feeCollector,
			feePercentBps
		);

		tokenBuyer.setBaseFee(zeroAddress, baseFeeEther);

		token = new MockERC20();
	}

	function test_ContractInitialization() public {
		// sanity test
		assertEq(tokenBuyer.universalRouter(), universalRouterAddress);
		assertEq(tokenBuyer.permit2(), permit2Address);
		assertEq(tokenBuyer.feeCollector(), feeCollector);
		assertEq(tokenBuyer.feePercentBps(), feePercentBps);

		// check baseFee
		assertEq(tokenBuyer.calculateFee(zeroAddress, 0.001 ether), 100);
	}

	//function test_SwapNativeToken() public {
	//}
}
