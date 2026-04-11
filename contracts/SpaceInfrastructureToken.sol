// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Space Infrastructure Ownership Token
 * @dev A governance token for collective ownership of space infrastructure
 */
contract SpaceInfrastructureToken {
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
    
    mapping(address => OwnershipUnit[]) public ownershipRegistry;
    uint256 public totalShares;
    uint256 public nextProposalId;
    
    event OwnershipTransferred(address indexed from, address indexed to, uint256 shares);
    event ProposalCreated(uint256 proposalId, address proposer, string description);
    event VoteCast(address indexed voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 proposalId);
    
    /**
     * @dev Transfer ownership shares from one address to another
     */
    function transferOwnership(address from, address to, uint256 shares) public {
        require(ownershipRegistry[from].length > 0, "No ownership found");
        
        // Update from balance
        for (uint256 i = 0; i < ownershipRegistry[from].length; i++) {
            if (ownershipRegistry[from][i].owner == from && ownershipRegistry[from][i].active) {
                require(ownershipRegistry[from][i].shares >= shares, "Insufficient shares");
                ownershipRegistry[from][i].shares -= shares;
                
                // Update to balance
                bool found = false;
                for (uint256 j = 0; j < ownershipRegistry[to].length; j++) {
                    if (ownershipRegistry[to][j].owner == to && ownershipRegistry[to][j].active) {
                        ownershipRegistry[to][j].shares += shares;
                        found = true;
                        break;
                    }
                }
                
                if (!found) {
                    ownershipRegistry[to].push(OwnershipUnit({
                        owner: to,
                        shares: shares,
                        active: true,
                        blockNumber: block.number
                    }));
                }
                
                emit OwnershipTransferred(from, to, shares);
                break;
            }
        }
    }
    
    /**
     * @dev Create a new governance proposal
     */
    function createProposal(string memory description, uint256 targetShares) public returns (uint256) {
        uint256 proposalId = nextProposalId++;
        proposals[proposalId] = Proposal({
            proposalId: proposalId,
            proposer: msg.sender,
            description: description,
            targetShares: targetShares,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            deadline: block.number + 100 // 100 blocks to vote
        });
        
        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }
    
    /**
     * @dev Cast vote on a proposal
     */
    function vote(uint256 proposalId, bool support) public {
        require(proposals[proposalId].deadline > block.number, "Voting closed");
        require(!proposals[proposalId].executed, "Proposal already executed");
        
        uint256 voterShares = getVoterShares(msg.sender);
        require(voterShares > 0, "No voting shares");
        
        if (support) {
            proposals[proposalId].forVotes += voterShares;
        } else {
            proposals[proposalId].againstVotes += voterShares;
        }
        
        emit VoteCast(msg.sender, proposalId, support);
    }
    
    /**
     * @dev Execute a proposal if it passes
     */
    function executeProposal(uint256 proposalId) public {
        Proposal storage p = proposals[proposalId];
        require(block.number > p.deadline, "Voting still open");
        require(!p.executed, "Proposal already executed");
        
        uint256 totalShares = getTotalShares();
        uint256 supportThreshold = totalShares * 50 / 100; // 50% needed
        
        if (p.forVotes >= supportThreshold) {
            // Execute the proposal
            p.executed = true;
            emit ProposalExecuted(proposalId);
        }
    }
    
    /**
     * @dev Get total shares for an address
     */
    function getVoterShares(address voter) public view returns (uint256) {
        uint256 shares = 0;
        for (uint256 i = 0; i < ownershipRegistry[voter].length; i++) {
            if (ownershipRegistry[voter][i].active) {
                shares += ownershipRegistry[voter][i].shares;
            }
        }
        return shares;
    }
    
    /**
     * @dev Get total shares in circulation
     */
    function getTotalShares() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < ownershipRegistry.length; i++) {
            for (uint256 j = 0; j < ownershipRegistry[i].length; j++) {
                if (ownershipRegistry[i][j].active) {
                    total += ownershipRegistry[i][j].shares;
                }
            }
        }
        return total;
    }
}