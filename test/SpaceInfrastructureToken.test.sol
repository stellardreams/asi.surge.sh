// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/SpaceInfrastructureToken.sol";

import { expect } from "chai";
import { ethers } from "hardhat";

describe("SpaceInfrastructureToken", function() {
  let token;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  
  beforeEach(async () => {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    
    token = await ethers.getContractFactory("SpaceInfrastructureToken");
    token = await token.deploy();
    await token.deployed();
  });
  
  describe("Initialization", function() {
    it("Should set initial shares for deployer", async function() {
      const balance = await token.totalShares();
      expect(balance).to.equal(ethers.utils.parseEther("1000000"));
      
      const ownerShares = await token.getVoterShares(owner.address);
      expect(ownerShares).to.equal(ethers.utils.parseEther("1000000"));
    });
  });
  
  describe("Ownership Transfer", function() {
    it("Should transfer shares between addresses", async function() {
      // Transfer 100 shares to addr1
      await token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("100"));
      
      const ownerBalance = await token.getVoterShares(owner.address);
      expect(ownerBalance).to.equal(ethers.utils.parseEther("999900"));
      
      const addr1Balance = await token.getVoterShares(addr1.address);
      expect(addr1Balance).to.equal(ethers.utils.parseEther("100"));
    });
    
    it("Should handle partial transfers across multiple entries", async function() {
      // Give addr1 50 shares from owner
      await token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("50"));
      
      // Transfer 30 shares back to owner from addr1
      await token.transferOwnership(addr1.address, owner.address, ethers.utils.parseEther("30"));
      
      const ownerBalance = await token.getVoterShares(owner.address);
      expect(ownerBalance).to.equal(ethers.utils.parseEther("999930"));
      
      const addr1Balance = await token.getVoterShares(addr1.address);
      expect(addr1Balance).to.equal(ethers.utils.parseEther("20"));
    });
    
    it("Should prevent transferring more shares than owned", async function() {
      await expect(token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("1000001")))
        .to.be.revertedWith("Insufficient shares");
    });
  });
  
  describe("Proposal Creation", function() {
    it("Should create a proposal", async function() {
      const tx = await token.createProposal("Test proposal", ethers.utils.parseEther("100"));
      await tx.wait();
      
      // Check that proposal was created
      const proposalId = (await token.nextProposalId()) - 1;
      const proposal = await token.proposals(proposalId);
      
      expect(proposal.proposer).to.equal(owner.address);
      expect(proposal.description).to.equal("Test proposal");
      expect(proposal.targetShares).to.equal(ethers.utils.parseEther("100"));
      expect(proposal.executed).to.be.false;
    });
    
    it("Should require sufficient shares to create proposal", async function() {
      await expect(token.createProposal("Test", ethers.utils.parseEther("1000000")))
        .to.be.revertedWith("Sender does not have enough shares");
    });
  });
  
  describe("Voting", function() {
    it("Should allow voting on proposals", async function() {
      // Create proposal
      const tx = await token.createProposal("Vote on shares", ethers.utils.parseEther("500"));
      await tx.wait();
      const proposalId = (await token.nextProposalId()) - 1;
      
      // Transfer shares to addr1 so they can vote
      await token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("600"));
      
      // Vote for proposal
      await token.connect(addr1).vote(proposalId, true);
      
      const proposal = await token.proposals(proposalId);
      expect(proposal.forVotes).to.equal(ethers.utils.parseEther("600"));
    });
    
    it("Should prevent multiple votes on same proposal", async function() {
      const tx = await token.createProposal("Test vote", ethers.utils.parseEther("100"));
      await tx.wait();
      const proposalId = (await token.nextProposalId()) - 1;
      
      await token.connect(addr1).vote(proposalId, true);
      
      // Try to vote again
      await expect(token.connect(addr1).vote(proposalId, false))
        .to.be.revertedWith("Already voted");
    });
  });
  
  describe("Proposal Execution", function() {
    it("Should execute proposal that meets quorum and target", async function() {
      // Create proposal with low target to test
      const tx = await token.createProposal("Test execution", ethers.utils.parseEther("500"));
      await tx.wait();
      const proposalId = (await token.nextProposalId()) - 1;
      
      // Transfer shares to addr1 so they can vote
      await token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("600"));
      
      // Vote for proposal
      await token.connect(addr1).vote(proposalId, true);
      
      // Wait for deadline (simulate by advancing time)
      // In a real test, we'd need to manipulate block number or use a mock
      // For now, we'll just check that the function can be called
      await expect(token.executeProposal(proposalId)).to.not.be.reverted;
      
      const proposal = await token.proposals(proposalId);
      expect(proposal.executed).to.be.true;
    });
  });
  
  describe("Emergency Pause", function() {
    it("Should allow owner to pause and unpause contract", async function() {
      await token.pauseContract();
      expect(await token.paused()).to.be.true;
      
      await token.unpauseContract();
      expect(token.paused()).to.be.false;
    });
    
    it("Should prevent transfers when paused", async function() {
      await token.pauseContract();
      await expect(token.transferOwnership(owner.address, addr1.address, ethers.utils.parseEther("100")))
        .to.be.revertedWith("Pausable: paused");
    });
  });
});