pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import { TokenBuyer } from "src/TokenBuyer.sol";
import { IFeeDistributor } from "src/interfaces/IFeeDistributor.sol";
import { ITokenBuyer } from "src/interfaces/ITokenBuyer.sol";
import { MockERC20 } from "src/mock/MockERC20.sol";

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

	event TokensSweeped(address token, address recipient, uint256 amount);

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

		vm.prank(feeCollector);
		tokenBuyer.setBaseFee(zeroAddress, baseFeeEther);

		token = new MockERC20();
	}

	function test_ContractInitialization() public {
		// sanity test
		assertEq(tokenBuyer.universalRouter(), universalRouterAddress);
		assertEq(tokenBuyer.permit2(), permit2Address);
		assertEq(tokenBuyer.feeCollector(), feeCollector);
		assertEq(tokenBuyer.feePercentBps(), feePercentBps);
	}

	function test_SweepTransfer() public {
		// recipient address
		uint256 recipientPrivateKey;
		address payable recipient;
		recipientPrivateKey = 0x2EC191E47;
		recipient = payable(vm.addr(recipientPrivateKey));

		// mint tokens to contract
		token.mint(address(tokenBuyer), 10);
		assertEq(token.balanceOf(address(tokenBuyer)), 10);

		// expecting a specific event
		vm.expectEmit(true, true, true, true);
		emit TokensSweeped(address(token), recipient, 1);

		// sweep the contract
		vm.prank(feeCollector);
		tokenBuyer.sweep(address(token), recipient, 1);

		// check balances
		assertEq(token.balanceOf(address(tokenBuyer)), 9);
		assertEq(token.balanceOf(recipient), 1);
	}

	function test_SweepOnlyFeeCollector() public {
		// unauthorized caller
		uint256 invalidFeeCollectorPrivateKey;
		address payable invalidFeeCollector;
		invalidFeeCollectorPrivateKey = 0xBAD;
		invalidFeeCollector = payable(vm.addr(invalidFeeCollectorPrivateKey));

		// expect access denied error
		vm.expectRevert(abi.encodeWithSelector(
			IFeeDistributor.AccessDenied.selector,
			invalidFeeCollector,
			feeCollector
		));
		vm.prank(invalidFeeCollector);
		tokenBuyer.sweep(zeroAddress, invalidFeeCollector, 100);
	}
}
