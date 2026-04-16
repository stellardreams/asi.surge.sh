const { expect } = require("chai");

describe("TestToken", function () {
  let TestToken, token, owner, addr1;

  beforeEach(async function () {
    TestToken = await ethers.getContractFactory("TestToken");
    [owner, addr1] = await ethers.getSigners();
    token = await TestToken.deploy();
    await token.waitForDeployment();
  });

  it("Should have correct name and symbol", async function () {
    expect(await token.name()).to.equal("TestToken");
    expect(await token.symbol()).to.equal("TEST");
  });

  it("Should mint initial supply to deployer", async function () {
    const initialSupply = 10000000000n * 10n**18n;
    expect(await token.totalSupply()).to.equal(initialSupply);
    expect(await token.balanceOf(owner.address)).to.equal(initialSupply);
  });

  it("Should allow transfers", async function () {
    const amount = 1000000000000000000n; // 1 token
    await token.transfer(addr1.address, amount);
    expect(await token.balanceOf(addr1.address)).to.equal(amount);
  });
});