// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Strings.sol';
import "./libraries/Base64.sol";
import "./libraries/Traits.sol";
import "./interfaces/IWardrobe.sol";
import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools {
  using Strings for uint256;

  // global random seed
  string public _baseSeed;
  string public _provenance;

  // generator rarities
  uint256[4] private _backgroundRarities = [5, 5];
  uint256[4] private _furRarities = [5, 5];
  uint256[4] private _faceRarities = [5, 5];
  uint256[4] private _headRarities = [0, 0, 5, 5];
  uint256[4] private _clothesRarities = [0, 0, 5, 5];

  mapping(uint256 => uint256) _customHead;
  mapping(uint256 => uint256) _customClothes;

  struct Raccool {
    string[2] background;
    string[2] fur;
    string[2] face;
    string[2] head;
    string[2] clothes;
  }

  constructor(){
    Raccool memory rac = getRaccool(6965);

    console.log(rac.background[0]);
    console.log(rac.fur[0]);
    console.log(rac.face[0]);
    console.log(rac.head[0]);
    console.log(rac.clothes[0]);
  }

  function background(uint256 backgroundIndex_) private pure returns(string[2] memory){
    return Traits.backgrounds()[backgroundIndex_];
  }

  function fur(uint256 furIndex_) private pure returns(string[2] memory){
    return Traits.furs()[furIndex_];
  }

  function face(uint256 faceIndex_) private pure returns(string[2] memory){
    return Traits.faces()[faceIndex_];
  }

  function head(uint256 headIndex_) private pure returns(string[2] memory){
    return Traits.heads()[headIndex_];
  }

  function clothes(uint256 clothesIndex_) private pure returns(string[2] memory){
    return Traits.clothes()[clothesIndex_];
  }

  // TODO
  function customize(uint256 tokenId_, uint256 head_, uint256 clothes_) external {
    IWardrobe wardrobe = IWardrobe(0xf7C08eD8430dCA5BAD72aB86906059BdEdAF5Dc4); 

    // require(msg.sender == ownerOf(tokenId_));

    uint256 currentHead = _customHead[tokenId_];
    uint256 currentClothes = _customClothes[tokenId_];

    if(head_ > 0){
      if(currentHead > 1) wardrobe.mint(msg.sender, currentHead);
      if(head_ > 1) wardrobe.burn(msg.sender, head_);
      _customHead[tokenId_] = head_;
    }

    if(clothes_ > 0){
      if(currentClothes > 1) wardrobe.mint(msg.sender, currentHead);
      if(clothes_ > 0) wardrobe.burn(msg.sender, clothes_);
      _customClothes[tokenId_] = clothes_;
    }
  }

  function getRaccool(uint256 tokenId_) private view returns(Raccool memory raccool){
    raccool.background = background(generateTrait(tokenId_, _backgroundRarities));
    raccool.fur = fur(generateTrait(tokenId_, _furRarities));
    raccool.face = face(generateTrait(tokenId_, _faceRarities));
    raccool.head = head(customTrait(tokenId_, _headRarities, _customHead));
    raccool.clothes = clothes(customTrait(tokenId_, _clothesRarities, _customClothes));
  }

  function customTrait(uint256 tokenId_, uint256[4] memory rarities_, mapping(uint256 => uint256) storage custom_) private view returns(uint256){
    uint256 n = custom_[tokenId_];
    if(n == 0) return generateTrait(tokenId_, rarities_);

    return n;
  }

  function generateTrait(uint256 tokenId_, uint256[4] memory rarities_) private view returns(uint256){
    uint256 n = 1 + random(tokenId_.toString()) % 10;
    uint256 trait = 0;

    while(n > rarities_[trait]){
      n -= rarities_[trait];
      trait++;
    }

    return trait;
  }

  // get a pseudorandom uint256 using the global and the given seed
  function random(string memory seed_) private view returns (uint256) {
    bytes memory seed = abi.encodePacked(_baseSeed, seed_);
    return uint256(keccak256(seed));
  }
}
