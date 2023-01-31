import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, constants, Contract } from "ethers";
import { ethers } from "hardhat";
import { encodePermit2Permit, encodeUnwrapEth, encodeV3SwapExactOut, encodeWrapEth } from "../scripts/callEncoder";

// Test accounts
let wallet0: SignerWithAddress;
let randomWallet: SignerWithAddress;

// Sample collector details
let feeCollector: SignerWithAddress;
const feePercentBps = BigNumber.from(200);

// Contract instances
let token: Contract;
let tokenBuyer: Contract;

// Uniswap Universal Router and Permit2 on Polygon
const universalRouterAddress = "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5";
const permit2Address = "0x000000000022D473030F116dDEE9F6B43aC78BA3";

describe("TokenBuyer", function () {
  this.beforeAll("deploy contracts", async () => {
    [wallet0, feeCollector, randomWallet] = await ethers.getSigners();
  });

  this.beforeEach("deploy new contracts", async () => {
    const TokenBuyer = await ethers.getContractFactory("TokenBuyer");
    tokenBuyer = await TokenBuyer.deploy(universalRouterAddress, permit2Address, feeCollector.address, feePercentBps);

    const ERC20 = await ethers.getContractFactory("MockERC20");
    token = await ERC20.deploy();
  });

  context("creating a contract", async () => {
    it("should initialize addresses", async () => {
      expect(await tokenBuyer.universalRouter()).to.equal(universalRouterAddress);
      expect(await tokenBuyer.permit2()).to.equal(permit2Address);
      expect(await tokenBuyer.feeCollector()).to.equal(feeCollector.address);
      expect(await tokenBuyer.feePercentBps()).to.equal(feePercentBps);
    });
  });

  context("paying fees", async () => {
    beforeEach("approve tokens", async () => {
      await token.approve(feeCollector.address, ethers.constants.MaxUint256);
    });

    it("should swap native token to ERC20 and distribute tokens correctly", async () => {
      const usdc = token.attach("0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174");
      const amountIn = BigNumber.from("1955340553184923583");
      const amountOut = ethers.utils.parseUnits("1.95", 6);

      const amountInWithFee = amountIn.mul(feePercentBps.add(10000)).div(10000);
      const amountInCalculated = amountInWithFee.div(feePercentBps.add(10000)).mul(10000);
      // This won't pass: we lose the last 4 digits because of poor precision
      // expect(amountIn).to.eq(amountInCalculated);

      const eoaERC20Balance0 = await usdc.balanceOf(wallet0.address);
      const eoaBalance0 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance0 = await ethers.provider.getBalance(feeCollector.address);

      await tokenBuyer.getAssets(
        { tokenAddress: constants.AddressZero, amount: 0 },
        "0x0b010c", // WRAP_ETH, V3_SWAP_EXACT_OUT, UNWRAP_ETH
        [
          encodeWrapEth("0x0000000000000000000000000000000000000002", amountIn),
          encodeV3SwapExactOut(
            wallet0.address,
            amountOut,
            amountIn,
            "0x2791bca1f2de4661ed88a30c99a7a9449aa841740001f40d500b1d8e8ef31e21c99d1db9a6444d3adf1270",
            false
          ),
          encodeUnwrapEth(wallet0.address, 0)
        ],
        { value: amountInWithFee }
      );

      const contractERC20Balance = await usdc.balanceOf(tokenBuyer.address);
      const contractBalance = await ethers.provider.getBalance(tokenBuyer.address);
      const eoaERC20Balance1 = await usdc.balanceOf(wallet0.address);
      const eoaBalance1 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance1 = await ethers.provider.getBalance(feeCollector.address);

      expect(contractERC20Balance).to.eq(0);
      expect(contractBalance).to.eq(0);
      expect(eoaERC20Balance1).to.eq(eoaERC20Balance0.add(amountOut));
      expect(eoaBalance1).to.gte(eoaBalance0.sub(amountInWithFee));
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0.add(amountInWithFee.sub(amountInCalculated)));
    });

    it("should swap ERC20 to ERC20 and distribute tokens correctly", async () => {
      const usdc = token.attach("0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174");
      const wmatic = token.attach("0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270");
      const amountIn = BigNumber.from("1955340553184923583");
      const amountOut = ethers.utils.parseUnits("1.95", 6);

      const amountInWithFee = amountIn.mul(feePercentBps.add(10000)).div(10000);
      const amountInCalculated = amountInWithFee.div(feePercentBps.add(10000)).mul(10000);
      // This won't pass: we lose the last 4 digits because of poor precision
      // expect(amountIn).to.eq(amountInCalculated);

      await wallet0.sendTransaction({ to: wmatic.address, value: amountInWithFee });
      await wmatic.approve(tokenBuyer.address, amountInWithFee);

      const eoaTokenOutBalance0 = await usdc.balanceOf(wallet0.address);
      const eoaTokenInBalance0 = await wmatic.balanceOf(wallet0.address);
      const feeCollectorBalance0 = await wmatic.balanceOf(feeCollector.address);

      await tokenBuyer.getAssets(
        { tokenAddress: wmatic.address, amount: amountInWithFee },
        "0x0a01", // PERMIT2_PERMIT, V3_SWAP_EXACT_OUT
        [
          encodePermit2Permit(
            wmatic.address,
            "1461501637330902918203684832716283019655932542975",
            1706751423,
            0,
            "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
            "1704161223",
            // eslint-disable-next-line max-len
            "0x43d422359b743755a8c8de3cd7b54c20c381084ce597d8135a3051382c96a2344d6d236a3f4a685c91bb036780ca7f90d69cbe9df8982ec022b6990f7f9b22751c"
          ),
          encodeV3SwapExactOut(
            wallet0.address,
            amountOut,
            amountIn,
            "0x2791bca1f2de4661ed88a30c99a7a9449aa841740001f40d500b1d8e8ef31e21c99d1db9a6444d3adf1270",
            true
          )
        ]
      );

      const contractTokenOutBalance = await usdc.balanceOf(tokenBuyer.address);
      const contractTokenInBalance = await wmatic.balanceOf(tokenBuyer.address);
      const eoaTokenOutBalance1 = await usdc.balanceOf(wallet0.address);
      const eoaTokenInBalance1 = await wmatic.balanceOf(wallet0.address);
      const feeCollectorBalance1 = await wmatic.balanceOf(feeCollector.address);

      expect(contractTokenOutBalance).to.eq(0);
      expect(contractTokenInBalance).to.eq(0);
      expect(eoaTokenOutBalance1).to.eq(eoaTokenOutBalance0.add(amountOut));
      expect(eoaTokenInBalance1).to.gte(eoaTokenInBalance0.sub(amountInWithFee));
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0.add(amountInWithFee.sub(amountInCalculated)));
    });

    it("should emit a TokensBought event", async () => {
      const amountIn = BigNumber.from("1955340553184923583");
      const amountInWithFee = amountIn.mul(feePercentBps.add(10000)).div(10000);

      const tx = await tokenBuyer.getAssets(
        { tokenAddress: constants.AddressZero, amount: 0 },
        "0x0b", // WRAP_ETH
        [encodeWrapEth(wallet0.address, amountIn)],
        { value: amountInWithFee }
      );

      await expect(tx).to.emit(tokenBuyer, "TokensBought");
    });
  });

  context("the fee collector", async () => {
    it("should revert if it's attempted to be changed by anyone else", async () => {
      await expect(tokenBuyer.setFeeCollector(randomWallet.address))
        .to.be.revertedWithCustomError(tokenBuyer, "AccessDenied")
        .withArgs(wallet0.address, feeCollector.address);
    });

    it("should change the address", async () => {
      await tokenBuyer.connect(feeCollector).setFeeCollector(randomWallet.address);
      const newAddress = await tokenBuyer.feeCollector();
      expect(newAddress).to.eq(randomWallet.address);
    });

    it("should emit a FeeCollectorChanged event", async () => {
      const tx = tokenBuyer.connect(feeCollector).setFeeCollector(randomWallet.address);
      await expect(tx).to.emit(tokenBuyer, "FeeCollectorChanged").withArgs(randomWallet.address);
    });
  });

  context("the fee collector's share", async () => {
    it("should revert if it's attempted to be changed by anyone else", async () => {
      await expect(tokenBuyer.setFeePercentBps("100"))
        .to.be.revertedWithCustomError(tokenBuyer, "AccessDenied")
        .withArgs(wallet0.address, feeCollector.address);
    });

    it("should change the value", async () => {
      await tokenBuyer.connect(feeCollector).setFeePercentBps("100");
      const newValue = await tokenBuyer.feePercentBps();
      expect(newValue).to.eq("100");
    });

    it("should emit a FeePercentBpsChanged event", async () => {
      const tx = tokenBuyer.connect(feeCollector).setFeePercentBps("100");
      await expect(tx).to.emit(tokenBuyer, "FeePercentBpsChanged").withArgs("100");
    });
  });
});
