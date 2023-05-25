pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { FeeDistributor } from "src/utils/FeeDistributor.sol";
import { IFeeDistributor } from "src/interfaces/IFeeDistributor.sol";

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
	}

	function test_CalculateFee() public {
		// check initial values
		assertEq(feeDistributorHarness.feeCollector(), feeCollector);
		assertEq(feeDistributorHarness.feePercentBps(), feePercentBps);

		// set base fees
		vm.prank(feeCollector);
		feeDistributorHarness.setBaseFee(zeroAddress, zeroBaseFeeEther);
		vm.prank(feeCollector);
		feeDistributorHarness.setBaseFee(oneAddress, oneBaseFeeEther);

		// check fee calculation (values computed using a python script)
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.001 ether), 509803921568628);
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.02 ether), 882352941176471);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.001 ether), 117647058823530);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.02 ether), 490196078431373);

		// change fee base fee bps
		vm.prank(feeCollector);
		feeDistributorHarness.setFeePercentBps(300);
		assertEq(feeDistributorHarness.feePercentBps(), 300);

		// check fee calculation again
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.001 ether), 514563106796117);
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.02 ether), 1067961165048544);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.001 ether), 126213592233010);
		assertEq(feeDistributorHarness.exposed_calculateFee(oneAddress, 0.02 ether), 679611650485437);
	}

	function test_SetFeeCollector() public {
		// check initial value
		assertEq(feeDistributorHarness.feeCollector(), feeCollector);

		// set new fee collector
		address payable newFeeCollector;
		newFeeCollector = payable(vm.addr(0x900D));
		vm.prank(feeCollector);
		feeDistributorHarness.setFeeCollector(newFeeCollector);
		assertEq(feeDistributorHarness.feeCollector(), newFeeCollector);
		
		// set the old fee collector again
		vm.prank(newFeeCollector);
		feeDistributorHarness.setFeeCollector(feeCollector);
		assertEq(feeDistributorHarness.feeCollector(), feeCollector);
	}

	function test_EmitBaseFeeChanged() public {
		// new token
		address twoAddress;
		twoAddress = address(2);
		
		// expecting a specific emit message
		vm.expectEmit(true, true, true, true);
		emit FeeDistributorHarness.BaseFeeChanged(oneAddress, 550);

		// do actually call the contract
		vm.prank(feeCollector);
		feeDistributorHarness.setBaseFee(twoAddress, 550);
	}

	function test_SetBaseFeeOnlyFeeCollector() public {
		vm.expectRevert(abi.encodeWithSelector(
			IFeeDistributor.AccessDenied.selector,
			invalidFeeCollector,
			feeCollector
		));
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setBaseFee(zeroAddress, 10 ether);
	}

	function test_SetFeeCollectorOnlyFeeCollector() public {
		vm.expectRevert(abi.encodeWithSelector(
			IFeeDistributor.AccessDenied.selector,
			invalidFeeCollector,
			feeCollector
		));
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setFeeCollector(payable(invalidFeeCollector));
	}

	function test_SetFeePercentBpsOnlyFeeCollector() public {
		vm.expectRevert(abi.encodeWithSelector(
			IFeeDistributor.AccessDenied.selector,
			invalidFeeCollector,
			feeCollector
		));
		vm.prank(invalidFeeCollector);
		feeDistributorHarness.setFeePercentBps(300);
	}
}
