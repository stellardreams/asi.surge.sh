/**
 * Hardhat configuration for Space Infrastructure Token project
 */

import "@nomicfoundation/hardhat-toolbox";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
export default {
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: {
        count: 10,
        balance: 10000000000000000000 // 10 ETH each
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545"
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