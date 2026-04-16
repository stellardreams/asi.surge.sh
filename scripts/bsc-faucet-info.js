// BSC Testnet Faucet Helper
// Lists popular BSC Testnet faucets for getting test BNB

console.log("🚰 BSC Testnet Faucets (Free test BNB)");
console.log("=".repeat(50));

const faucets = [
  {
    name: "BSC Faucet",
    url: "https://testnet.bnbchain.org/faucet-smart",
    description: "Official BSC faucet - requires account setup"
  },
  {
    name: "FaucetHub",
    url: "https://faucethub.io/faucets/binance-smart-chain-testnet/",
    description: "Multiple claims, various amounts"
  },
  {
    name: "FreeBNB",
    url: "https://freebnb.vercel.app/",
    description: "Quick claims, no signup required"
  },
  {
    name: "BNB Chain Testnet Faucet",
    url: "https://testnet.binance.org/faucet-smart",
    description: "Direct from BNB Chain"
  }
];

faucets.forEach((faucet, index) => {
  console.log(`${index + 1}. ${faucet.name}`);
  console.log(`   📍 ${faucet.url}`);
  console.log(`   ℹ️  ${faucet.description}`);
  console.log();
});

console.log("📝 Instructions:");
console.log("1. Visit one of the faucets above");
console.log("2. Connect your MetaMask wallet");
console.log("3. Request test BNB (paste your wallet address)");
console.log("4. Wait a few minutes for the transaction");
console.log("5. Check BSC Testnet explorer: https://testnet.bscscan.com/");

console.log("\n💡 Tips:");
console.log("- BSC Testnet Chain ID: 97");
console.log("- Add BSC Testnet RPC: https://data-seed-prebsc-1-s1.bnbchain.org:8545/");
console.log("- Gas price: ~20 gwei");
console.log("- Block time: ~3 seconds");