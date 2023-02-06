// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Signatures } from "./utils/Signatures.sol";
import { ITokenBuyer } from "./interfaces/ITokenBuyer.sol";
import { IUniversalRouter } from "./interfaces/external/IUniversalRouter.sol";
import { LibAddress } from "./lib/LibAddress.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A smart contract for buying any kind of tokens and taking a fee.
contract TokenBuyer is ITokenBuyer, Signatures {
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
        PayToken calldata payToken,
        bytes calldata uniCommands,
        bytes[] calldata uniInputs
    ) external payable {
        IERC20 token = IERC20(payToken.tokenAddress);

        // Get the tokens from the user and send the fee collector's share
        if (address(token) == address(0)) payable(feeCollector).sendEther(calculateFee(msg.value));
        else {
            if (!token.transferFrom(msg.sender, address(this), payToken.amount))
                revert TransferFailed(msg.sender, address(this));
            if (!token.transferFrom(address(this), feeCollector, calculateFee(payToken.amount)))
                revert TransferFailed(address(this), feeCollector);
            token.approve(permit2, type(uint256).max);
        }

        IUniversalRouter(universalRouter).execute{ value: address(this).balance }(uniCommands, uniInputs);

        // Send out any remaining tokens
        if (address(token) == address(0)) payable(msg.sender).sendEther(address(this).balance);
        else if (!token.transferFrom(address(this), msg.sender, token.balanceOf(address(this))))
            revert TransferFailed(address(this), msg.sender);

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

    function sweep(address token, address payable recipient, uint256 amount) external {
        if (msg.sender != feeCollector) revert AccessDenied(msg.sender, feeCollector);

        if (token == address(0)) recipient.sendEther(amount);
        else if (!IERC20(token).transfer(recipient, amount)) revert TransferFailed(address(this), feeCollector);

        emit TokensSweeped(token, recipient, amount);
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
