# IFeeDistributor

## Functions

### baseFee

```solidity
function baseFee(
    address token
) external returns (uint256 baseFee)
```

The base fee of a swap on top of the percentual fee.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address | The token whose base fee is queried. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `baseFee` | uint256 | The amount of the fee in wei. |
### setBaseFee

```solidity
function setBaseFee(
    address token,
    uint256 newFee
) external
```

Sets the base fee for a given token.

Callable only by the owner.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address | The token whose base fee is set. |
| `newFee` | uint256 | The new base fee in wei. |

### setFeeCollector

```solidity
function setFeeCollector(
    address payable newFeeCollector
) external
```

Sets the address that receives the fee from the funds.

Callable only by the owner.

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

Callable only by the owner.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `newShare` | uint96 | The percentual value expressed in basis points. |

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

### BaseFeeChanged

```solidity
event BaseFeeChanged(
    address token,
    uint256 newFee
)
```

Event emitted when a token's base fee is changed.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address | The address of the token whose fee was changed. 0 for ether. |
| `newFee` | uint256 | The new amount of base fee in wei. |
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

