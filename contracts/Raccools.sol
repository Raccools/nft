// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '@openzeppelin/contracts/utils/Strings.sol';
import "./libraries/Base64.sol";
import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools {
  using Strings for uint256;

  // global random seed
  string public _baseSeed;
  string public _provenance;

  // trait name and svg image
  string[2][2] private _backgroundTraits = [
    ["yellow", "svg1"],
    ["blue", "svg2"]
  ];

  string[2][2] private _furTraits = [
    ["basic 1", "svga"],
    ["basic 2", "svgb"]
  ];

  string[2][2] private _faceTraits = [
    ["smile", "svgX"],
    ["yum", "svgY"]
  ];

  // rarity intervals
  // higher two adjacent rarity distances higher the latter trait occurrence
  uint256[2] private _backgroundRarities = [5, 10];
  uint256[2] private _furRarities = [5, 10];
  uint256[2] private _faceRarities = [8, 10];

  // rarity-trait mapping
  // @dev same idea as erc721a `ownerOf` strategy to link owner to token id
  mapping(uint256 => uint256) _backgrounds;
  mapping(uint256 => uint256) _furs;
  mapping(uint256 => uint256) _faces;

  uint256 private _sizeBackgrounds = _backgroundRarities[1];
  uint256 private _sizeFurs = _furRarities[1];
  uint256 private _sizeFaces = _faceRarities[1];

  constructor(){
    for(uint i=0; i < 2; i++){
      _backgrounds[_backgroundRarities[i]] = i+1;
    }

    for(uint i=0; i < 2; i++){
      _furs[_furRarities[i]] = i+1;
    }

    for(uint i=0; i < 2; i++){
      _faces[_faceRarities[i]] = i+1;
    }
  }

  function face(uint256 tokenId_) public view returns(string[2] memory){
    return _faceTraits[traitIndex(tokenId_, _sizeFaces, _faces)];
  }

  function background(uint256 tokenId_) public view returns(string[2] memory){
    return _backgroundTraits[traitIndex(tokenId_, _sizeBackgrounds, _backgrounds)];
  }

  function fur(uint256 tokenId_) public view returns(string[2] memory){
    return _furTraits[traitIndex(tokenId_, _sizeFurs, _furs)];
  }

  // get a random trait index from a rarity-trait mapping
  function traitIndex(uint256 tokenId_, uint256 rangeSize_, mapping(uint256 => uint256) storage ranges_) private view returns(uint256){
    uint256 rangeIndex = random(tokenId_.toString()) % rangeSize_;

    while(rangeIndex > 0){
      uint256 trait = ranges_[rangeIndex];
      if(trait > 0) return trait;
      rangeIndex--;
    }

    return 0;
  }

  // get a pseudorandom uint256 using a global and given seed
  function random(string memory seed_) private view returns (uint256) {
    bytes memory seed = abi.encodePacked(_baseSeed, seed_);
    return uint256(keccak256(seed));
  }

//  function tokenURI(uint256 tokenId_) public view returns(string memory){
//    return "data:application/json;base64,";
//  }
}
