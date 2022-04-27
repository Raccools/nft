// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
interface IWardrobe {
  function mint(address account_, uint256 tokenId_) external;
  function burn(address account_, uint256 tokenId_) external;
  function balanceOf(address account_, uint256 tokenId_) external view returns(uint256);
}
