pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { FeeDistributor } from "src/utils/FeeDistributor.sol";

contract FeeDistributorHarness is FeeDistributor {
	constructor(
		address payable feeCollector_,
		uint96 feePercentBps_
	) FeeDistributor(feeCollector_, feePercentBps_) {}

	function exposed_calculateFee(address token, uint256 amount) external view returns (uint256 fee) {
		return calculateFee(token, amount);
	}
}

contract FeeDistributorTest is Test {
	FeeDistributorHarness feeDistributorHarness;
	address zeroAddress;
	address oneAddress;
	address payable feeCollector;
	address payable invalidFeeCollector;
	uint256 feeCollectorPrivateKey; 
	uint256 invalidFeeCollectorPrivateKey; 
	uint256 zeroBaseFeeEther;
	uint256 oneBaseFeeEther;
	uint96 feePercentBps;

	function setUp() public {
		feeCollectorPrivateKey = 0xFEEC011EC402;
		feeCollector = payable(vm.addr(feeCollectorPrivateKey));
		invalidFeeCollectorPrivateKey = 0xBAD;
		invalidFeeCollector = payable(vm.addr(invalidFeeCollectorPrivateKey));

		feePercentBps = 200;
		zeroBaseFeeEther = 0.0005 ether;
		oneBaseFeeEther = 0.0001 ether;
		zeroAddress = address(0);
		oneAddress = address(1);

		feeDistributorHarness = new FeeDistributorHarness(feeCollector, feePercentBps);

		vm.prank(feeCollector);
		feeDistributorHarness.setBaseFee(zeroAddress, zeroBaseFeeEther);
		vm.prank(feeCollector);
		feeDistributorHarness.setBaseFee(oneAddress, oneBaseFeeEther);
	}

	function test_CalculateFee() public {
		// check initial values
		assertEq(feeDistributorHarness.feeCollector(), feeCollector);
		assertEq(feeDistributorHarness.feePercentBps(), feePercentBps);

		// check fee calculation (values computed using a python script)
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.001 ether), 509803921570000);
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.02 ether), 882352941180000);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.001 ether), 117647058830000);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.02 ether), 490196078440000);

		// change fee base fee bps
		vm.prank(feeCollector);
		feeDistributorHarness.setFeePercentBps(300);
		assertEq(feeDistributorHarness.feePercentBps(), 300);

		// check fee calculation again
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.001 ether), 514563106800000);
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.02 ether), 1067961165050000);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.001 ether), 126213592240000);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.02 ether), 679611650490000);
	}

	function testFail_SetBaseFeeOnlyFeeCollector() public {
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setBaseFee(zeroAddress, 10 ether);
	}

	function testFail_SetFeeCollectorOnlyFeeCollector() public {
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setFeeCollector(payable(invalidFeeCollector));
	}

	function testFail_SetFeePercentBpsOnlyFeeCollector() public {
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setFeePercentBps(300);
	}
}
