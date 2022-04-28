// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
library Traits {
  function background(uint256 backgroundIndex_) internal pure returns(string[2] memory){
    return [
      ["yellow", "svg1"],
      ["blue", "svg2"]
    ][backgroundIndex_];
  }

  function fur(uint256 furIndex_) internal pure returns(string[2] memory){
    return [
      ["basic 1", "svga"],
      ["basic 2", "svgb"]
    ][furIndex_];
  }

  function face(uint256 faceIndex_) internal pure returns(string[2] memory){
    return [
      ["smile", "svgX"],
      ["yum", "svgY"]
    ][faceIndex_];
  }

  function head(uint256 headIndex_) internal pure returns(string[2] memory){
    return [
      ["", ""],
      ["", ""],
      ["mohawk", "svg=="],
      ["flower", "svg+="]
    ][headIndex_];
  }

  function clothes(uint256 clothesIndex_) internal pure returns(string[2] memory){
    return [
      ["", ""],
      ["", ""],
      ["suit", "svggg"],
      ["bag", "svgff"]
    ][clothesIndex_];
  }
}
