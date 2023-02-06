# FeeDistributor

## Variables

### feeCollector

```solidity
address payable feeCollector
```

Returns the address that receives the fee from the funds.

### feePercentBps

```solidity
uint96 feePercentBps
```

Returns the percentage of the fee expressed in basis points.

### baseFee

```solidity
mapping(address => uint256) baseFee
```

The base fee of a swap on top of the percentual fee.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |

## Functions

### constructor

```solidity
constructor(
    address payable feeCollector_,
    uint96 feePercentBps_
) 
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `feeCollector_` | address payable | The address that will receive a fee from the funds. |
| `feePercentBps_` | uint96 | The percentage of the fee expressed in basis points (e.g 500 for a 5% cut). |

### setBaseFee

```solidity
function setBaseFee(
    address token,
    uint256 newFee
) external
```

Sets the base fee for a given token.

Callable only by the current fee collector.

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

### calculateFee

```solidity
function calculateFee(
    address token,
    uint256 amount
) internal returns (uint256 fee)
```

Calculate the fee from the full amount + fee

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address |  |
| `amount` | uint256 |  |

## Modifiers

### onlyFeeCollector

```solidity
modifier onlyFeeCollector()
```

