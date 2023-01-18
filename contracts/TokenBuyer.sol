// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ITokenBuyer } from "./interfaces/ITokenBuyer.sol";
import { LibAddress } from "./lib/LibAddress.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBuyer is ITokenBuyer {
    using LibAddress for address payable;

    address payable public feeCollector;
    uint96 public feePercentx100;

    /// @param feeCollector_ The address that will receive a fee from the funds.
    /// @param feePercentx100_ The percentage of the fee multiplied by 100 (e.g 500 for a 5% cut).
    constructor(address payable feeCollector_, uint96 feePercentx100_) {
        feeCollector = feeCollector_;
        feePercentx100 = feePercentx100_;
    }

    function getAssets() external payable {
        emit AssetsTransferred();
    }

    function setFeeCollector(address payable newFeeCollector) external {
        if (msg.sender != feeCollector) revert AccessDenied(msg.sender, feeCollector);
        feeCollector = newFeeCollector;
        emit FeeCollectorChanged(newFeeCollector);
    }

    function setFeePercentx100(uint96 newShare) external {
        if (msg.sender != feeCollector) revert AccessDenied(msg.sender, feeCollector);
        feePercentx100 = newShare;
        emit FeePercentx100Changed(newShare);
    }
}
