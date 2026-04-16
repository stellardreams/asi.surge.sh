// SPDX-License-Identifier: MIT
/*
 * EnhancedSpaceInfrastructureToken.sol
 * 
 * This contract extends the original SpaceInfrastructureToken with ERC-20 compatibility
 * and additional features for community rewards and vesting.
 * 
 * Requestor: @genidma
 * Lead Developer: KiloAI via Trinity Large Thinking Model via Arcee AI
 * Created: 2026-04-14T00:08:16-04:00
 * 
 * This code is for prototyping and requires security audit before production use.
 */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SpaceInfrastructureToken.sol";

contract EnhancedSpaceInfrastructureToken is SpaceInfrastructureToken, ERC20, AccessControl {
    
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNING_ROLE = keccak256("BURNING_ROLE");
    bytes32 public constant VOTING_ROLE = keccak256("VOTING_ROLE");
    
    // Governance parameters (matching original)

    
    // Vesting parameters
    struct VestingSchedule {
        address beneficiary;
        uint256 startBlock;
        uint256 endBlock;
        uint256 amount;
        uint256 claimed;
        bool revoked;
    }
    
    // Events (including ERC-20 events)
    event ERC20Transfer(address indexed from, address indexed to, uint256 value);
    event ERC20Approval(address indexed owner, address indexed spender, uint256 value);


    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event VestingCreated(address indexed beneficiary, uint256 startBlock, uint256 endBlock, uint256 amount);
    event VestingClaimed(address indexed beneficiary, uint256 amount);
    event VestingRevoked(address indexed beneficiary, uint256 amount);
    
    // State
    mapping(address => uint256[]) public vestingSchedules;
    mapping(uint256 => VestingSchedule) public vestingScheduleDetails;
    uint256 public totalVestingAmount;

    mapping(uint256 => mapping(address => uint256)) public votingPowerAtProposal;
    
    // Override ERC-20 name, symbol, decimals
    function name() public view override returns (string memory) {
        return "SpaceInfrastructureToken";
    }
    
    function symbol() public view override returns (string memory) {
        return "SIT";
    }
    
    function decimals() public view override returns (uint8) {
        return 18;
    }
    
    // Constructor
    constructor() ERC20("SpaceInfrastructureToken", "SIT") {
        // Initialize roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNING_ROLE, msg.sender);

        // Deployer gets initial supply (100,000 tokens)
        _mint(msg.sender, 100000 * 10 ** 18);
        emit OwnershipTransferred(address(0), msg.sender, 100000 * 10 ** 18, block.number);
    }
    
    // Override transfer to emit custom events (ERC-20 Transfer already emitted)
    function transfer(address to, uint256 value) public override onlyActive returns (bool) {
        bool success = super.transfer(to, value);
        if (success) {
            emit OwnershipTransferred(msg.sender, to, value, block.number);
        }
        return success;
    }

    // Override transferFrom to emit custom events
    function transferFrom(address from, address to, uint256 value) public override onlyActive returns (bool) {
        bool success = super.transferFrom(from, to, value);
        if (success) {
            emit OwnershipTransferred(from, to, value, block.number);
        }
        return success;
    }
    
    // Create proposal (same as original but with ERC-20 amounts)
    function createProposal(string memory description, uint256 targetShares) external onlyActive override returns (uint256) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(targetShares > 0, "Target shares must be positive");
        require(msg.sender != address(0), "Invalid sender");
        require(targetShares >= MIN_PROPOSAL_SHARES, "Insufficient proposal shares");
        require(balanceOf(msg.sender) >= targetShares, "Sender does not have enough tokens");
        
        uint256 proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposalId: proposalId,
            proposer: msg.sender,
            description: description,
            targetShares: targetShares,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            deadline: block.number + PROPOSAL_DURATION_BLOCKS
        });

        // Snapshot voting power at proposal creation
        votingPowerAtProposal[proposalId][msg.sender] = balanceOf(msg.sender);

        emit ProposalCreated(proposalId, msg.sender, description, targetShares);
        return proposalId;
    }
    
    // Vote (uses ERC-20 balance)
    function vote(uint256 proposalId, bool support) external onlyActive override {
        Proposal storage p = proposals[proposalId];
        require(block.number <= p.deadline, "Voting period ended");
        require(!p.executed, "Proposal already executed");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        uint256 voterAmount = votingPowerAtProposal[proposalId][msg.sender];
        require(voterAmount > 0, "No voting amount");
        
        if (support) {
            p.forVotes += voterAmount;
        } else {
            p.againstVotes += voterAmount;
        }
        
        hasVoted[proposalId][msg.sender] = true;
        emit VoteCast(msg.sender, proposalId, support, voterAmount, block.number);
    }
    
    // Execute proposal (same as original)
    function executeProposal(uint256 proposalId) external onlyOwnerOrProposer(proposalId) override {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(block.number > p.deadline, "Deadline not reached");
        
        uint256 totalVotes = p.forVotes + p.againstVotes;
        uint256 totalAmount = totalSupply();
        uint256 quorumAmount = (totalAmount * QUORUM_PERCENTAGE) / 100;
        
        // Check quorum
        if (totalVotes < quorumAmount) {
            p.executed = true;
            emit ProposalExecuted(proposalId, false);
            return;
        }
        
        // Check if for votes meet target
        if (p.forVotes >= p.targetShares) {
            p.executed = true;
            emit ProposalExecuted(proposalId, true);
        } else {
            p.executed = true;
            emit ProposalExecuted(proposalId, false);
        }
    }
    
    // Vesting functions (similar to previous but using ERC-20)
    function createVestingSchedule(address beneficiary, uint256 startBlock, uint256 endBlock, uint256 amount) external onlyOwner {
        require(startBlock < endBlock, "Invalid vesting period");
        require(amount > 0, "Amount must be positive");
        require(totalVestingAmount + amount <= totalSupply(), "Insufficient supply");
        
        uint256 vestingId = totalVestingAmount + 1;
        vestingSchedules[beneficiary].push(vestingId);
        vestingScheduleDetails[vestingId] = VestingSchedule({
            beneficiary: beneficiary,
            startBlock: startBlock,
            endBlock: endBlock,
            amount: amount,
            claimed: 0,
            revoked: false
        });
        
        totalVestingAmount += amount;
        _mint(beneficiary, amount); // Mint the full amount but lock it
        
        emit VestingCreated(beneficiary, startBlock, endBlock, amount);
    }
    
    function claimVesting(uint256 vestingId) external onlyActive {
        VestingSchedule storage vesting = vestingScheduleDetails[vestingId];

        require(vesting.beneficiary == msg.sender, "Not a beneficiary");
        require(block.number >= vesting.startBlock, "Vesting not started");
        require(!vesting.revoked, "Vesting revoked");

        uint256 elapsedBlocks = block.number - vesting.startBlock;
        uint256 totalBlocks = vesting.endBlock - vesting.startBlock;
        uint256 vestedAmount = (vesting.amount * elapsedBlocks) / totalBlocks;
        uint256 claimable = vestedAmount - vesting.claimed;

        require(claimable > 0, "No claimable amount");

        vesting.claimed += claimable;
        _transfer(address(this), msg.sender, claimable);

        emit VestingClaimed(msg.sender, claimable);
    }
    
    function revokeVesting(uint256 vestingId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        VestingSchedule storage vesting = vestingScheduleDetails[vestingId];

        require(vesting.beneficiary != address(0), "Vesting does not exist");
        require(!vesting.revoked, "Vesting already revoked");

        uint256 elapsedBlocks = block.number - vesting.startBlock;
        uint256 totalBlocks = vesting.endBlock - vesting.startBlock;
        uint256 vestedAmount = (vesting.amount * elapsedBlocks) / totalBlocks;

        vesting.revoked = true;
        _transfer(vesting.beneficiary, address(this), vestedAmount);
        emit VestingRevoked(vesting.beneficiary, vestedAmount);
    }
    
    function getVestingIds(address beneficiary) public view returns (uint256[] memory) {
        return vestingSchedules[beneficiary];
    }
    
    // Minter functions
    function addMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, account);
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, account);
        emit MinterRemoved(account);
    }
    
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit OwnershipTransferred(address(0), to, amount, block.number);
    }
    
    function burn(address from, uint256 amount) public onlyRole(BURNING_ROLE) {
        _burn(from, amount);
    }
    
    // Pause/unpause
    function pauseContract() public onlyOwner override {
        _pause();
        emit Paused(msg.sender);
    }
    
    function unpauseContract() public onlyOwner override {
        _unpause();
        emit Unpaused(msg.sender);
    }
}