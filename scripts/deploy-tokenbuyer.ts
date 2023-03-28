import { ethers } from "hardhat";

// Constructor arguments
const universalRouter = "0x..."; // Uniswap Universal Router's address.
const permit2 = "0x..."; // Permit2's address.
const zkSyncBridge = "0x..."; // ZkSynk's bridge's address.
const feeCollector = "0x..."; // The address that will receive a fee from the funds.
const feePercentBps = 0; // The percentage of the fee expressed in basis points (e.g 500 for a 5% cut).

async function main() {
  const TokenBuyer = await ethers.getContractFactory("TokenBuyer");
  const tokenBuyer = await TokenBuyer.deploy(universalRouter, permit2, zkSyncBridge, feeCollector, feePercentBps);

  console.log(
    `Deploying contract to ${
      ethers.provider.network.name !== "unknown" ? ethers.provider.network.name : ethers.provider.network.chainId
    }...`
  );

  await tokenBuyer.deployed();

  console.log("TokenBuyer deployed to:", tokenBuyer.address);
  console.log("Constructor arguments:", universalRouter, permit2, zkSyncBridge, feeCollector, feePercentBps);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
