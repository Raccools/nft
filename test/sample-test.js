const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Raccools", function () {
  it("Should return the token metadata", async function () {
    const Wardrobe = await ethers.getContractFactory("Wardrobe");
    const wardrobe = await Wardrobe.deploy();
    await wardrobe.deployed();

    const Raccools = await ethers.getContractFactory("Raccools");
    const raccools = await Raccools.deploy(wardrobe.address);
    await raccools.deployed();

    //expect(await raccools.tokenURI(2)).to.equal("data:application/json;base64,");
  });
});
