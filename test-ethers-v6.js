import { ethers } from "ethers";

console.log("Testing ethers v6 compatibility...");

// Test basic ethers functionality
console.log("Ethers version:", ethers.version);

// Test parseEther
const oneEther = ethers.parseEther("1");
console.log("1 ether in wei:", oneEther.toString());

// Test formatEther
const formatted = ethers.formatEther(oneEther);
console.log("Formatted back:", formatted);

// Test BigInt math
const twoEther = ethers.parseEther("2");
const threeEther = oneEther + twoEther;
console.log("1 + 2 =", ethers.formatEther(threeEther), "ether");

console.log("✅ Ethers v6 is working correctly!");