// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IFeeDistributor } from "../interfaces/IFeeDistributor.sol";

contract FeeDistributor is IFeeDistributor {
    address payable public feeCollector;
    uint96 public feePercentBps;

    /// @param feeCollector_ The address that will receive a fee from the funds.
    /// @param feePercentBps_ The percentage of the fee expressed in basis points (e.g 500 for a 5% cut).
    constructor(address payable feeCollector_, uint96 feePercentBps_) {
        feeCollector = feeCollector_;
        feePercentBps = feePercentBps_;
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
}
