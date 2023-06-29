// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IFeeDistributor } from "../interfaces/IFeeDistributor.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract FeeDistributor is IFeeDistributor, Ownable {
    address payable public feeCollector;
    uint96 public feePercentBps;

    mapping(address => uint256) public baseFee;

    /// @param feeCollector_ The address that will receive a fee from the funds.
    /// @param feePercentBps_ The percentage of the fee expressed in basis points (e.g 500 for a 5% cut).
    constructor(address payable feeCollector_, uint96 feePercentBps_) {
        feeCollector = feeCollector_;
        feePercentBps = feePercentBps_;
    }

    function setBaseFee(address token, uint256 newFee) external onlyOwner {
        baseFee[token] = newFee;
        emit BaseFeeChanged(token, newFee);
    }

    function setFeeCollector(address payable newFeeCollector) external onlyOwner {
        feeCollector = newFeeCollector;
        emit FeeCollectorChanged(newFeeCollector);
    }

    function setFeePercentBps(uint96 newShare) external onlyOwner {
        feePercentBps = newShare;
        emit FeePercentBpsChanged(newShare);
    }

    /// @notice Calculate the fee from the full amount + fee
    function calculateFee(address token, uint256 amount) internal view returns (uint256 fee) {
        uint256 baseFeeAmount = baseFee[token];
        uint256 withoutBaseFee = (amount - baseFeeAmount) * 10000;
        return amount - (withoutBaseFee / (10000 + feePercentBps));
    }
}
