// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
interface IWardrobe {
  function mintHead(address account_, uint256 tokenId_) external;
  function mintClothes(address account_, uint256 tokenId_) external;
  function burnHead(address account_, uint256 tokenId_) external;
  function burnClothes(address account_, uint256 tokenId_) external;
  function balanceOf(address account_, uint256 tokenId_) external view returns(uint256);
  function head(uint256 headIndex_) external view returns(string[2] memory);
  function clothes(uint256 clothesIndex_) external view returns(string[2] memory);
}
