import { ethers } from "hardhat";

// Constructor arguments
const feeCollector = "0x..."; // The address that will receive a fee from the funds.
const feePercentx100 = 0; // The percentage of the fee multiplied by 100 (e.g 500 for a 5% cut).

async function main() {
  const TokenBuyer = await ethers.getContractFactory("TokenBuyer");
  const tokenBuyer = await TokenBuyer.deploy(feeCollector, feePercentx100);

  console.log(
    `Deploying contract to ${
      ethers.provider.network.name !== "unknown" ? ethers.provider.network.name : ethers.provider.network.chainId
    }...`
  );

  await tokenBuyer.deployed();

  console.log("TokenBuyer deployed to:", tokenBuyer.address);
  console.log("Constructor arguments:", feeCollector, feePercentx100);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
