/**
 * Displays BSC Testnet faucet information for developers
 * 
 * Provides a curated list of BSC Testnet faucets with URLs and descriptions
 * to help developers obtain test BNB for smart contract deployment and testing.
 * 
 * @returns {Array<Object>} Array of faucet objects with name, url, and description
 * @example
 * ```javascript
 * const faucets = getBscTestnetFaucets();
 * faucets.forEach(f => console.log(f.name, f.url));
 * ```
 * 
 * @remarks
 * This is a utility function that returns static faucet data.
 * No external API calls or network requests are made.
 */
export function getBscTestnetFaucets() {
  return [
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
}

/**
 * Displays formatted faucet information to console
 * 
 * Outputs a formatted list of BSC Testnet faucets with instructions
 * for developers to obtain test BNB tokens.
 * 
 * @example
 * ```javascript
 * displayBscFaucetInfo();
 * ```
 */
export function displayBscFaucetInfo() {
  const faucets = getBscTestnetFaucets();
  
  console.log("🚰 BSC Testnet Faucets (Free test BNB)");
  console.log("=".repeat(50));
  
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
}
