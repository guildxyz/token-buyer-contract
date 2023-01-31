# Callbacks

ERC Callback Support

Implements various functions introduced by a variety of ERCs for security reasons.
All are called by external contracts to ensure that this contract safely supports the ERC in question.

## Functions

### onERC721Received

```solidity
function onERC721Received(
    address ,
    address ,
    uint256 ,
    bytes 
) external returns (bytes4)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256 |  |
| `` | bytes |  |

### onERC1155Received

```solidity
function onERC1155Received(
    address ,
    address ,
    uint256 ,
    uint256 ,
    bytes 
) external returns (bytes4)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256 |  |
| `` | uint256 |  |
| `` | bytes |  |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(
    address ,
    address ,
    uint256[] ,
    uint256[] ,
    bytes 
) external returns (bytes4)
```

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `` | address |  |
| `` | address |  |
| `` | uint256[] |  |
| `` | uint256[] |  |
| `` | bytes |  |

### supportsInterface

```solidity
function supportsInterface(
    bytes4 interfaceId
) external returns (bool)
```

Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.

This function call must use less than 30 000 gas.

#### Parameters

| Name | Type | Description |
| :--- | :--- | :---------- |
| `interfaceId` | bytes4 |  |

