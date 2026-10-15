import { defineConfig } from "hardhat/config";
import hardhatEthers from "@nomicfoundation/hardhat-ethers";

// BSC Testnet. Chain ID 97. The default public RPC is used only when
// BSC_TESTNET_RPC_URL is unset; override it for reliability or for a
// dedicated endpoint. Never commit a private key: PRIVATE_KEY is read
// from the environment so it stays out of version control.
const rpcUrl =
  process.env.BSC_TESTNET_RPC_URL ??
  "https://data-seed-prebsc-1-s1.bnbchain.org:8545/";

const accounts = process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [];

export default defineConfig({
  solidity: "0.8.20",

  // hardhat-ethers must be registered as a plugin. In Hardhat 3 the
  // runtime environment no longer exposes `ethers` unless a plugin
  // provides it, so scripts that read it off the HRE would otherwise
  // get undefined.
  plugins: [hardhatEthers],

  networks: {
    bscTestnet: {
      type: "http",
      // BSC is EVM-compatible but is neither an Ethereum L1 nor an
      // Optimism-style L2. Hardhat 3 supports only "generic", "l1" and
      // "op", so "generic" is the correct choice: it applies standard
      // EVM semantics without imposing Ethereum mainnet block gas or
      // base fee assumptions.
      chainType: "generic",
      chainId: 97,
      url: rpcUrl,
      // Empty when PRIVATE_KEY is unset so that read-only commands and
      // `hardhat compile` still work without a deployment key.
      accounts,
    },
  },
});
