const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Raccools", function () {
  it("Should return the token metadata", async function () {
    const Raccools = await ethers.getContractFactory("Raccools");
    const raccools = await Raccools.deploy();
    await raccools.deployed();

    //expect(await raccools.tokenURI(2)).to.equal("data:application/json;base64,");
  });
});
