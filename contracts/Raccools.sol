// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Strings.sol';
import "./libraries/Base64.sol";
import "./libraries/Traits.sol";
import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools {
  using Strings for uint256;

  // global random seed
  string public _baseSeed;
  string public _provenance;

  // trait name and svg image
  string[2][4] private _backgroundTraits = Traits.backgroundTraits();
  string[2][4] private _furTraits = Traits.furTraits();
  string[2][4] private _faceTraits = Traits.faceTraits();
  string[2][4] private _headTraits = Traits.headTraits();
  string[2][4] private _clothesTraits = Traits.clothesTraits();

  // generator rarities
  uint256[4] private _backgroundRarities = [5, 5];
  uint256[4] private _furRarities = [5, 5];
  uint256[4] private _faceRarities = [5, 5];
  uint256[4] private _headRarities = [0, 0, 5, 5];
  uint256[4] private _clothesRarities = [0, 0, 5, 5];

  mapping(uint256 => uint256) _customHead;
  mapping(uint256 => uint256) _customClothes;

  constructor(){
    console.log(background(0)[0]);
    console.log(fur(0)[0]);
    console.log(face(0)[0]);
    console.log(head(0)[0]);
    console.log(clothes(0)[0]);
  }

  function face(uint256 tokenId_) private view returns(string[2] memory){
    return _faceTraits[generateTrait(tokenId_, _faceRarities)];
  }

  function background(uint256 tokenId_) private view returns(string[2] memory){
    return _backgroundTraits[generateTrait(tokenId_, _backgroundRarities)];
  }

  function fur(uint256 tokenId_) private view returns(string[2] memory){
    return _furTraits[generateTrait(tokenId_, _furRarities)];
  }

  function head(uint256 tokenId_) private view returns(string[2] memory){
    return _headTraits[customTrait(tokenId_, _headRarities, _customHead)];
  }

  function clothes(uint256 tokenId_) private view returns(string[2] memory){
    return _clothesTraits[customTrait(tokenId_, _clothesRarities, _customClothes)];
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

//  function tokenURI(uint256 tokenId_) external view returns(string memory){
//    return "data:application/json;base64,";
//  }
}
