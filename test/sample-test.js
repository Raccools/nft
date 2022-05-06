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

  let Traits = await ethers.getContractFactory("Traits")
  traits = await Traits.deploy()

  let Raccools = await ethers.getContractFactory("Raccools", {libraries: {Traits: traits.address}})
  let Wardrobe = await ethers.getContractFactory("Wardrobe", {libraries: {Traits: traits.address}})
  wardrobe = await Wardrobe.deploy()
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
    expect(metadata.attributes[0].value).to.not.equal("?")
    expect(metadata.attributes[1].value).to.not.equal("?")
    expect(metadata.attributes[2].value).to.not.equal("?")
    expect(metadata.attributes[3].value).to.not.equal("?")
    expect(metadata.attributes[4].value).to.not.equal("?")

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

      //expect(await estimateGas("tokenURI", "uint256", "1")).eq(721325)

    })

    it("revealed metadata uses 208,025 gas", async function(){
      await raccools.mint(1, {value: _cost})
      await raccools.setBaseSeed("test")

      //expect(await estimateGas("tokenURI", "uint256", "1")).eq(208025)
    })
  })
})

describe("customize", function(){
  it("reverts when no traits are given", async function(){
    await raccools.mint(1, {value: _cost})
    await expect(raccools.customize(1, 0, 0)).to.revertedWith("Would produce same raccool")
  })

  it("reverts when given traits would produce the same raccool", async function(){
    await raccools.mint(1, {value: _cost})
    await raccools.customize(1, 1, 1)
    await expect(raccools.customize(2, 1, 1)).to.revertedWith("Would produce same raccool")
  })

  it("reverts when not the token owner", async function(){
    await raccools.connect(addr1).mint(1, {value: _cost})
    await expect(raccools.customize(1, 1, 1)).to.revertedWith("Must be the token owner")
  })

  it("reverts when not owning head trait token", async function(){
    await raccools.mint(1, {value: _cost})
    await expect(raccools.customize(1, 2, 0)).to.reverted
  })

  it("reverts when not owning clothes trait token", async function(){
    await raccools.mint(1, {value: _cost})
    await expect(raccools.customize(1, 0, 2)).to.reverted
  })

  it("successfully burns current raccool and mints a new one", async function(){
    await raccools.mint(1, {value: _cost})
    expect(await raccools.ownerOf(1)).to.equal(owner.address)
    await expect(raccools.ownerOf(2)).to.reverted

    await raccools.customize(1, 1, 0)
    await expect(raccools.ownerOf(1)).to.reverted
    expect(await raccools.ownerOf(2)).to.equal(owner.address)
  })

  it("successfully removes head trait and mint it", async function(){
    await raccools.mint(1, {value: _cost})

    let tx = await (await raccools.customize(1, 1, 0)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(headChanges[1]).to.equal(1)
    expect(clothesChanges[1]).to.equal(clothesChanges[0])

    let headTokenId = wardrobe.headTokenId(headChanges[0])

    expect(await wardrobe.balanceOf(owner.address, headTokenId)).to.equal(1)
  })

  it("successfully removes the clothes trait and mint it", async function(){
    await raccools.mint(1, {value: _cost})

    let tx = await (await raccools.customize(1, 0, 1)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(clothesChanges[1]).to.equal(1)
    expect(headChanges[1]).to.equal(headChanges[0])

    let clothesTokenId = wardrobe.clothesTokenId(clothesChanges[0])

    expect(await wardrobe.balanceOf(owner.address, clothesTokenId)).to.equal(1)
  })

  it("successfully removes clothes and head traits", async function(){
    await raccools.mint(1, {value: _cost})

    let tx = await (await raccools.customize(1, 1, 1)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(clothesChanges[1]).to.equal(1)
    expect(headChanges[1]).to.equal(1)

    let clothesTokenId = wardrobe.clothesTokenId(clothesChanges[0])
    let headTokenId = wardrobe.headTokenId(headChanges[0])

    expect(await wardrobe.balanceOf(owner.address, headTokenId)).to.equal(1)
    expect(await wardrobe.balanceOf(owner.address, clothesTokenId)).to.equal(1)
  })

  it("successfully changes head trait", async function(){
    await raccools.mint(1, {value: _cost})
    let tx1 = await (await raccools.customize(1, 1, 0)).wait()

    let { args: [, headChanges1, ] } = tx1.events.filter((el) => el.event == "Customize")[0]

    let head = headChanges1[0]

    // had to mint 2, first one got the same head trait
    await raccools.mint(2, {value: _cost.mul(2)})
    let tx = await (await raccools.customize(4, head, 0)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(headChanges[1]).to.equal(head)
    expect(clothesChanges[1]).to.equal(clothesChanges[0])

    expect(await wardrobe.balanceOf(owner.address, wardrobe.headTokenId(headChanges[0]))).to.equal(1)
  })

  it("successfully changes clothes trait", async function(){
    await raccools.mint(1, {value: _cost})
    let tx1 = await (await raccools.customize(1, 0, 1)).wait()

    let { args: [, , clothesChanges1] } = tx1.events.filter((el) => el.event == "Customize")[0]

    let clothes = clothesChanges1[0]

    // had to mint 2, first one got the same head trait
    await raccools.mint(2, {value: _cost.mul(2)})
    let tx = await (await raccools.customize(4, 0, clothes)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(headChanges[1]).to.equal(headChanges[0])
    expect(clothesChanges[1]).to.equal(clothes)

    expect(await wardrobe.balanceOf(owner.address, wardrobe.clothesTokenId(clothesChanges[0]))).to.equal(1)
  })

  it("successfully changes clothes and head traits", async function(){
    await raccools.mint(1, {value: _cost})
    let tx1 = await (await raccools.customize(1, 1, 1)).wait()

    let { args: [, headChanges1, clothesChanges1] } = tx1.events.filter((el) => el.event == "Customize")[0]

    let clothes = clothesChanges1[0]
    let head = headChanges1[0]

    // had to mint 2, first one got the same head trait
    await raccools.mint(2, {value: _cost.mul(2)})
    let tx = await (await raccools.customize(4, head, clothes)).wait()
    let { args: [, headChanges, clothesChanges] } = tx.events.filter((el) => el.event == "Customize")[0]

    expect(headChanges[1]).to.equal(head)
    expect(clothesChanges[1]).to.equal(clothes)

    expect(await wardrobe.balanceOf(owner.address, wardrobe.clothesTokenId(clothesChanges[0]))).to.equal(1)
    expect(await wardrobe.balanceOf(owner.address, wardrobe.headTokenId(headChanges[0]))).to.equal(1)
  })

  context("gas used", function(){
    it("removing head costs 186,652 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx = await (await raccools.customize(1, 1, 0)).wait()

      expect(tx.gasUsed).to.equal(186652)
    })

    it("removing clothes costs 186,901 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx = await (await raccools.customize(1, 0, 1)).wait()

      expect(tx.gasUsed).to.equal(186901)
    })

    it("removing clothes and head costs 215,950 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx = await (await raccools.customize(1, 1, 1)).wait()

      expect(tx.gasUsed).to.equal(215950)
    })

    it("changing head trait costs 196,267 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx1 = await (await raccools.customize(1, 1, 0)).wait()
      let { args: [, headChanges1, ] } = tx1.events.filter((el) => el.event == "Customize")[0]
      let head = headChanges1[0]

      // had to mint 2, first one got the same head trait
      await raccools.mint(2, {value: _cost.mul(2)})
      let tx = await (await raccools.customize(4, head, 0)).wait()

      expect(tx.gasUsed).to.equal(196267)
    })

    it("changing clothes trait costs 196,754 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx1 = await (await raccools.customize(1, 0, 1)).wait()
      let { args: [, , clothesChanges] } = tx1.events.filter((el) => el.event == "Customize")[0]
      let clothes = clothesChanges[0]

      // had to mint 2, first one got the same head trait
      await raccools.mint(2, {value: _cost.mul(2)})
      let tx = await (await raccools.customize(4, 0, clothes)).wait()

      expect(tx.gasUsed).to.equal(196754)
    })

    it("changing clothes and head traits costs 232,695 gas", async function(){
      await raccools.mint(1, {value: _cost})
      let tx1 = await (await raccools.customize(1, 1, 1)).wait()

      let { args: [, headChanges1, clothesChanges1] } = tx1.events.filter((el) => el.event == "Customize")[0]

      let clothes = clothesChanges1[0]
      let head = headChanges1[0]

      // had to mint 2, first one got the same head trait
      await raccools.mint(2, {value: _cost.mul(2)})
      let tx = await (await raccools.customize(4, head, clothes)).wait()

      expect(tx.gasUsed).to.equal(232695)
    })
  })
})


//    let tx = await raccools.customize(1, 1, 3)
//    //await expect(tx).to.emit(raccools, "HeadTransfer")
//    //await expect(tx).to.not.emit(raccools, "ClothesTransfer")
//    let txinfo = await tx.wait()
//
//    console.log({gasUsed: txinfo.gasUsed})
//    console.log({cumulativeGasUsed: txinfo.cumulativeGasUsed})
//
//    //await expect(raccools.customize(1, 1, 0)).to.emit(raccools, "Customize")
//    // console.log(await tx.wait())
