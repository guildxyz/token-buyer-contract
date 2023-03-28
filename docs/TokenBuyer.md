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

### zkSyncBridge

```solidity
address zkSyncBridge
```

## Functions

### constructor

```solidity
constructor(
    address payable universalRouter_,
    address permit2_,
    address zkSyncBridge_,
    address payable feeCollector_,
    uint96 feePercentBps_
) 
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `universalRouter_` | address payable | The address of Uniswap's Universal router. |
| `permit2_` | address | The address of the Permit2 contract. |
| `zkSyncBridge_` | address | The address of the ZkSync bridge contract. |
| `feeCollector_` | address payable | The address that will receive a fee from the funds. |
| `feePercentBps_` | uint96 | The percentage of the fee expressed in basis points (e.g 500 for a 5% cut). |

### getAssets

```solidity
function getAssets(
    uint256 guildId,
    struct ITokenBuyer.PayToken payToken,
    bytes uniCommands,
    bytes[] uniInputs
) external
```

Executes token swaps and takes a fee.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `guildId` | uint256 | The id of the guild where the payment was made. Used only for analytics. |
| `payToken` | struct ITokenBuyer.PayToken | The address and the amount of the token that's used for paying. 0 for ether. |
| `uniCommands` | bytes | A set of concatenated commands, each 1 byte in length. |
| `uniInputs` | bytes[] | An array of byte strings containing abi encoded inputs for each command. |

### bridgeAssets

```solidity
function bridgeAssets(
    uint256 guildId,
    address contractL2,
    uint256 l2Value,
    bytes forwardedCalldata,
    uint256 l2GasLimit,
    uint256 l2GasPerPubdataByteLimit,
    bytes[] factoryDeps,
    address refundRecipient
) external
```

Bridges tokens to ZkSync and takes a fee.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `guildId` | uint256 | The id of the guild where the payment was made. Used only for analytics. |
| `contractL2` | address | The L2 receiver address. |
| `l2Value` | uint256 | `msg.value` of L2 transaction. |
| `forwardedCalldata` | bytes | The input of the L2 transaction. |
| `l2GasLimit` | uint256 | Maximum amount of L2 gas that transaction can consume during execution on L2. |
| `l2GasPerPubdataByteLimit` | uint256 | The max amount L2 gas that the operator may charge for single byte of pubdata. |
| `factoryDeps` | bytes[] | An array of L2 bytecodes that will be marked as known on L2. |
| `refundRecipient` | address | The address on L2 that will receive the refund for the transaction.
If the transaction fails, it will also be the address to receive `_l2Value`. |

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

