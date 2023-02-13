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

