// BSCScan Contract Verification Helper
// Generates verification command for BSC Testnet

import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const contractAddress = process.argv[2];

if (!contractAddress) {
  console.log("Usage: node scripts/verify-bsc.js <contract-address>");
  console.log("Example: node scripts/verify-bsc.js 0x1234567890123456789012345678901234567890");
  process.exit(1);
}

console.log("🔍 BSC Testnet Contract Verification");
console.log("=".repeat(50));
console.log(`Contract Address: ${contractAddress}`);
console.log();

// Read contract source
try {
  const contractSource = readFileSync(join(__dirname, '../contracts/testtoken/TestToken.sol'), 'utf8');

  console.log("📋 Verification Steps:");
  console.log("1. Go to: https://testnet.bscscan.com/verifyContract");
  console.log("2. Select 'Solidity (Single File)'");
  console.log("3. Fill in:");
  console.log(`   - Contract Address: ${contractAddress}`);
  console.log("   - Compiler: v0.8.20+commit.a1b79de6");
  console.log("   - License: MIT");
  console.log("4. Copy the contract source below:");
  console.log();

  console.log("// TestToken.sol");
  console.log("-".repeat(20));
  console.log(contractSource);

  console.log("\n5. Click 'Verify and Publish'");
  console.log("6. Wait for verification (usually 1-2 minutes)");

} catch (error) {
  console.error("❌ Error reading contract file:", error.message);
}