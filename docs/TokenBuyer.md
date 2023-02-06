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

### sweep

```solidity
function sweep(
    address token,
    address payable recipient,
    uint256 amount
) external
```

Allows the feeCollector to withdraw any tokens stuck in the contract. Used to rescue funds.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address | The address of the token to sweep. 0 for ether. |
| `recipient` | address payable | The recipient of the tokens. |
| `amount` | uint256 | The amount of the tokens to sweep. |

