import { expect } from "chai";

describe("SpaceInfrastructureTokenV2", function () {
  let SpaceInfrastructureTokenV2, token, owner, addr1, addr2;

  beforeEach(async function () {
    SpaceInfrastructureTokenV2 = await ethers.getContractFactory("SpaceInfrastructureTokenV2");
    [owner, addr1, addr2] = await ethers.getSigners();
    token = await SpaceInfrastructureTokenV2.deploy();
    await token.waitForDeployment();

    // Mint some tokens to addr1 for testing
    await token.mint(addr1.address, 10000n * 10n ** 18n);
  });

  describe("Deployment", function () {
    it("Should have correct name and symbol", async function () {
      expect(await token.name()).to.equal("SpaceInfrastructureToken");
      expect(await token.symbol()).to.equal("SIT");
    });

    it("Should assign initial supply to deployer", async function () {
      const initialSupply = 100000n * 10n ** 18n;
      expect(await token.totalSupply()).to.equal(initialSupply);
      expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
    });
  });

  describe("Governance", function () {
    it("Should create a proposal", async function () {
      const description = "Test proposal";
      const targetAmount = 1000n * 10n ** 18n;

      await expect(token.createProposal(description, targetAmount))
        .to.emit(token, "ProposalCreated")
        .withArgs(0, owner.address, description, targetAmount);

      const proposal = await token.proposals(0);
      expect(proposal.description).to.equal(description);
      expect(proposal.targetAmount).to.equal(targetAmount);
    });

    it("Should allow voting on proposal", async function () {
      const description = "Test proposal";
      const targetAmount = 1000n * 10n ** 18n;

      await token.createProposal(description, targetAmount);

      await expect(token.vote(0, true))
        .to.emit(token, "VoteCast");

      expect(await token.hasVoted(owner.address, 0)).to.be.true;
    });

    it("Should execute proposal if quorum met", async function () {
      const description = "Test proposal";
      const targetAmount = 1000n * 10n ** 18n;

      await token.createProposal(description, targetAmount);

      // Fast forward to after deadline
      await ethers.provider.send("evm_increaseTime", [1000 * 15]); // 1000 blocks * 15s
      await ethers.provider.send("evm_mine");

      await expect(token.executeProposal(0))
        .to.emit(token, "ProposalExecuted")
        .withArgs(0, true); // Should pass since forVotes >= targetAmount
    });
  });

  describe("Vesting", function () {
    it("Should create vesting schedule", async function () {
      const amount = 1000n * 10n ** 18n;
      const startBlock = (await ethers.provider.getBlockNumber()) + 10;
      const endBlock = startBlock + 100;

      await expect(token.createVestingSchedule(addr1.address, startBlock, endBlock, amount))
        .to.emit(token, "VestingCreated");

      const vestingIds = await token.getVestingIds(addr1.address);
      expect(vestingIds.length).to.equal(1);

      const vesting = await token.vestingScheduleDetails(vestingIds[0]);
      expect(vesting.beneficiary).to.equal(addr1.address);
      expect(vesting.amount).to.equal(amount);
    });

    it("Should allow claiming vested tokens", async function () {
      const amount = 1000n * 10n ** 18n;
      const startBlock = await ethers.provider.getBlockNumber();
      const endBlock = startBlock + 10;

      await token.createVestingSchedule(addr1.address, startBlock, endBlock, amount);

      // Fast forward halfway
      for (let i = 0; i < 5; i++) {
        await ethers.provider.send("evm_mine");
      }

      const vestingIds = await token.getVestingIds(addr1.address);
      const vestingId = vestingIds[0];

      await expect(token.connect(addr1).claimVesting(vestingId))
        .to.emit(token, "VestingClaimed");

      const balance = await token.balanceOf(addr1.address);
      expect(balance).to.be.gt(0);
    });
  });

  describe("Access Control", function () {
    it("Should allow owner to add minter", async function () {
      await expect(token.addMinter(addr1.address))
        .to.emit(token, "MinterAdded");

      // Check role
      expect(await token.hasRole(await token.MINTER_ROLE(), addr1.address)).to.be.true;
    });

    it("Should allow minter to mint tokens", async function () {
      await token.addMinter(addr1.address);

      const amount = 1000n * 10n ** 18n;
      await expect(token.connect(addr1).mint(addr2.address, amount))
        .to.changeTokenBalance(token, addr2, amount);
    });
  });
});