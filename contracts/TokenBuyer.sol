// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Callbacks } from "./utils/Callbacks.sol";
import { Signatures } from "./utils/Signatures.sol";
import { ITokenBuyer } from "./interfaces/ITokenBuyer.sol";
import { IUniversalRouter } from "./interfaces/external/IUniversalRouter.sol";
import { LibAddress } from "./lib/LibAddress.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A smart contract for buying any kind of tokens and taking a fee.
contract TokenBuyer is ITokenBuyer, Callbacks, Signatures {
    using LibAddress for address payable;

    address payable public immutable universalRouter;
    address public immutable permit2;
    address payable public feeCollector;
    uint96 public feePercentBps;

    /// @param universalRouter_ The address of Uniswap's Universal router.
    /// @param universalRouter_ The address of the Permit2 contract.
    /// @param feeCollector_ The address that will receive a fee from the funds.
    /// @param feePercentBps_ The percentage of the fee expressed in basis points (e.g 500 for a 5% cut).
    constructor(
        address payable universalRouter_,
        address permit2_,
        address payable feeCollector_,
        uint96 feePercentBps_
    ) {
        universalRouter = universalRouter_;
        permit2 = permit2_;
        feeCollector = feeCollector_;
        feePercentBps = feePercentBps_;
    }

    function getAssets(
        bytes[] calldata tokens,
        bytes calldata uniCommands,
        bytes[] calldata uniInputs
    ) external payable {
        // Get the tokens from the user and send the fee collector's share
        payable(feeCollector).sendEther(calculateFee(msg.value));
        for (uint256 i; i < tokens.length; ) {
            (IERC20 token, uint256 amount) = abi.decode(tokens[i], (IERC20, uint256));
            if (!token.transferFrom(msg.sender, address(this), amount))
                revert TransferFailed(msg.sender, address(this));
            if (!token.transferFrom(address(this), feeCollector, calculateFee(amount)))
                revert TransferFailed(address(this), feeCollector);
            token.approve(permit2, type(uint256).max);
            unchecked {
                ++i;
            }
        }

        IUniversalRouter(universalRouter).execute{ value: address(this).balance }(uniCommands, uniInputs);

        // Send out any remaining tokens
        payable(msg.sender).sendEther(address(this).balance);
        for (uint256 i; i < tokens.length; ) {
            (IERC20 token, ) = abi.decode(tokens[i], (IERC20, uint256));
            uint256 contractBalance = token.balanceOf(address(this));
            if (!token.transferFrom(address(this), msg.sender, contractBalance))
                revert TransferFailed(address(this), msg.sender);
            unchecked {
                ++i;
            }
        }

        emit TokensBought();
    }

    function setFeeCollector(address payable newFeeCollector) external {
        if (msg.sender != feeCollector) revert AccessDenied(msg.sender, feeCollector);
        feeCollector = newFeeCollector;
        emit FeeCollectorChanged(newFeeCollector);
    }

    function setFeePercentBps(uint96 newShare) external {
        if (msg.sender != feeCollector) revert AccessDenied(msg.sender, feeCollector);
        feePercentBps = newShare;
        emit FeePercentBpsChanged(newShare);
    }

    /// @notice Calculate the fee from the full amount + fee
    function calculateFee(uint256 amount) internal view returns (uint256 fee) {
        return amount - ((amount / (10000 + feePercentBps)) * 10000);
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
