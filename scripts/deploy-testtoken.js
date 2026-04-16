import { ethers } from "hardhat";

async function main() {
  const TestToken = await ethers.getContractFactory("TestToken");
  const token = await TestToken.deploy();
  
  console.log("TestToken deployed to:", await token.getAddress());
  console.log("Total supply:", await token.totalSupply());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});