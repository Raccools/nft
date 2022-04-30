// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
library Traits {
  function hiddenBackground() internal pure returns(string[2] memory){
    return ["?", "#f9d100"];
  }

  function hiddenFur() internal pure returns(string[2] memory){
    return ["?", '<path d="M 33 33 C 44 26 57 26 67 31 L 79 24 C 85 26 86 40 79 48 Q 80 54 84 59 C 67 82 32 69 15 64 L 23 50 C 13 47 13 28 18 24 Z M 24 67 Q 15 84 10 100 L 83 100 Q 81 83 73 69 Q 55 76 24 67 M 32 91 Q 24 96 21 100 M 78 100 Q 78 92 75 84" stroke="black" stroke-width="1.5" fill="#333333" />'];
  }

  function hiddenFace() internal pure returns(string[2] memory){
    return ["?", ""];
  }

  function hiddenHead() internal pure returns(string[2] memory){
    return ["?", ""];
  }

  function hiddenClothes() internal pure returns(string[2] memory){
    return ["?", ""];
  }

  // 

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
