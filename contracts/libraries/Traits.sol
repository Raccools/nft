// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
library Traits {
  function backgrounds() internal pure returns(string[2][2] memory){
    return [
      ["yellow", "svg1"],
      ["blue", "svg2"]
    ];
  }

  function furs() internal pure returns(string[2][2] memory){
    return [
      ["basic 1", "svga"],
      ["basic 2", "svgb"]
    ];
  }

  function faces() internal pure returns(string[2][2] memory){
    return [
      ["smile", "svgX"],
      ["yum", "svgY"]
    ];
  }

  function heads() internal pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["mohawk", "svg=="],
      ["flower", "svg+="]
    ];
  }

  function clothes() internal pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["suit", "svggg"],
      ["bag", "svgff"]
    ];
  }
}
