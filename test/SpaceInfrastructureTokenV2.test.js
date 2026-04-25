import { ethers } from "ethers";
import chai from "chai";
const { expect } = chai;

describe("SpaceInfrastructureTokenV2", function () {
  let SpaceInfrastructureTokenV2, token, owner, addr1, addr2;

  beforeEach(async function () {
    SpaceInfrastructureTokenV2 = await ethers.getContractFactory("SpaceInfrastructureTokenV2");
    [owner, addr1, addr2] = await ethers.getSigners();
    token = await SpaceInfrastructureTokenV2.deploy();
    await token.waitForDeployment();
  });

    describe("Deployment", function () {
      it("Should have correct name and symbol", async function () {
        expect(await token.name()).to.equal("SpaceInfrastructureToken");
        expect(await token.symbol()).to.equal("SIT");
      });

      it("Should assign initial supply to deployer", async function () {
        const initialSupply = ethers.parseEther("100000000000");
        const mintAmount = ethers.parseEther("10000");
        expect(await token.totalSupply()).to.equal(initialSupply + mintAmount);
        expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
        expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
      });

    it("Should assign initial supply to deployer", async function () {
      const initialSupply = ethers.parseEther("100000000000");
      const mintAmount = ethers.parseEther("10000");
      expect(await token.totalSupply()).to.equal(initialSupply + mintAmount);
      expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
    });
  });

    describe("Governance", function () {
      it("Should create a proposal", async function () {
        const description = "Test proposal";
        const targetAmount = ethers.parseEther("1000");

        await token.createProposal(description, targetAmount);

        const proposal = await token.proposals(0);
        expect(proposal.description).to.equal(description);
        expect(proposal.targetAmount).to.equal(targetAmount);
      });

    it("Should allow voting on proposal", async function () {
      const description = "Test proposal";
      const targetAmount = ethers.parseEther("1000");

      await token.createProposal(description, targetAmount);

      await token.vote(0, true);

      expect(await token.hasVoted(0, owner.address)).to.be.true;
    });

    it("Should execute proposal if quorum met", async function () {
      const description = "Test proposal";
      const targetAmount = ethers.BigNumber.from("1000000000000000000000");

      await token.createProposal(description, targetAmount);

      // Vote for the proposal
      await token.vote(0, true);

      // Mine blocks to pass deadline (1000 blocks)
      for (let i = 0; i < 1000; i++) {
        await ethers.provider.send("evm_mine");
      }

      // Queue the proposal
      await token.queueProposal(0);

      // Advance time to pass timelock (1 day)
      await ethers.provider.send("evm_increaseTime", [86400]);
      await ethers.provider.send("evm_mine");

      await token.executeProposal(0);

      const proposal = await token.proposals(0);
      expect(proposal.executed).to.be.true;
    });
  });

    describe("Vesting", function () {
      it("Should create vesting schedule", async function () {
        const amount = ethers.parseEther("1000");
        const startBlock = (await ethers.provider.getBlockNumber()) + 10;
        const endBlock = startBlock + 100;

        await token.createVestingSchedule(addr1.address, startBlock, endBlock, amount);

        const vestingIds = await token.getVestingIds(addr1.address);
        expect(vestingIds.length).to.equal(1);

        const vesting = await token.vestingScheduleDetails(vestingIds[0]);
        expect(vesting.beneficiary).to.equal(addr1.address);
        expect(vesting.amount).to.equal(amount);
      });

    it("Should allow claiming vested tokens", async function () {
      const amount = ethers.parseEther("1000");
      const startBlock = (await ethers.provider.getBlockNumber()) + 1;
      const endBlock = startBlock + 10;

      await token.createVestingSchedule(addr1.address, startBlock, endBlock, amount);

      // Fast forward halfway
      for (let i = 0; i < 6; i++) {
        await ethers.provider.send("evm_mine");
      }

      const vestingIds = await token.getVestingIds(addr1.address);
      const vestingId = vestingIds[0];

      await token.connect(addr1).claimVesting(vestingId);

      const balance = await token.balanceOf(addr1.address);
      expect(balance.gt(0)).to.be.true;
    });
  });

    describe("Access Control", function () {
    it("Should allow minter to mint tokens", async function () {
      await token.addMinter(addr1.address);

      const amount = ethers.parseEther("1000");
      const balanceBefore = await token.balanceOf(addr2.address);
      await token.connect(addr1).mint(addr2.address, amount);
      const balanceAfter = await token.balanceOf(addr2.address);
      expect(balanceAfter - balanceBefore).to.equal(amount);
    });
  });
});