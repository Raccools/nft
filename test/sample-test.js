const { expect } = require("chai")
const { ethers, waffle } = require("hardhat")

let raccoolsContract
let wardrobeContract
let owner
let addr1
let addr2

beforeEach(async function () {
  [owner, addr1, addr2] = await ethers.getSigners()

  const Raccools = await ethers.getContractFactory("Raccools")
  const Wardrobe = await ethers.getContractFactory("Wardrobe")
  wardrobe = await Wardrobe.deploy()
  await wardrobe.deployed()

  raccools = await Raccools.deploy(wardrobe.address)
  await raccools.deployed()
})

describe("mint", function() {
  it("Successfully mint token id 1", async function () {
    let _cost = await raccools._cost()

    expect(await raccools.mint(1, {value: _cost}))
    expect(await raccools.ownerOf(1)).to.equal(owner.address)
    await expect(raccools.ownerOf(0)).to.reverted
  })

  it("Successfully mint max amount", async function () {
    let _cost = await raccools._cost()

    expect(await raccools.mint(20, {value: _cost.mul(20)}))
  })

  it("Reverts when amount exceeds max supply", async function () {
    let _maxSupply = await raccools._maxSupply()

    await expect(raccools.mint(_maxSupply.add(1))).to.revertedWith("Cannot exceed max supply")
  })

  it("Reverts when amount is greater than tx limit", async function () {
    let _maxMintPerTx = await raccools._maxMintPerTx()

    await expect(raccools.mint(_maxMintPerTx.add(1))).to.revertedWith("Cannot exceed 20 per tx")
  })

  it("Reverts when ether sent is lower than cost", async function () {
    let _cost = await raccools._cost()

    await expect(raccools.mint(1, {value: _cost.sub(1)})).to.reverted
    await expect(raccools.mint(20, {value: _cost.mul(20).sub(1)})).to.reverted
  })
})

describe("tokenURI", function(){
  it("Shows hidden metadata when not revealed", async function () {
    let _cost = await raccools._cost()

    expect(await raccools.mint(1, {value: _cost}))

    let metadata = await raccools.tokenURI(1)
    metadata = metadata.replace("data:application/json;base64,", "")
    metadata = JSON.parse(atob(metadata))

    expect(metadata.name).to.equal("Raccools #1")
    expect(metadata.attributes[0].value).to.equal("?")
    expect(metadata.attributes[1].value).to.equal("?")
    expect(metadata.attributes[2].value).to.equal("?")
    expect(metadata.attributes[3].value).to.equal("?")
    expect(metadata.attributes[4].value).to.equal("?")

    let svg = metadata.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)

    expect(svg.startsWith("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0, 0, 100, 100'>")).to.be.true
  })

  it("Shows final metadata when revealed", async function () {
    let _cost = await raccools._cost()

    expect(await raccools.mint(1, {value: _cost}))
    expect(await raccools.setBaseSeed("test"))

    let metadata = await raccools.tokenURI(1)
    metadata = metadata.replace("data:application/json;base64,", "")
    metadata = JSON.parse(atob(metadata))

    expect(metadata.name).to.equal("Raccools #1")
    expect(metadata.attributes[0].value == "?").to.be.false
    expect(metadata.attributes[1].value == "?").to.be.false
    expect(metadata.attributes[2].value == "?").to.be.false
    expect(metadata.attributes[3].value == "?").to.be.false
    expect(metadata.attributes[4].value == "?").to.be.false

    let svg = metadata.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)

    expect(svg.startsWith("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0, 0, 100, 100'>")).to.be.true
  })

  it("Reverts when token is not minted", async function () {
    await expect(raccools.tokenURI(1)).to.be.revertedWith("Token not minted");
  })

  it("Reveals metadata when base seed is set", async function () {
    expect(await raccools.isRevealed()).to.be.false
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.be.true
  })

})
