// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
interface IWardrobe {
  function mint(address account_, uint256 tokenId_) external;
  function burn(address account_, uint256 tokenId_) external;
  function balanceOf(address account_, uint256 tokenId_) external view returns(uint256);
  function head(uint256 headIndex_) external view returns(string[2] memory);
  function clothes(uint256 clothesIndex_) external view returns(string[2] memory);
  function headTokenId(uint256 headIndex_) external pure returns(uint256);
  function clothesTokenId(uint256 clothesIndex_) external pure returns(uint256);
}
