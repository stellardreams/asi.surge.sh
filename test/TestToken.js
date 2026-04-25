import { ethers } from "ethers";
import chai from "chai";
const { expect } = chai;

describe("TestToken", function () {
  let token;
  let owner;
  let addr1;
  let addr2;

  before(async function () {
    const TestToken = await ethers.getContractFactory("TestToken");
    token = await TestToken.deploy();
    await token.waitForDeployment();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("Should have correct name", async function () {
      expect(await token.name()).to.equal("TestToken");
    });

    it("Should have correct symbol", async function () {
      expect(await token.symbol()).to.equal("TEST");
    });

    it("Should have 10 billion supply", async function () {
      const totalSupply = await token.totalSupply();
      expect(totalSupply).to.equal(ethers.parseEther("10000000000"));
    });

    it("Should assign total supply to owner", async function () {
      expect(await token.balanceOf(owner.address)).to.equal(ethers.parseEther("10000000000"));
    });
  });

  describe("Transfers", function () {
    it("Should transfer tokens between accounts", async function () {
      await token.transfer(addr1.address, ethers.parseEther("1000"));
      expect(await token.balanceOf(addr1.address)).to.equal(ethers.parseEther("1000"));
    });
  });

  describe("Approvals", function () {
    it("Should approve spender", async function () {
      await token.approve(addr1.address, ethers.parseEther("500"));
      expect(await token.allowance(owner.address, addr1.address)).to.equal(ethers.parseEther("500"));
    });

    it("Should transfer from approved account", async function () {
      await token.transfer(owner.address, ethers.parseEther("1000"));
      await token.connect(addr1).transferFrom(owner.address, addr2.address, ethers.parseEther("500"));
      expect(await token.balanceOf(addr2.address)).to.equal(ethers.parseEther("500"));
    });
  });
});