// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Signatures {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    /// @notice Returns whether the signature provided is valid for the provided hash.
    /// @param hash Hash of the data to be signed.
    /// @param signature Signature byte array associated with _hash.
    /// @return magicValue The function selector if the function passes.
    function isValidSignature(bytes32 hash, bytes memory signature) public pure returns (bytes4 magicValue) {
        // TODO: make this actually secure
        hash;
        signature;
        return MAGICVALUE;
    }
}
