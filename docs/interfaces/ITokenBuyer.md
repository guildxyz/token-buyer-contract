# ITokenBuyer

A smart contract for buying any kind of tokens and taking a fee.

## Functions

### getAssets

```solidity
function getAssets(
    struct ITokenBuyer.PayToken payToken,
    bytes uniCommands,
    bytes[] uniInputs
) external
```

Executes token swaps and takes a fee.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `payToken` | struct ITokenBuyer.PayToken | The address and the amount of the token that's used for paying. 0 for ether. |
| `uniCommands` | bytes | A set of concatenated commands, each 1 byte in length. |
| `uniInputs` | bytes[] | An array of byte strings containing abi encoded inputs for each command. |

### setFeeCollector

```solidity
function setFeeCollector(
    address payable newFeeCollector
) external
```

Sets the address that receives the fee from the funds.

Callable only by the current fee collector.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `newFeeCollector` | address payable | The new address of feeCollector. |

### setFeePercentBps

```solidity
function setFeePercentBps(
    uint96 newShare
) external
```

Sets the fee's amount from the funds.

Callable only by the fee collector.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `newShare` | uint96 | The percentual value expressed in basis points. |

### universalRouter

```solidity
function universalRouter() external returns (address payable)
```

Returns the address of Uniswap's Universal Router.

### permit2

```solidity
function permit2() external returns (address)
```

Returns the address the Permit2 contract.

### feeCollector

```solidity
function feeCollector() external returns (address payable)
```

Returns the address that receives the fee from the funds.

### feePercentBps

```solidity
function feePercentBps() external returns (uint96)
```

Returns the percentage of the fee expressed in basis points.

## Events

### TokensBought

```solidity
event TokensBought(
)
```

Event emitted when a call to {getAssets} succeeds.

### FeeCollectorChanged

```solidity
event FeeCollectorChanged(
    address newFeeCollector
)
```

Event emitted when the fee collector address is changed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `newFeeCollector` | address | The new address of feeCollector. |
### FeePercentBpsChanged

```solidity
event FeePercentBpsChanged(
    uint96 newShare
)
```

Event emitted when the share of the fee collector changes.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `newShare` | uint96 | The new value of feePercentBps. |

## Custom errors

### AccessDenied

```solidity
error AccessDenied(address sender, address owner)
```

Error thrown when a function is attempted to be called by the wrong address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| sender | address | The address that sent the transaction. |
| owner | address | The address that is allowed to call the function. |

### TransferFailed

```solidity
error TransferFailed(address from, address to)
```

Error thrown when an ERC20 transfer failed.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The sender of the token. |
| to | address | The recipient of the token. |

## Custom types

### PayToken

```solidity
struct PayToken {
  address tokenAddress;
  uint256 amount;
}
```

