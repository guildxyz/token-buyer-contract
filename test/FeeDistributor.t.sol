pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { FeeDistributor } from "src/utils/FeeDistributor.sol";

// TODO abstract ?
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
	FeeDistributor feeDistributor;
	FeeDistributorHarness feeDistributorHarness;
	address zeroAddress;
	address oneAddress;
	address payable feeCollector;
	uint256 feeCollectorPrivateKey; 
	uint256 zeroBaseFeeEther;
	uint256 oneBaseFeeEther;
	uint96 feePercentBps;

	function setUp() public {
		feeCollectorPrivateKey = 0xFEEC011EC402;
		feeCollector = payable(vm.addr(feeCollectorPrivateKey));
		feePercentBps = 200;
		zeroBaseFeeEther = 0.0005 ether;
		oneBaseFeeEther = 0.0001 ether;
		zeroAddress = address(0);
		oneAddress = address(1);

		feeDistributor = new FeeDistributor(feeCollector, feePercentBps);
		feeDistributorHarness = new FeeDistributorHarness(feeCollector, feePercentBps);

		vm.prank(feeCollector);
		feeDistributor.setBaseFee(zeroAddress, zeroBaseFeeEther);
		vm.prank(feeCollector);
		feeDistributor.setBaseFee(oneAddress, oneBaseFeeEther);
	}

	function test_CalculateFee() public {
		assertEq(feeDistributor.feeCollector(), feeCollector);
		assertEq(feeDistributor.feePercentBps(), feePercentBps);

		// check baseFee
		assertEq(feeDistributorHarness.exposed_calculateFee(zeroAddress, 0.001 ether), 19607843140000);
	}
}
