// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title A smart contract for buying any kind of tokens and taking a fee.
interface ITokenBuyer {
    /// @notice A token address-amount pair.
    struct PayToken {
        address tokenAddress;
        uint256 amount;
    }

    /// @notice Executes token swaps and takes a fee.
    /// @param payToken The address and the amount of the token that's used for paying. 0 for ether.
    /// @param uniCommands A set of concatenated commands, each 1 byte in length.
    /// @param uniInputs An array of byte strings containing abi encoded inputs for each command.
    function getAssets(
        PayToken calldata payToken,
        bytes calldata uniCommands,
        bytes[] calldata uniInputs
    ) external payable;

    /// @notice Sets the address that receives the fee from the funds.
    /// @dev Callable only by the current fee collector.
    /// @param newFeeCollector The new address of feeCollector.
    function setFeeCollector(address payable newFeeCollector) external;

    /// @notice Sets the fee's amount from the funds.
    /// @dev Callable only by the fee collector.
    /// @param newShare The percentual value expressed in basis points.
    function setFeePercentBps(uint96 newShare) external;

    /// @notice Returns the address of Uniswap's Universal Router.
    function universalRouter() external view returns (address payable);

    /// @notice Returns the address the Permit2 contract.
    function permit2() external view returns (address);

    /// @notice Returns the address that receives the fee from the funds.
    function feeCollector() external view returns (address payable);

    /// @notice Returns the percentage of the fee expressed in basis points.
    function feePercentBps() external view returns (uint96);

    /// @notice Event emitted when a call to {getAssets} succeeds.
    event TokensBought();

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

    /// @notice Error thrown when an ERC20 transfer failed.
    /// @param from The sender of the token.
    /// @param to The recipient of the token.
    error TransferFailed(address from, address to);
}
