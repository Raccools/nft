const { expect } = require("chai")
const { ethers, waffle } = require("hardhat")
const Web3 = require('web3')

const provider = waffle.provider
const web3 = new Web3(provider)

async function estimateGas(method, type, parameter, value){
  const data = web3.eth.abi.encodeFunctionSignature(`${method}(${type})`)
    + web3.eth.abi.encodeParameter(type, parameter).substring(2)

  return await provider.estimateGas({ from: owner.address, to: raccools.address, data, value })
}

beforeEach(async function () {
  [owner, addr1, addr2] = await ethers.getSigners()

  let Raccools = await ethers.getContractFactory("Raccools")
  let Wardrobe = await ethers.getContractFactory("Wardrobe")
  let wardrobe = await Wardrobe.deploy()
  await wardrobe.deployed()

  raccools = await Raccools.deploy(wardrobe.address)
  await raccools.deployed()

  _cost = await raccools._cost()
  _maxMintPerTx = await raccools._maxMintPerTx()
  _maxSupply = await raccools._maxSupply()
})

describe("mint", function() {
  it("successfully mint token id 1", async function () {
    expect(await raccools.mint(1, {value: _cost}))
    expect(await raccools.ownerOf(1)).to.equal(owner.address)
    await expect(raccools.ownerOf(0)).to.reverted
  })

  it("successfully mint max amount pet tx", async function () {
    expect(await raccools.mint(_maxMintPerTx, {value: _cost.mul(_maxMintPerTx)}))
  })

  it("reverts when amount exceeds max supply", async function () {
    await expect(raccools.mint(_maxSupply.add(1))).to.revertedWith("Cannot exceed max supply")
  })

  it("reverts when amount is greater than tx limit", async function () {
    await expect(raccools.mint(_maxMintPerTx.add(1))).to.revertedWith("Cannot exceed 20 per tx")
  })

  it("reverts when ether sent is lower than cost", async function () {
    await expect(raccools.mint(1, {value: _cost.sub(1)})).to.reverted
    await expect(raccools.mint(20, {value: _cost.mul(20).sub(1)})).to.reverted
  })

  context("gas used", function(){
    it("minting one nft costs 75,218 gas", async function(){
      expect(await estimateGas("mint", "uint256", "1", _cost)).eq(75218)
    })

    it("minting five nfts costs 83,058 gas", async function(){
      expect(await estimateGas("mint", "uint256", "5", _cost.mul(5))).eq(83058)
    })

    it("minting twenty nfts costs 112,458 gas", async function(){
      expect(await estimateGas("mint", "uint256", "20", _cost.mul(20))).eq(112458)
    })
  })
})

describe("tokenURI", function(){
  it("shows hidden metadata when not revealed", async function () {
    await raccools.mint(1, {value: _cost})

    let metadata = await raccools.tokenURI(1)
    metadata = metadata.replace("data:application/json;base64,", "")
    metadata = JSON.parse(atob(metadata))

    // validate name
    expect(metadata.name).to.equal("Raccools #1")

    // validate attributes
    expect(metadata.attributes[0].value).to.equal("?")
    expect(metadata.attributes[1].value).to.equal("?")
    expect(metadata.attributes[2].value).to.equal("?")
    expect(metadata.attributes[3].value).to.equal("?")
    expect(metadata.attributes[4].value).to.equal("?")

    let svg = metadata.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)

    // validate svg image
    expect(svg.startsWith('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0, 0, 100, 100">')).to.be.true
  })

  it("shows final metadata when revealed", async function () {
    await raccools.mint(1, {value: _cost})
    await raccools.setBaseSeed("test")

    let metadata = await raccools.tokenURI(1)
    metadata = metadata.replace("data:application/json;base64,", "")
    metadata = JSON.parse(atob(metadata))

    // validate name
    expect(metadata.name).to.equal("Raccools #1")

    // validate attributes
    expect(metadata.attributes[0].value) != "?"
    expect(metadata.attributes[1].value) != "?"
    expect(metadata.attributes[2].value) != "?"
    expect(metadata.attributes[3].value) != "?"
    expect(metadata.attributes[4].value) != "?"

    let svg = metadata.image
    svg = svg.replace("data:image/svg+xml;base64,", "")
    svg = atob(svg)

    // validate svg image
    expect(svg.startsWith('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0, 0, 100, 100">')).to.be.true
  })

  it("reverts when token is not minted", async function () {
    await expect(raccools.tokenURI(1)).to.be.revertedWith("Token not minted")
  })

  it("reveals metadata when base seed is set", async function () {
    expect(await raccools.isRevealed()).to.be.false
    expect(await raccools.setBaseSeed("test"))
    expect(await raccools.isRevealed()).to.be.true
  })

  context("gas used", function(){
    it("unrevealed metadata uses 721,325 gas", async function(){
      await raccools.mint(1, {value: _cost})

      expect(await estimateGas("tokenURI", "uint256", "1")).eq(721325)

    })

    it("revealed metadata uses 209,825 gas", async function(){
      await raccools.mint(1, {value: _cost})
      await raccools.setBaseSeed("test")

      expect(await estimateGas("tokenURI", "uint256", "1")).eq(209825)

    })
  })
})

describe("customize", function(){
  it("successfully removes head", async function(){
    await raccools.mint(1, {value: _cost})
    let tx = await raccools.customize(1, 1, 0)
    await expect(tx).to.emit(raccools, "HeadTransfer")

    //await expect(raccools.customize(1, 1, 0)).to.emit(raccools, "Customize")
    console.log(await tx.wait())

  })
})
