// SPDX-License-Identifier: MIT
/*
 * SpaceInfrastructureToken.sol
 * 
 * This contract is named after Vitalik Buterin, Brian Armstrong, and Chris Lewicki
 * to acknowledge their significant contributions to technology, decentralized systems,
 * and space exploration. Their collective work has inspired this effort to create a
 * decentralized ownership model for space infrastructure, enabling safer and more
 * secure exploration and development of outer space while helping to equip ownership for space infrastructure (or infrastructure in outer space)
 * for as many humans as possible.
 * their work will help enable wholesome and sustainable prosperity for many generations to come. Perhaps indefinitely. Thank you sincerely for all of your contributions. 
 * 
 * Requestor: @genidma
 * Lead Developer: KiloAI via Trinity Large Thinking Model via Arcee AI
 * Original Implementation: KiloAI with Trinity Large Thinking Model via Arcee AI
 * Created: 2026-04-11T00:06:20-04:00
 * 
 * This code is for prototyping and requires security audit before production use.
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
     * @title Space Infrastructure Ownership Token
     * @dev A governance token for collective ownership of space infrastructure
     */
    abstract contract SpaceInfrastructureToken is Ownable, Pausable {
        struct OwnershipUnit {
            address owner;
            uint256 shares;
            bool active;
            uint256 blockNumber;
        }
        
        struct Proposal {
            uint256 proposalId;
            address proposer;
            string description;
            uint256 targetShares;
            uint256 forVotes;
            uint256 againstVotes;
            bool executed;
            uint256 deadline;
        }
        
        // Events
        event OwnershipTransferred(address indexed from, address indexed to, uint256 shares, uint256 timestamp);
        event NewParticipant(address indexed participant, uint256 initialShares, uint256 timestamp);
        event ShareConsolidated(address indexed participant, uint256 oldShares, uint256 newShares, uint256 timestamp);
        event ProposalCreated(uint256 proposalId, address indexed proposer, string description, uint256 targetShares);
        event VoteCast(address indexed voter, uint256 proposalId, bool support, uint256 shares, uint256 timestamp);
        event ProposalExecuted(uint256 proposalId, bool passed);

        
        // State
        mapping(address => OwnershipUnit[]) public ownershipRegistry;
        uint256 public totalShares;
        uint256 public nextProposalId;
        mapping(uint256 => Proposal) public proposals;
        mapping(uint256 => mapping(address => bool)) public hasVoted;
        
// Configuration
uint256 public constant SHARE_DECIMALS = 10 ** 18;
uint256 public constant PROPOSAL_DURATION_BLOCKS = 1000; // ~4 hours at 15s blocks
uint256 public constant QUORUM_PERCENTAGE = 20; // 20% of total shares must participate
uint256 public constant MIN_PROPOSAL_SHARES = 1000; // Minimum shares required to create proposal

// Modifiers
modifier onlyActive() {
    require(!paused(), "Contract is paused");
    _;
}

modifier onlyOwnerOrProposer(uint256 proposalId) {
    require(msg.sender == owner() || msg.sender == proposals[proposalId].proposer, "Not authorized");
    _;
}
    
    /**
     * @dev Constructor - deployer gets initial shares
     */
    constructor() {
        ownershipRegistry[msg.sender].push(OwnershipUnit({
            owner: msg.sender,
            shares: 100000 * SHARE_DECIMALS,
            active: true,
            blockNumber: block.number
        }));
        totalShares = 100000 * SHARE_DECIMALS;
        emit OwnershipTransferred(address(0), msg.sender, 100000 * SHARE_DECIMALS, block.number);
    }
    
    /**
     * @dev Transfer ownership shares from one address to another
     * @param from Source address
     * @param to Destination address
     * @param shares Amount of shares to transfer
     */
    function transferOwnership(address from, address to, uint256 shares) external onlyActive returns (bool) {
        require(from != to, "Cannot transfer to self");
        require(from != address(0) && to != address(0), "Invalid address");
        require(shares > 0, "Shares must be positive");
        
        // Get sender's total shares
        uint256 senderTotal = getVoterShares(from);
        require(senderTotal >= shares, "Insufficient shares");
        
        // Remove shares from sender - handle multiple entries
        uint256 remaining = shares;
        uint256 index = 0;
        while (remaining > 0 && index < ownershipRegistry[from].length) {
            OwnershipUnit storage entry = ownershipRegistry[from][index];
            if (entry.active && entry.shares >= remaining) {
                entry.shares -= remaining;
                uint256 transferred = remaining;
                remaining = 0;
                if (entry.shares == 0) {
                    entry.active = false;
                }
                index++;
            } else if (entry.active) {
                remaining -= entry.shares;
                entry.active = false;
                index++;
            } else {
                index++;
            }
        }
        
        // Add shares to receiver
        bool foundActive = false;
        for (uint256 i = 0; i < ownershipRegistry[to].length; i++) {
            OwnershipUnit storage entry = ownershipRegistry[to][i];
            if (entry.active) {
                entry.shares += shares;
                foundActive = true;
                break;
            }
        }
        
        // If receiver has no active entry, create new one
        if (!foundActive) {
            ownershipRegistry[to].push(OwnershipUnit({
                owner: to,
                shares: shares,
                active: true,
                blockNumber: block.number
            }));
            emit NewParticipant(to, shares, block.number);
        }
        
        emit OwnershipTransferred(from, to, shares, block.number);
        return true;
    }
    
    /**
     * @dev Create a new governance proposal
     * @param description Proposal description
     * @param targetShares Minimum shares required to pass
     * @return proposalId
     */
    function createProposal(string memory description, uint256 targetShares) external onlyActive virtual returns (uint256) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(targetShares > 0, "Target shares must be positive");
        require(msg.sender != address(0), "Invalid sender");
        require(targetShares >= MIN_PROPOSAL_SHARES, "Insufficient proposal shares");
        require(getVoterShares(msg.sender) >= targetShares, "Sender does not have enough shares");
        
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
        
        emit ProposalCreated(proposalId, msg.sender, description, targetShares);
        return proposalId;
    }
    
    /**
     * @dev Cast vote on a proposal
     * @param proposalId Proposal identifier
     * @param support Vote in favor (true) or against (false)
     */
    function vote(uint256 proposalId, bool support) external onlyActive virtual {
        Proposal storage p = proposals[proposalId];
        require(block.number <= p.deadline, "Voting period ended"); // Fixed: voting open during deadline
        require(!p.executed, "Proposal already executed");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        uint256 voterShares = getVoterShares(msg.sender);
        require(voterShares > 0, "No voting shares");
        
        if (support) {
            p.forVotes += voterShares;
        } else {
            p.againstVotes += voterShares;
        }
        
        hasVoted[proposalId][msg.sender] = true;
        emit VoteCast(msg.sender, proposalId, support, voterShares, block.number);
    }
    
    /**
     * @dev Execute a proposal if it passes
     * @param proposalId Proposal identifier
     */
    function executeProposal(uint256 proposalId) external onlyOwnerOrProposer(proposalId) virtual {
        Proposal storage p = proposals[proposalId];
        require(!p.executed, "Proposal already executed");
        require(block.number > p.deadline, "Deadline not reached");
        
        uint256 totalVotes = p.forVotes + p.againstVotes;
        uint256 totalShares = getTotalShares();
        uint256 quorumShares = (totalShares * QUORUM_PERCENTAGE) / 100;
        
        // Check quorum
        if (totalVotes < quorumShares) {
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
    
    /**
     * @dev Get total shares for an address
     */
    function getVoterShares(address voter) public view returns (uint256) {
        uint256 shares = 0;
        for (uint256 i = 0; i < ownershipRegistry[voter].length; i++) {
            OwnershipUnit storage entry = ownershipRegistry[voter][i];
            if (entry.active) {
                shares += entry.shares;
            }
        }
        return shares;
    }
    
    /**
     * @dev Get total shares in circulation (cached)
     */
    function getTotalShares() public view returns (uint256) {
        return totalShares;
    }
    
    /**
     * @dev Pause all operations in case of emergency
     */
    function pauseContract() public onlyOwner virtual {
        _pause();
        emit Paused(msg.sender);
    }
    
    /**
     * @dev Unpause operations
     */
    function unpauseContract() public onlyOwner virtual {
        _unpause();
        emit Unpaused(msg.sender);
    }
}