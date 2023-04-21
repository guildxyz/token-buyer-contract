# IZkSyncBridge

## Functions

### requestL2Transaction

```solidity
function requestL2Transaction(
    address _contractL2,
    uint256 _l2Value,
    bytes _calldata,
    uint256 _l2GasLimit,
    uint256 _l2GasPerPubdataByteLimit,
    bytes[] _factoryDeps,
    address _refundRecipient
) external returns (bytes32 canonicalTxHash)
```

Request execution of L2 transaction from L1.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `_contractL2` | address | The L2 receiver address. |
| `_l2Value` | uint256 | `msg.value` of L2 transaction. |
| `_calldata` | bytes | The input of the L2 transaction. |
| `_l2GasLimit` | uint256 | Maximum amount of L2 gas that transaction can consume during execution on L2. |
| `_l2GasPerPubdataByteLimit` | uint256 | The maximum amount L2 gas that the operator may charge the user for single byte of pubdata. |
| `_factoryDeps` | bytes[] | An array of L2 bytecodes that will be marked as known on L2. |
| `_refundRecipient` | address | The address on L2 that will receive the refund for the transaction.
If the transaction fails, it will also be the address to receive `_l2Value`. |

#### Return Values

| Name | Type | Description |
| :--- | :--- | :---------- |
| `canonicalTxHash` | bytes32 | The hash of the requested L2 transaction. This hash can be used to follow the transaction status. |

