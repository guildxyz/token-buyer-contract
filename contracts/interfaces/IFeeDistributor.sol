// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFeeDistributor {
    /// @notice Sets the address that receives the fee from the funds.
    /// @dev Callable only by the current fee collector.
    /// @param newFeeCollector The new address of feeCollector.
    function setFeeCollector(address payable newFeeCollector) external;

    /// @notice Sets the fee's amount from the funds.
    /// @dev Callable only by the fee collector.
    /// @param newShare The percentual value expressed in basis points.
    function setFeePercentBps(uint96 newShare) external;

    /// @notice Returns the address that receives the fee from the funds.
    function feeCollector() external view returns (address payable);

    /// @notice Returns the percentage of the fee expressed in basis points.
    function feePercentBps() external view returns (uint96);

    /// @notice Event emitted when the fee collector address is changed.
    /// @param newFeeCollector The new address of feeCollector.
    event FeeCollectorChanged(address newFeeCollector);

    /// @notice Event emitted when the share of the fee collector changes.
    /// @param newShare The new value of feePercentBps.
    event FeePercentBpsChanged(uint96 newShare);

    /// @notice Error thrown when a function is attempted to be called by the wrong address.
    /// @param sender The address that sent the transaction.
    /// @param owner The address that is allowed to call the function.
    error AccessDenied(address sender, address owner);
}
