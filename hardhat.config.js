/**
 * Hardhat configuration for Space Infrastructure Token project
 */

require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
        blockNumber: 20000000
      },
      accounts: {
        count: 10,
        balance: 10000000000000000000 // 10 ETH each
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    testnet: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_KEY}`,
      accounts: {
        mnemonic: process.env.MNEMONIC || "test test test test test test test test test test test junk"
      }
    }
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
    migrations: "./migrations"
  },
  mocha: {
    timeout: 100000
  }
};