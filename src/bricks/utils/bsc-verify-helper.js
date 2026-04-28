/**
 * BSCScan Contract Verification Helper
 * 
 * Generates verification commands and instructions for verifying
 * smart contracts on BSC Testnet via BSCScan.
 * 
 * @example
 * ```javascript
 * const verificationInfo = generateBscVerification('0x123...');
 * console.log(verificationInfo.steps);
 * ```
 */

/**
 * Generates BSCScan verification instructions for a contract
 * 
 * @param {string} contractAddress - Deployed contract address on BSC Testnet
 * @param {string} [contractName='TestToken'] - Name of the contract
 * @returns {Object} Verification information including steps and commands
 * @throws {Error} If contract address is not provided
 * 
 * @example
 * ```javascript
 * const info = generateBscVerification('0x123...', 'TestToken');
 * console.log(info.verificationUrl);
 * ```
 */
export function generateBscVerification(contractAddress, contractName = 'TestToken') {
  if (!contractAddress) {
    throw new Error('Contract address is required for verification');
  }

  const bscScanUrl = 'https://testnet.bscscan.com';
  const compilerVersion = 'v0.8.20+commit.a1b79de6';
  const license = 'MIT';

  return {
    contractAddress,
    contractName,
    network: 'BSC Testnet',
    verificationUrl: `${bscScanUrl}/verifyContract`,
    contractUrl: `${bscScanUrl}/address/${contractAddress}`,
    compilerVersion,
    license,
    steps: [
      `1. Go to: ${bscScanUrl}/verifyContract`,
      '2. Select "Solidity (Single File)"',
      '3. Fill in:',
      `   - Contract Address: ${contractAddress}`,
      `   - Compiler: ${compilerVersion}`,
      `   - License: ${license}`,
      '4. Copy and paste the contract source code',
      '5. Click "Verify and Publish"',
      '6. Wait for verification (usually 1-2 minutes)'
    ],
    getInstructions() {
      return this.steps.join('\n');
    }
  };
}

/**
 * Displays formatted verification instructions to console
 * 
 * @param {string} contractAddress - Deployed contract address
 * @param {string} [contractName='TestToken'] - Contract name
 * 
 * @example
 * ```javascript
 * displayBscVerification('0x123...', 'TestToken');
 * ```
 */
export function displayBscVerification(contractAddress, contractName = 'TestToken') {
  const info = generateBscVerification(contractAddress, contractName);
  
  console.log("🔍 BSC Testnet Contract Verification");
  console.log("=".repeat(50));
  console.log(`Contract: ${info.contractName}`);
  console.log(`Address: ${info.contractAddress}`);
  console.log(`Network: ${info.network}`);
  console.log(`Explorer: ${info.contractUrl}`);
  console.log();
  
  console.log("📋 Verification Steps:");
  info.steps.forEach(step => console.log(step));
  console.log();
  
  console.log("💡 Tips:");
  console.log("- Ensure constructor arguments are correct");
  console.log("- Check "Optimization" was enabled during compilation");
  console.log("- Verify license matches your contract");
  console.log("- If verification fails, check for minor differences in source");
}

/**
 * Validates a BSC Testnet contract address format
 * 
 * @param {string} address - Address to validate
 * @returns {boolean} True if valid BSC address format
 * 
 * @example
 * ```javascript
 * isValidBscAddress('0x123...'); // true
 * isValidBscAddress('invalid'); // false
 * ```
 */
export function isValidBscAddress(address) {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}
