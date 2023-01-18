// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenBuyer {
    // TODO
    /*
    1) get assets from the user: much like in Poap fee collector
    2) swap assets. Possibilities:
        - encode full path off-chain, much like https://github.com/Uniswap/universal-router
    3) store our share
    4) send assets back to the user
    */
    function getAssets() external payable;

    /// @notice Sets the address that receives the fee from the funds.
    /// @dev Callable only by the current fee collector.
    /// @param newFeeCollector The new address of feeCollector.
    function setFeeCollector(address payable newFeeCollector) external;

    /// @notice Sets the fee's amount from the funds.
    /// @dev Callable only by the fee collector.
    /// @param newShare The percentual value multiplied by 100.
    function setFeePercentx100(uint96 newShare) external;

    /// @notice Returns the address that receives the fee from the funds.
    function feeCollector() external view returns (address payable);

    /// @notice Returns the percentage of the fee multiplied by 100.
    function feePercentx100() external view returns (uint96);

    // TODO
    /// @notice Event emitted when a call to {getAssets} succeeds.
    event AssetsTransferred();

    /// @notice Event emitted when the fee collector address is changed.
    /// @param newFeeCollector The new address of feeCollector.
    event FeeCollectorChanged(address newFeeCollector);

    /// @notice Event emitted when the share of the fee collector changes.
    /// @param newShare The new value of feePercentx100.
    event FeePercentx100Changed(uint96 newShare);

    /// @notice Error thrown when a function is attempted to be called by the wrong address.
    /// @param sender The address that sent the transaction.
    /// @param owner The address that is allowed to call the function.
    error AccessDenied(address sender, address owner);

    /// @notice Error thrown when an ERC20 transfer failed.
    /// @param from The sender of the token.
    /// @param to The recipient of the token.
    error TransferFailed(address from, address to);
}
