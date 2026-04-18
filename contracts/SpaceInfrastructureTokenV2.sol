// SPDX-License-Identifier: MIT
/*
 * SpaceInfrastructureTokenV2.sol
 * 
 * Enhanced version of the SpaceInfrastructureToken with ERC-20 compatibility
 * and additional features for community rewards and vesting.
 * 
 * This contract extends the original governance token with:
 * - ERC-20 standard interface
 * - Mintable/burnable functions for community rewards
 * - Vesting schedules for team/advisors
 * - Access controls for different roles
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
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

contract SpaceInfrastructureTokenV2 is ERC20, Ownable, Pausable, AccessControl {
    
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant VOTING_ROLE = keccak256("VOTING_ROLE");
    
    // Governance parameters
    uint256 public constant PROPOSAL_DURATION_BLOCKS = 1000; // ~4 hours at 15s blocks
    uint256 public constant QUORUM_PERCENTAGE = 20; // 20% of total shares must participate
    uint256 public constant MIN_PROPOSAL_SHARES = 1000; // Minimum shares required to create proposal
    uint256 public constant TIMELOCK_DELAY = 86400; // 1 day delay for execution
    
    // Vesting parameters
    struct VestingSchedule {
        address beneficiary;
        uint256 startBlock;
        uint256 endBlock;
        uint256 amount;
        uint256 claimed;
        bool revoked;
    }
    
    // Events
    event TokenTransferred(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    event NewParticipant(address indexed participant, uint256 initialAmount, uint256 timestamp);
    event ShareConsolidated(address indexed participant, uint256 oldAmount, uint256 newAmount, uint256 timestamp);
    event ProposalCreated(uint256 proposalId, address indexed proposer, string description, uint256 targetAmount);
    event VoteCast(address indexed voter, uint256 proposalId, bool support, uint256 amount, uint256 timestamp);
    event ProposalQueued(uint256 proposalId, uint256 executionTime);
    event ProposalExecuted(uint256 proposalId, bool passed);

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event VestingCreated(address indexed beneficiary, uint256 startBlock, uint256 endBlock, uint256 amount);
    event VestingClaimed(address indexed beneficiary, uint256 amount);
    event VestingRevoked(address indexed beneficiary, uint256 amount);
    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    
    // State
    mapping(address => uint256[]) public vestingSchedules;
    mapping(uint256 => VestingSchedule) public vestingScheduleDetails;
    uint256 public totalVestingAmount;
    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public votingPowerAtProposal;

    // Token locking
    struct Lock {
        uint256 amount;
        uint256 unlockTime;
    }
    mapping(address => Lock[]) public locks;
    mapping(address => uint256) public totalLocked;

    // Staking
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaim;
    }
    mapping(address => Stake) public stakes;
    uint256 public totalStaked;
    uint256 public rewardRate = 100; // 1% per day or something, adjust as needed

    // Treasury
    address public treasury;
    
    // Proposal struct (same as original)
    struct Proposal {
        uint256 proposalId;
        address proposer;
        string description;
        uint256 targetAmount;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        uint256 deadline;
        uint256 queuedTimestamp;
    }
    
    // Modifier for active contract
    modifier onlyActive() {
        require(!paused(), "Contract is paused");
        _;
    }
    
    // Modifier for only owner or proposer
    modifier onlyOwnerOrProposer(uint256 proposalId) {
        require(msg.sender == owner() || msg.sender == proposals[proposalId].proposer, "Not authorized");
        _;
    }
    
    /**
     * @dev Constructor
     * Deploys the token with initial supply and sets up roles
     */
    constructor() ERC20("SpaceInfrastructureToken", "SIT") {
        // Deployer gets initial supply (100,000 tokens)
        _mint(msg.sender, 100000 * 10 ** decimals());
        emit TokenTransferred(address(0), msg.sender, 100000 * 10 ** decimals(), block.number);

        // Set treasury to deployer initially
        treasury = msg.sender;

        // Grant deployer all roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }
    
    /**
     * @dev Transfer tokens from one address to another (ERC-20 standard)
     * @param sender Source address (the owner of the tokens)
     * @param recipient Destination address
     * @param amount Amount of tokens to transfer
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override onlyActive returns (bool) {
        require(sender != recipient, "Cannot transfer to self");
        require(sender != address(0) && recipient != address(0), "Invalid address");
        require(amount > 0, "Amount must be positive");
        require(unlockedBalanceOf(sender) >= amount, "Insufficient unlocked balance");

        uint256 currentAllowance = allowance(sender, msg.sender);
        require(currentAllowance >= amount, "Allowance exceeded");

        _transfer(sender, recipient, amount);
        _spendAllowance(sender, msg.sender, amount);

        emit TokenTransferred(sender, recipient, amount, block.number);
        return true;
    }
    
    /**
     * @dev Create a new governance proposal
     * @param description Proposal description
     * @param targetAmount Minimum amount required to pass
     * @return proposalId
     */
    function createProposal(string memory description, uint256 targetAmount) external onlyActive returns (uint256) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(targetAmount > 0, "Target amount must be positive");
        require(msg.sender != address(0), "Invalid sender");
        require(targetAmount >= MIN_PROPOSAL_SHARES, "Insufficient proposal amount");
        require(balanceOf(msg.sender) >= targetAmount, "Sender does not have enough tokens");
        
        uint256 proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposalId: proposalId,
            proposer: msg.sender,
            description: description,
            targetAmount: targetAmount,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            deadline: block.number + PROPOSAL_DURATION_BLOCKS,
            queuedTimestamp: 0
        });

        // Snapshot voting power at proposal creation
        votingPowerAtProposal[proposalId][msg.sender] = balanceOf(msg.sender);

        emit ProposalCreated(proposalId, msg.sender, description, targetAmount);
        return proposalId;
    }
    
    /**
     * @dev Cast vote on a proposal
     * @param proposalId Proposal identifier
     * @param support Vote in favor (true) or against (false)
     */
    function vote(uint256 proposalId, bool support) external onlyActive {
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
    
    /**
     * @dev Queue a proposal for execution after voting period
     * @param proposalId Proposal identifier
     */
    function queueProposal(uint256 proposalId) external onlyOwnerOrProposer(proposalId) {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(block.number > p.deadline, "Voting period not ended");
        require(p.queuedTimestamp == 0, "Proposal already queued");

        uint256 totalVotes = p.forVotes + p.againstVotes;
        uint256 totalAmount = totalSupply();
        uint256 quorumAmount = (totalAmount * QUORUM_PERCENTAGE) / 100;

        // Check quorum
        require(totalVotes >= quorumAmount, "Quorum not reached");
        require(p.forVotes >= p.targetAmount, "Proposal did not pass");

        p.queuedTimestamp = block.timestamp;
        emit ProposalQueued(proposalId, block.timestamp + TIMELOCK_DELAY);
    }

    /**
     * @dev Execute a queued proposal after timelock delay
     * @param proposalId Proposal identifier
     */
    function executeProposal(uint256 proposalId) external onlyOwnerOrProposer(proposalId) {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(p.queuedTimestamp > 0, "Proposal not queued");
        require(block.timestamp >= p.queuedTimestamp + TIMELOCK_DELAY, "Timelock not expired");

        p.executed = true;
        emit ProposalExecuted(proposalId, true);
    }
    
    /**
     * @dev Create a vesting schedule for a beneficiary
     * @param beneficiary Address to receive vested tokens
     * @param startBlock Block when vesting starts
     * @param endBlock Block when vesting ends
     * @param amount Total amount to vest
     */
    function createVestingSchedule(address beneficiary, uint256 startBlock, uint256 endBlock, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
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
        _mint(address(this), amount); // Mint to contract for vesting
        
        emit VestingCreated(beneficiary, startBlock, endBlock, amount);
    }
    
    /**
     * @dev Claim vested tokens for a specific vesting schedule
     */
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
    
    /**
     * @dev Revoke a vesting schedule and return remaining tokens to owner
     */
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
    
    /**
     * @dev Get the vesting ID for a beneficiary
     */
    function getVestingIds(address beneficiary) public view returns (uint256[] memory) {
        return vestingSchedules[beneficiary];
    }
    
    /**
     * @dev Add minter role
     */
    function addMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, account);
        emit MinterAdded(account);
    }
    
    /**
     * @dev Remove minter role
     */
    function removeMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
        emit MinterRemoved(account);
    }
    
    /**
     * @dev Mint new tokens (only minters)
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit TokenTransferred(address(0), to, amount, block.number);
    }
    
    /**
     * @dev Burn tokens (only burner role)
     */
    function burn(uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev Pause contract (only owner)
     */
    function pauseContract() public onlyOwner {
        _pause();
        emit Paused(msg.sender);
    }
    
    /**
     * @dev Unpause contract (only owner)
     */
    function unpauseContract() public onlyOwner {
        _unpause();
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Lock tokens for a specified time
     * @param amount Amount of tokens to lock
     * @param unlockTime Timestamp when tokens can be unlocked
     */
    function lockTokens(uint256 amount, uint256 unlockTime) external onlyActive {
        require(amount > 0, "Amount must be positive");
        require(unlockTime > block.timestamp, "Unlock time must be in the future");
        require(balanceOf(msg.sender) >= totalLocked[msg.sender] + amount, "Insufficient unlocked balance");

        locks[msg.sender].push(Lock(amount, unlockTime));
        totalLocked[msg.sender] += amount;

        emit TokensLocked(msg.sender, amount, unlockTime);
    }

    /**
     * @dev Unlock tokens that have passed their unlock time
     */
    function unlockTokens() external onlyActive {
        uint256 totalUnlockable = 0;
        for (uint256 i = 0; i < locks[msg.sender].length; i++) {
            if (block.timestamp >= locks[msg.sender][i].unlockTime) {
                totalUnlockable += locks[msg.sender][i].amount;
                locks[msg.sender][i].amount = 0; // Mark as unlocked
            }
        }
        require(totalUnlockable > 0, "No tokens available to unlock");

        totalLocked[msg.sender] -= totalUnlockable;
        emit TokensUnlocked(msg.sender, totalUnlockable);
    }

    /**
     * @dev Get unlocked balance (total balance - locked)
     */
    function unlockedBalanceOf(address account) public view returns (uint256) {
        return balanceOf(account) - totalLocked[account];
    }

    /**
     * @dev Stake tokens to earn rewards
     * @param amount Amount to stake
     */
    function stake(uint256 amount) external onlyActive {
        require(amount > 0, "Amount must be positive");
        require(unlockedBalanceOf(msg.sender) >= amount, "Insufficient unlocked balance");

        _claimRewards(msg.sender); // Claim any pending rewards first

        stakes[msg.sender].amount += amount;
        stakes[msg.sender].startTime = block.timestamp;
        if (stakes[msg.sender].lastClaim == 0) {
            stakes[msg.sender].lastClaim = block.timestamp;
        }
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    /**
     * @dev Unstake tokens
     * @param amount Amount to unstake
     */
    function unstake(uint256 amount) external onlyActive {
        require(amount > 0, "Amount must be positive");
        require(stakes[msg.sender].amount >= amount, "Insufficient staked amount");

        _claimRewards(msg.sender); // Claim rewards before unstaking

        stakes[msg.sender].amount -= amount;
        totalStaked -= amount;

        emit Unstaked(msg.sender, amount);
    }

    /**
     * @dev Claim staking rewards
     */
    function claimRewards() external onlyActive {
        uint256 rewards = _calculateRewards(msg.sender);
        require(rewards > 0, "No rewards available");

        stakes[msg.sender].lastClaim = block.timestamp;
        _mint(msg.sender, rewards);

        emit RewardsClaimed(msg.sender, rewards);
    }

    /**
     * @dev Internal function to claim rewards
     */
    function _claimRewards(address user) internal {
        uint256 rewards = _calculateRewards(user);
        if (rewards > 0) {
            stakes[user].lastClaim = block.timestamp;
            _mint(user, rewards);
            emit RewardsClaimed(user, rewards);
        }
    }

    /**
     * @dev Calculate pending rewards for a user
     */
    function _calculateRewards(address user) internal view returns (uint256) {
        if (stakes[user].amount == 0 || stakes[user].lastClaim == 0) return 0;

        uint256 timeStaked = block.timestamp - stakes[user].lastClaim;
        // Simple reward calculation: amount * rewardRate * time / 1e18 / 86400 (per day)
        return (stakes[user].amount * rewardRate * timeStaked) / (1e18 * 86400);
    }

    /**
     * @dev Get pending rewards for a user
     */
    function getPendingRewards(address user) external view returns (uint256) {
        return _calculateRewards(user);
    }

    /**
     * @dev Set treasury address (only admin)
     */
    function setTreasury(address _treasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = _treasury;
    }

    /**
     * @dev Transfer tokens to treasury
     * @param amount Amount to transfer
     */
    function transferToTreasury(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(balanceOf(address(this)) >= amount, "Insufficient contract balance");
        _transfer(address(this), treasury, amount);
    }

    /**
     * @dev Get treasury balance
     */
    function treasuryBalance() external view returns (uint256) {
        return balanceOf(treasury);
    }
    
    // Override ERC-20 functions to emit our events and check locks
    function transfer(address to, uint256 amount) public override onlyActive returns (bool) {
        require(unlockedBalanceOf(msg.sender) >= amount, "Insufficient unlocked balance");
        bool success = super.transfer(to, amount);
        if (success) {
            emit TokenTransferred(msg.sender, to, amount, block.number);
        }
        return success;
    }
    
    function approve(address spender, uint256 amount) public override onlyActive returns (bool) {
        bool success = super.approve(spender, amount);
        return success;
    }
}