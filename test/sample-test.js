const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("Raccools", function () {
  it("Should return the token metadata", async function () {
    const Wardrobe = await ethers.getContractFactory("Wardrobe");
    const wardrobe = await Wardrobe.deploy();
    await wardrobe.deployed();

    const Raccools = await ethers.getContractFactory("Raccools");
    const raccools = await Raccools.deploy(wardrobe.address);
    await raccools.deployed();

    const [owner] = await ethers.getSigners();
    const provider = waffle.provider;

    // console.log(await provider.getBalance(owner.address));
    // await raccools.mint(2, {value: ethers.utils.parseEther("0.08")})
    // console.log(await provider.getBalance(owner.address));

    await expect(raccools.tokenURI(1)).to.be.revertedWith("Token not minted");
    await expect(raccools.mint(1)).to.be.reverted;
    //await expect(raccools.connect(owner).mint(1, {value: 1})).to.be.revertedWith("Insufficient funds");
  });
});
