// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./libraries/Base64.sol";
import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools {
  // @dev global random seed
  string public _baseSeed;
  string public _provenance;

  // @dev trait name and svg image
  string[2][2] _backgrounds = [["yellow", "svg1"], ["blue", "svg2"]];
  string[2][2] _furs = [["basic 1", "svga"], ["basic 2", "svgb"]];
  string[2][2] _faces = [["smile", "svgX"], ["yum", "svgY"]];

  uint256[2] _backgroundRarities = [5, 10];
  uint256[2] _furRarities = [5, 10];
  uint256[2] _facesRarities = [8, 10];

  uint256 _maxBackgroundRarity = _backgroundRarities[1];
  uint256 _maxFurRarity = _furRarities[1];
  uint256 _maxFaceRarity = _facesRarities[1];

  mapping(uint256 => uint256) _backgroundIndexes;
  mapping(uint256 => uint256) _furIndexes;
  mapping(uint256 => uint256) _faceIndexes;

  constructor(){
    for(uint i=0; i < 2; i++){
      _backgroundIndexes[_backgroundRarities[i]] = i+1;
      _furIndexes[_furRarities[i]] = i+1;
      _faceIndexes[_facesRarities[i]] = i+1;
    }
  }

  function random(string memory seed_) public view returns (uint256) {
    bytes memory seed = abi.encodePacked(_baseSeed, seed_);
    return uint256(keccak256(seed));
  }

  function tokenURI(uint256 tokenId_) public view returns(string memory){
    return "data:application/json;base64,";
  }
}
