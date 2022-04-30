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

describe("Initial state", function() {
  it("Token name is Raccools", async function () {
    expect(await raccools.name()).to.equal("Raccools")
  })

  it("Token symbol is RACCOOL", async function () {
    expect(await raccools.symbol()).to.equal("RACCOOL")
  })

  it("Total supply is 0", async function () {
    expect(await raccools.totalSupply()).to.equal(0)
  })

  it("Max supply is 10_000", async function () {
    expect(await raccools._maxSupply()).to.equal(10000)
  })

  it("Mint cost is 0.08 ether", async function () {
    expect(await raccools._cost()).to.equal(ethers.utils.parseEther("0.08"))
  })

  it("Max mint per tx is 20", async function () {
    expect(await raccools._maxMintPerTx()).to.equal(20)
  })

  it("Metadata is not revealed", async function () {
    expect(await raccools.isRevealed()).to.equal(false)
  })

  it("Base seed is empty", async function () {
    expect(await raccools._provenance()).to.equal('')
  })

  it("Provenance is empty", async function () {
    expect(await raccools._provenance()).to.equal('')
  })
})

describe("Minting", function() {
  it("Can mint multiple times", async function () {
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    expect(await raccools.mint(20, {value: ethers.utils.parseEther("1.6")}))
  })

  it("Cannot mint more than max supply", async function () {
    await expect(raccools.mint(10001)).to.revertedWith("Cannot exceed max supply")
  })

  it("Cannot mint 0 amount", async function () {
    await expect(raccools.mint(0)).to.reverted
  })

  it("Cannot mint more than 20 per tx", async function () {
    await expect(raccools.mint(21)).to.revertedWith("Cannot exceed 20 per tx")
  })

  it("Cannot mint paying less than 0.08 ether", async function () {
    await expect(raccools.mint(1, {value: ethers.utils.parseEther("0.07999")})).to.reverted
    await expect(raccools.mint(10, {value: ethers.utils.parseEther("0.7999")})).to.reverted
    await expect(raccools.mint(20, {value: ethers.utils.parseEther("1.4999")})).to.reverted
  })

  it("Token id starts from 1", async function () {
    expect(await raccools.mint(1, {value: ethers.utils.parseEther("0.08")}))
    await expect(raccools.ownerOf(0)).to.reverted
    expect(await raccools.ownerOf(1)).to.equal(owner.address)
  })
})

describe("Hidden metadata", function(){
  it("Metadata is not available before token is minted", async function () {
    await expect(raccools.tokenURI(1)).to.be.revertedWith("Token not minted");
    expect(await raccools.mint(1, {value: ethers.utils.parseEther("0.08")}))
    expect(await raccools.tokenURI(1));
    await expect(raccools.tokenURI(2)).to.be.revertedWith("Token not minted");
  })

  it("Metadata shows token id", async function () {
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    expect(hidden.name).to.equal("Raccools #5")
  })

  it("Metadata shows \"?\" on all traits", async function () {
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    expect(hidden.attributes[0].value).to.equal("?")
    expect(hidden.attributes[1].value).to.equal("?")
    expect(hidden.attributes[2].value).to.equal("?")
    expect(hidden.attributes[3].value).to.equal("?")
    expect(hidden.attributes[4].value).to.equal("?")
  })

  it("Metadata shows a valid svg image", async function () {
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    let svg = hidden.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)
    
    expect(svg.startsWith("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0, 0, 100, 100'>")).to.equal(true)
  })
})

describe("Revealed metadata", function(){
  it("Setting base seed reveals metadata", async function () {
    expect(await raccools.isRevealed()).to.equal(false)
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.equal(true)
  })

  it("Metadata shows token id", async function () {
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.equal(true)
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    expect(hidden.name).to.equal("Raccools #5")
  })

  it("Metadata shows all trait values", async function () {
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.equal(true)
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    expect(hidden.attributes[0].value).to.equal("?")
    expect(hidden.attributes[1].value).to.equal("?")
    expect(hidden.attributes[2].value).to.equal("?")
    expect(hidden.attributes[3].value).to.equal("?")
    expect(hidden.attributes[4].value).to.equal("?")
  })

  it("Metadata shows a valid svg image", async function () {
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.equal(true)
    expect(await raccools.mint(10, {value: ethers.utils.parseEther("0.8")}))
    let hidden = await raccools.tokenURI(5)
    hidden = hidden.replace("data:application/json;base64,", "")
    hidden = JSON.parse(atob(hidden))

    let svg = hidden.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)
    
    expect(svg.startsWith("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0, 0, 100, 100'>")).to.equal(true)
  })
})
