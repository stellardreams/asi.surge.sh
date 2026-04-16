// BSC Testnet deployment script for TestToken
// Usage: npx hardhat run scripts/deploy-testtoken-bsc.js --network bscTestnet

import pkg from "hardhat";
const { ethers } = pkg;

async function main() {
  console.log("🚀 Deploying TestToken to BSC Testnet...");

  // Get deployer
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  console.log("Account balance:", (await ethers.provider.getBalance(deployer.address)).toString());

  // Deploy contract
  const TestToken = await ethers.getContractFactory("TestToken");
  const token = await TestToken.deploy();

  console.log("⏳ Waiting for deployment...");
  await token.waitForDeployment();

  const tokenAddress = await token.getAddress();
  console.log("✅ TestToken deployed to:", tokenAddress);
  console.log("🔗 BSC Testnet Explorer:", `https://testnet.bscscan.com/address/${tokenAddress}`);

  // Verify contract details
  console.log("\n📋 Contract Details:");
  console.log("Name:", await token.name());
  console.log("Symbol:", await token.symbol());
  console.log("Total Supply:", (await token.totalSupply()).toString());
  console.log("Deployer Balance:", (await token.balanceOf(deployer.address)).toString());

  console.log("\n🔍 Next steps:");
  console.log("1. Verify contract on BSCScan: https://testnet.bscscan.com/verifyContract");
  console.log("2. Add to MetaMask: Use contract address above");
  console.log("3. Test transfers and trading");

  return tokenAddress;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });