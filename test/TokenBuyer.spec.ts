import type { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { setCode } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { Contract } from "ethers";
import { readFileSync } from "fs";
import { ethers } from "hardhat";
import {
  encodeCryptoPunks,
  encodePermit2Permit,
  encodeSeaport,
  encodeSweep,
  encodeUnwrapEth,
  encodeV3SwapExactOut,
  encodeWrapEth
} from "../scripts/callEncoder";
import seaportAbi from "./static/fulfillAdvancedOrderAbi.json";
import seaportOrder from "./static/seaportOrder.json";

// Test accounts
let wallet0: SignerWithAddress;
let randomWallet: SignerWithAddress;

// Sample collector details
let feeCollector: SignerWithAddress;
const feePercentBps = 200n;
const baseFeeEther = ethers.parseEther("0.0005");
const guildId = 1;

// Contracts
let token: Contract;
let tokenBuyer: Contract;
const badTokenBytecode = JSON.parse(
  readFileSync("artifacts/contracts/mock/MockBadERC20.sol/MockBadERC20.json", "utf-8")
).deployedBytecode;

// Uniswap Universal Router and Permit2 on Ethereum
const universalRouterAddress = "0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD";
const permit2Address = "0x000000000022D473030F116dDEE9F6B43aC78BA3";

describe("TokenBuyer", function () {
  this.beforeAll("get accounts", async () => {
    [wallet0, feeCollector, randomWallet] = await ethers.getSigners();
  });

  this.beforeEach("deploy new contracts", async () => {
    const TokenBuyer = await ethers.getContractFactory("TokenBuyer");
    tokenBuyer = await TokenBuyer.deploy(universalRouterAddress, permit2Address, feeCollector.address, feePercentBps);

    await tokenBuyer.setBaseFee(ethers.ZeroAddress, baseFeeEther);

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

  context("getting assets and paying fees", async () => {
    it("should revert if transferring tokens fails", async () => {
      await setCode(await token.getAddress(), badTokenBytecode);
      await token.approve(tokenBuyer, 10);
      const tx = tokenBuyer.getAssets(guildId, { tokenAddress: token, amount: 10 }, "0x00", []);
      await expect(tx)
        .to.be.revertedWithCustomError(tokenBuyer, "TransferFailed")
        .withArgs(wallet0.address, await tokenBuyer.getAddress());
    });

    it("should swap native token to ERC20 and distribute tokens correctly", async () => {
      const usdc = token.attach("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48") as Contract;
      const amountIn = ethers.parseEther("0.014");
      const amountOut = ethers.parseUnits("25", 6);

      const amountInWithFee = (amountIn * (feePercentBps + 10000n)) / 10000n + baseFeeEther;
      const fee = amountInWithFee - amountIn;

      const eoaERC20Balance0 = await usdc.balanceOf(wallet0.address);
      const eoaBalance0 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance0 = await ethers.provider.getBalance(feeCollector.address);

      await tokenBuyer.getAssets(
        guildId,
        { tokenAddress: ethers.ZeroAddress, amount: 0 },
        "0x0b010c", // WRAP_ETH, V3_SWAP_EXACT_OUT, UNWRAP_ETH
        [
          encodeWrapEth("0x0000000000000000000000000000000000000002", amountIn),
          encodeV3SwapExactOut(
            wallet0.address,
            amountOut,
            amountIn,
            "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb480001f4c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            false
          ),
          encodeUnwrapEth(wallet0.address, 0)
        ],
        { value: amountInWithFee }
      );

      const contractERC20Balance = await usdc.balanceOf(tokenBuyer);
      const contractBalance = await ethers.provider.getBalance(tokenBuyer);
      const eoaERC20Balance1 = await usdc.balanceOf(wallet0.address);
      const eoaBalance1 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance1 = await ethers.provider.getBalance(feeCollector.address);

      expect(contractERC20Balance).to.eq(0);
      expect(contractBalance).to.eq(0);
      expect(eoaERC20Balance1).to.eq(eoaERC20Balance0 + amountOut);
      expect(eoaBalance1).to.closeTo(eoaBalance0 - amountInWithFee, ethers.parseEther("0.005"));
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0 + fee);
    });

    it("should swap ERC20 to ERC20 and distribute tokens correctly", async () => {
      const usdc = token.attach("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48") as Contract;
      const weth = token.attach("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2") as Contract;
      const amountIn = 15343306352920000n;
      const amountOut = ethers.parseUnits("25", 6);

      const amountInWithFee = (amountIn * (feePercentBps + 10000n)) / 10000n;
      const fee = amountInWithFee - amountIn;

      await wallet0.sendTransaction({ to: weth, value: amountInWithFee });
      await weth.approve(tokenBuyer, amountInWithFee);

      const eoaTokenOutBalance0 = await usdc.balanceOf(wallet0.address);
      const eoaTokenInBalance0 = await weth.balanceOf(wallet0.address);
      const feeCollectorBalance0 = await weth.balanceOf(feeCollector.address);

      await tokenBuyer.getAssets(
        guildId,
        { tokenAddress: await weth.getAddress(), amount: amountInWithFee },
        "0x0a01", // PERMIT2_PERMIT, V3_SWAP_EXACT_OUT
        [
          encodePermit2Permit(
            await weth.getAddress(),
            "1461501637330902918203684832716283019655932542975",
            1706751423,
            0,
            universalRouterAddress,
            "1704161223",
            "0x00"
          ),
          encodeV3SwapExactOut(
            wallet0.address,
            amountOut,
            amountIn,
            "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb480001f4c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
            true
          )
        ]
      );

      const contractTokenOutBalance = await usdc.balanceOf(tokenBuyer);
      const contractTokenInBalance = await weth.balanceOf(tokenBuyer);
      const eoaTokenOutBalance1 = await usdc.balanceOf(wallet0.address);
      const eoaTokenInBalance1 = await weth.balanceOf(wallet0.address);
      const feeCollectorBalance1 = await weth.balanceOf(feeCollector.address);

      expect(contractTokenOutBalance).to.eq(0);
      expect(contractTokenInBalance).to.eq(0);
      expect(eoaTokenOutBalance1).to.eq(eoaTokenOutBalance0 + amountOut);
      expect(eoaTokenInBalance1).to.gte(eoaTokenInBalance0 - amountInWithFee);
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0 + fee);
    });

    it("should swap native token for CryptoPunks and distribute tokens correctly", async () => {
      const cryptopunks = token.attach("0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB") as Contract;
      const amountIn = 58690000000000000000n;
      const punkId = 3718;

      const amountInWithFee = (amountIn * (feePercentBps + 10000n)) / 10000n + baseFeeEther;
      const fee = amountInWithFee - amountIn;

      const eoaBalance0 = await ethers.provider.getBalance(wallet0.address);
      const eoaPunkBalance0 = await cryptopunks.balanceOf(wallet0.address);
      const feeCollectorBalance0 = await ethers.provider.getBalance(feeCollector.address);

      await tokenBuyer.getAssets(
        guildId,
        { tokenAddress: ethers.ZeroAddress, amount: 0 },
        "0x13", // CRYPTOPUNKS
        [encodeCryptoPunks(punkId, wallet0.address, amountIn)],
        { value: amountInWithFee }
      );

      const contractBalance = await ethers.provider.getBalance(tokenBuyer);
      const contractPunkBalance = await cryptopunks.balanceOf(tokenBuyer);
      const eoaPunkBalance1 = await cryptopunks.balanceOf(wallet0.address);
      const eoaBalance1 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance1 = await ethers.provider.getBalance(feeCollector.address);

      expect(contractBalance).to.eq(0);
      expect(contractPunkBalance).to.eq(0);
      expect(eoaPunkBalance1).to.eq(eoaPunkBalance0 + 1n);
      expect(eoaBalance1).to.lte(eoaBalance0 - amountInWithFee);
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0 + fee);
    });

    it("should swap native token for nft via seaport", async () => {
      const nft = token.attach(seaportOrder.advancedOrder.parameters.offer[0].token) as Contract;
      const amountIn = ethers.parseEther("0.084");
      const amountInWithFee = (amountIn * (feePercentBps + 10000n)) / 10000n + baseFeeEther;
      const fee = amountInWithFee - amountIn;

      const seaport = new Contract(ethers.ZeroAddress, seaportAbi, wallet0);
      const calldata = seaport.interface.encodeFunctionData("fulfillAdvancedOrder", [
        seaportOrder.advancedOrder,
        seaportOrder.criteriaResolvers,
        seaportOrder.fulfillerConduitKey,
        wallet0.address
      ]);

      const eoaNftBalance0 = await nft.balanceOf(wallet0.address);
      const eoaBalance0 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance0 = await ethers.provider.getBalance(feeCollector.address);

      await tokenBuyer.getAssets(
        guildId,
        { tokenAddress: ethers.ZeroAddress, amount: 0 },
        "0x2004", // SEAPORT_V1_4, SWEEP
        [encodeSeaport(amountIn, calldata), encodeSweep(ethers.ZeroAddress, wallet0.address, 0)],
        { value: amountInWithFee }
      );

      const contractBalance = await ethers.provider.getBalance(tokenBuyer);
      const contractNftBalance = await nft.balanceOf(tokenBuyer);
      const eoaNftBalance1 = await nft.balanceOf(wallet0.address);
      const eoaBalance1 = await ethers.provider.getBalance(wallet0.address);
      const feeCollectorBalance1 = await ethers.provider.getBalance(feeCollector.address);

      expect(contractBalance).to.eq(0);
      expect(contractNftBalance).to.eq(0);
      expect(eoaNftBalance1).to.eq(eoaNftBalance0 + 1n);
      expect(eoaBalance1).to.lte(eoaBalance0 - amountInWithFee);
      expect(feeCollectorBalance1).to.eq(feeCollectorBalance0 + fee);
    });

    it("should emit a TokensBought event", async () => {
      const amountIn = 1955340553184920000n;
      const amountInWithFee = (amountIn * (feePercentBps + 10000n)) / 10000n + baseFeeEther;

      const tx = await tokenBuyer.getAssets(
        guildId,
        { tokenAddress: ethers.ZeroAddress, amount: 0 },
        "0x0b", // WRAP_ETH
        [encodeWrapEth(wallet0.address, amountIn)],
        { value: amountInWithFee }
      );

      await expect(tx).to.emit(tokenBuyer, "TokensBought").withArgs(guildId);
    });
  });

  context("the base fee", async () => {
    it("should revert if it's attempted to be changed by anyone but the owner", async () => {
      await expect((tokenBuyer.connect(randomWallet) as Contract).setBaseFee(token, 10)).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });

    it("should change the fee", async () => {
      const feeAmount = ethers.parseEther("0.003");
      await tokenBuyer.setBaseFee(token, feeAmount);
      const newFee = await tokenBuyer.baseFee(token);
      expect(newFee).to.eq(feeAmount);
    });

    it("should emit a BaseFeeChanged event", async () => {
      const tx = tokenBuyer.setBaseFee(token, 10);
      await expect(tx)
        .to.emit(tokenBuyer, "BaseFeeChanged")
        .withArgs(await token.getAddress(), 10);
    });
  });

  context("the fee collector", async () => {
    it("should revert if it's attempted to be changed by anyone but the owner", async () => {
      await expect(
        (tokenBuyer.connect(randomWallet) as Contract).setFeeCollector(randomWallet.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should change the address", async () => {
      await tokenBuyer.setFeeCollector(randomWallet.address);
      const newAddress = await tokenBuyer.feeCollector();
      expect(newAddress).to.eq(randomWallet.address);
    });

    it("should emit a FeeCollectorChanged event", async () => {
      const tx = tokenBuyer.setFeeCollector(randomWallet.address);
      await expect(tx).to.emit(tokenBuyer, "FeeCollectorChanged").withArgs(randomWallet.address);
    });
  });

  context("the fee collector's share", async () => {
    it("should revert if it's attempted to be changed by anyone but the owner", async () => {
      await expect((tokenBuyer.connect(randomWallet) as Contract).setFeePercentBps("100")).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });

    it("should change the value", async () => {
      await tokenBuyer.setFeePercentBps("100");
      const newValue = await tokenBuyer.feePercentBps();
      expect(newValue).to.eq("100");
    });

    it("should emit a FeePercentBpsChanged event", async () => {
      const tx = tokenBuyer.setFeePercentBps("100");
      await expect(tx).to.emit(tokenBuyer, "FeePercentBpsChanged").withArgs("100");
    });
  });

  context("sweep tokens", async () => {
    it("should revert if it's attempted to be called by anyone but the owner", async () => {
      await expect(
        (tokenBuyer.connect(randomWallet) as Contract).sweep(ethers.ZeroAddress, wallet0.address, 0)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should revert if transferring tokens fails", async () => {
      await setCode(await token.getAddress(), badTokenBytecode);
      await expect(tokenBuyer.sweep(token, wallet0.address, 0))
        .to.be.revertedWithCustomError(tokenBuyer, "TransferFailed")
        .withArgs(await tokenBuyer.getAddress(), wallet0.address);
    });

    it("should give ERC20", async () => {
      const amount = ethers.parseEther("0.69");

      await token.transfer(tokenBuyer, amount);

      const balance0 = await token.balanceOf(wallet0.address);
      const contractBalance0 = await token.balanceOf(tokenBuyer);

      await tokenBuyer.sweep(token, wallet0.address, amount);

      const balance1 = await token.balanceOf(wallet0.address);
      const contractBalance1 = await token.balanceOf(tokenBuyer);

      expect(contractBalance0).to.not.eq(0);
      expect(contractBalance1).to.eq(0);
      expect(balance1).to.eq(balance0 + amount);
    });

    it("should emit a TokensSweeped event", async () => {
      const amount = ethers.parseEther("0.69");

      await token.transfer(tokenBuyer, amount);

      const tx = tokenBuyer.sweep(token, wallet0.address, amount);

      await expect(tx)
        .to.emit(tokenBuyer, "TokensSweeped")
        .withArgs(await token.getAddress(), wallet0.address, amount);
    });
  });
});
