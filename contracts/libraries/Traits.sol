// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @author Brecht Devos <brecht@loopring.org>
/// @notice Provides a function for encoding some bytes in base64
library Traits {
  function backgroundTraits() internal pure returns(string[2][2] memory){
    return [
      ["yellow", "svg1"],
      ["blue", "svg2"]
    ];
  }

  function furTraits() internal pure returns(string[2][2] memory){
    return [
      ["basic 1", "svga"],
      ["basic 2", "svgb"]
    ];
  }

  function faceTraits() internal pure returns(string[2][2] memory){
    return [
      ["smile", "svgX"],
      ["yum", "svgY"]
    ];
  }

  function headTraits() internal pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["mohawk", "svg=="],
      ["flower", "svg+="]
    ];
  }

  function clothesTraits() internal pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["suit", "svggg"],
      ["bag", "svgff"]
    ];
  }
}
