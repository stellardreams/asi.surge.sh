import hre from "hardhat";

async function main() {
  // Hardhat 3 exposes ethers on the network connection, not as a named
  // export of "hardhat". There is no `ethers` named export.
  const connection = await hre.network.connect();
  const { ethers } = connection;

  const TestToken = await ethers.getContractFactory("TestToken");
  const token = await TestToken.deploy();

  console.log("TestToken deployed to:", await token.getAddress());
  console.log("Total supply:", await token.totalSupply());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});