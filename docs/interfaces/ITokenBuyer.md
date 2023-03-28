# ITokenBuyer

A smart contract for buying any kind of tokens and taking a fee.

## Functions

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

## Events

### TokensBridged

```solidity
event TokensBridged(
    uint256 guildId,
    address sender,
    bytes32 canonicalTxHash
)
```

Event emitted when a call to {bridgeAssets} succeeds.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `guildId` | uint256 | The id of the guild where the payment was made. Used only for analytics. |
| `sender` | address | The sender of the transaction. |
| `canonicalTxHash` | bytes32 | The hash of the requested L2 transaction. |
### TokensBought

```solidity
event TokensBought(
    uint256 guildId
)
```

Event emitted when a call to {getAssets} succeeds.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `guildId` | uint256 | The id of the guild where the payment was made. Used only for analytics. |
### TokensSweeped

```solidity
event TokensSweeped(
    address token,
    address payable recipient,
    uint256 amount
)
```

Event emitted when tokens are sweeped from the contract.

Callable only by the current fee collector.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `token` | address | The address of the token sweeped. 0 for ether. |
| `recipient` | address payable | The recipient of the tokens. |
| `amount` | uint256 | The amount of the tokens sweeped. |

## Custom errors

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

