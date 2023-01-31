import { BigNumberish, BytesLike } from "ethers";
import { ethers } from "hardhat";

// Abi encode parameters for contract calls
const encodeParameters = (types: readonly string[], values: readonly any[]) =>
  ethers.utils.defaultAbiCoder.encode(types, values);

const encodeWrapEth = (recipient: string, amountMin: BigNumberish) =>
  encodeParameters(["address", "uint256"], [recipient, amountMin]);

const encodeUnwrapEth = (recipient: string, amountMin: BigNumberish) => encodeWrapEth(recipient, amountMin);

const encodeV3SwapExactOut = (
  recipient: string,
  amountOut: BigNumberish,
  amountInMax: BigNumberish,
  path: BytesLike,
  payerIsUser: boolean
) =>
  encodeParameters(
    ["address", "uint256", "uint256", "bytes", "bool"],
    [recipient, amountOut, amountInMax, path, payerIsUser]
  );

const encodePermit2Permit = (
  tokenAddress: string,
  amount: BigNumberish,
  expiration: BigNumberish,
  nonce: BigNumberish,
  spender: string,
  sigDeadline: BigNumberish,
  data: BytesLike
) =>
  encodeParameters(
    ["address", "uint160", "uint48", "uint48", "address", "uint256", "bytes"],
    [tokenAddress, amount, expiration, nonce, spender, sigDeadline, data]
  );

export { encodeWrapEth, encodeUnwrapEth, encodeV3SwapExactOut, encodePermit2Permit };
