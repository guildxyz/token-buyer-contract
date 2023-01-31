# TokenBuyer

A smart contract for buying any kind of tokens and taking a fee.

## Variables

### universalRouter

```solidity
address payable universalRouter
```

Returns the address of Uniswap's Universal Router.

### permit2

```solidity
address permit2
```

Returns the address the Permit2 contract.

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

## Functions

### constructor

```solidity
constructor(
    address payable universalRouter_,
    address permit2_,
    address payable feeCollector_,
    uint96 feePercentBps_
) 
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `universalRouter_` | address payable | The address of Uniswap's Universal router. |
| `permit2_` | address |  |
| `feeCollector_` | address payable | The address that will receive a fee from the funds. |
| `feePercentBps_` | uint96 | The percentage of the fee expressed in basis points (e.g 500 for a 5% cut). |

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

### calculateFee

```solidity
function calculateFee(
    uint256 amount
) internal returns (uint256 fee)
```

Calculate the fee from the full amount + fee

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `amount` | uint256 |  |

### receive

```solidity
receive() external
```

