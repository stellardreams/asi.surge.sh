#!/usr/bin/env python3
"""
Resource Allocation and Dividend Distribution System
For collective ownership of space infrastructure
"""
import json
import time
from datetime import datetime
from typing import Dict, List, Tuple
from collections import defaultdict

class ResourceAllocator:
    def __init__(self, config_path: str = "config/resources.json"):
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        self.participants = self.load_participants()
        self.blockchain = self.initialize_blockchain()
        self.supply_chain = self.initialize_supply_chain()
        
    def load_participants(self) -> Dict:
        """Load participant data with ownership shares"""
        try:
            with open('data/participants.json', 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"participants": []}
    
    def initialize_blockchain(self):
        """Initialize connection to blockchain for dividend distribution"""
        # Simplified - in reality this would connect to Ethereum/Polygon/etc.
        print("Initializing blockchain connection...")
        return {"connected": True}
    
    def initialize_supply_chain(self):
        """Initialize supply chain tracking for resource allocation"""
        print("Initializing supply chain tracking...")
        return {"tracking_active": True}
    
    def calculate_shares(self) -> Dict[str, float]:
        """Calculate each participant's share of ownership"""
        shares = defaultdict(float)
        for participant in self.participants.get("participants", []):
            shares[participant["address"]] += participant.get("shares", 0)
        return dict(shares)
    
    def allocate_resources(self, resources: Dict) -> Dict:
        """
        Allocate resources based on ownership shares
        @param resources: Dictionary of resources to allocate
        @return: Allocation results
        """
        total_shares = sum(self.calculate_shares().values())
        if total_shares == 0:
            return {"error": "No active participants"}
        
        allocation = {}
        for resource, quantity in resources.items():
            # Distribute proportionally to ownership shares
            for address, shares in self.calculate_shares().items():
                if address not in allocation:
                    allocation[address] = {}
                allocation[address][resource] = (quantity * shares) / total_shares
        
        return allocation
    
    def distribute_dividends(self, profits: float) -> Dict:
        """
        Distribute dividends to participants based on ownership
        @param profits: Total profits to distribute
        @return: Distribution results with blockchain transaction IDs
        """
        shares = self.calculate_shares()
        total_shares = sum(shares.values())
        
        if total_shares == 0:
            return {"error": "No participants to distribute dividends"}
        
        distribution = {}
        transactions = []
        
        for address, shares in shares.items():
            amount = (profits * shares) / total_shares
            if amount > 0:
                # In reality, this would send a blockchain transaction
                tx_id = self.send_blockchain_transaction(address, amount)
                distribution[address] = {
                    "amount": amount,
                    "tx_id": tx_id,
                    "timestamp": datetime.now().isoformat()
                }
                transactions.append(distribution[address])
        
        # Log distribution event
        self.log_distribution(transactions, profits)
        
        return {
            "total_distributed": profits,
            "transactions": transactions,
            "timestamp": datetime.now().isoformat()
        }
    
    def send_blockchain_transaction(self, to_address: str, amount: float) -> str:
        """Simulate sending a blockchain transaction"""
        # In production, this would interact with a blockchain network
        tx_id = f"0x{int(time.time()):x}{hash(to_address):x}"
        print(f"Sending {amount} to {to_address} with tx_id: {tx_id}")
        return tx_id
    
    def log_distribution(self, transactions: List, total: float):
        """Log dividend distribution event"""
        log_entry = {
            "event": "dividend_distribution",
            "timestamp": datetime.now().isoformat(),
            "total": total,
            "transactions": transactions
        }
        print(f"Distribution logged: {json.dumps(log_entry, indent=2)}")
    
    def generate_report(self) -> str:
        """Generate a report of current allocations and distributions"""
        report = f"""
        === Space Infrastructure Resource Allocation Report ===
        Generated: {datetime.now()}
        
        Total Participants: {len(self.participants.get('participants', []))}
        Total Shares: {sum(self.calculate_shares().values())}
        
        Recent Distributions:
        """
        # Would list recent distributions in production
        report += "\nNo recent distributions found.\n"
        return report

def main():
    allocator = ResourceAllocator()
    
    # Example usage
    resources = {
        "titanium": 1000,
        "aluminum": 2500,
        "oxygen": 5000,
        "water": 3000
    }
    
    allocation = allocator.allocate_resources(resources)
    print(f"Resource allocation results:\n{json.dumps(allocation, indent=2)}")
    
    # Simulate profit distribution
    if allocation:
        profits = 10000.0
        distribution = allocator.distribute_dividends(profits)
        print(f"Dividend distribution results:\n{json.dumps(distribution, indent=2)}")
    
    # Generate report
    print(allocator.generate_report())

if __name__ == "__main__":
    main()