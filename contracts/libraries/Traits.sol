// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
library Traits {
  function hiddenBackground() internal pure returns(string[2] memory){
    return ["?", "#f9d100"];
  }

  function hiddenFur() internal pure returns(string[2] memory){
    return ["?", '<path d="M 33 33 C 44 26 57 26 67 31 L 79 24 C 85 26 86 40 79 48 Q 80 54 84 59 C 67 82 32 69 15 64 L 23 50 C 13 47 13 28 18 24 Z M 24 67 Q 15 84 10 100 L 83 100 Q 81 83 73 69 Q 55 76 24 67 M 32 91 Q 24 96 21 100 M 78 100 Q 78 92 75 84" stroke="black" stroke-width="1.5" fill="#a48d76" /><path d="M 40 100 L 74 100 Q 72 85 65 79 T 48 80 Q 40 88 40 99 M 52 69 Q 43 64 44 59 Q 49 50 61 49 Q 74 47 74 59 Q 74 64 70 67 Q 61 74 52 69" fill="#d2d0c9" /><path d="M 40 100 H 74" stroke="black" stroke-width="1.5" /><path d="M 21 39 Q 17 27 25 31 Q 30 35 31 40 C 30 44 23 46 21 39 M 72 36 Q 75 27 79 29 Q 80 30 80 31 C 79 41 76 42 72 36" fill="#8d755e" /><path d="M 21 39 Q 17 27 25 31 Q 30 35 31 40 M 72 36 Q 75 27 79 29 Q 80 30 80 31" stroke="black" fill="none" /><path d="M 28 54 Q 26 53 40 44 Q 48 40 51 43 T 57 44 Q 58 43 57 41 Q 56 38 58 37 Q 62 36 62 38 Q 61 43 63 44 Q 65 44 66 42 C 68 41 71 41 73 42 Q 75 43 80 56 Q 78 59 70 55 Q 67 52 66 54 Q 63 56 59 53 C 58 52 56 52 55 53 Q 52 56 50 56 Q 31 58 28 54" fill="#3e3838" />'];
  }

  function hiddenFace() internal pure returns(string[2] memory){
    return ["?", '<path d="M 47 44 A 1 1 0 0 0 46 56 A 1 1 0 0 0 47 44 M 70 43 A 1 1 0 0 0 70 55 A 1 1 0 0 0 70 43" stroke="none" fill="black" /><path d="M 48 46 A 1 1 0 0 0 49 49 A 1 1 0 0 0 48 46 M 45 49 A 1 1 0 0 0 45 52 A 1 1 0 0 0 45 49 M 46 53 A 1 1 0 0 0 46 55 A 1 1 0 0 0 46 53 M 71 45 A 1 1 0 0 0 72 49 A 1 1 0 0 0 71 45 M 68 48 A 1 1 0 0 0 68 50 A 1 1 0 0 0 68 48 M 68 51 A 1 1 0 0 0 69 53 A 1 1 0 0 0 68 51" stroke="none" fill="white" /><path d="M 59 54 C 61 53 64 53 66 54 Q 68 55 65 57 C 63 58 61 58 60 57 Q 57 55 59 54" stroke="black" fill="black" /><path d="M 66 60 Q 59 61 51 61" stroke="black" fill="none" /><path d="M 55 61 H 52 Q 50 61 51 58 C 52 56 54 56 55 58 V 61" stroke="black" fill="#ff859c" />'];
  }

  function hiddenHead() internal pure returns(string[2] memory){
    return ["?", '<path d="M 61 33 V 17 L 56 16 L 47 16 L 46 20 L 43 15 C 38 17 32 23 33 32 C 42 28 49 27 57 34 L 61 33 M 56 16 L 57 34" stroke="black" stroke-width="1.5" fill="#bcf118" />'];
  }

  function hiddenClothes() internal pure returns(string[2] memory){
    return ["?", '<path d="M 22 67 Q 37 72 51 72 C 54 79 58 79 61 72 Q 68 72 74 68 L 84 88 L 77 91 L 78 100 L 20 100 L 27 94 Z" stroke="black" stroke-width="1.5" fill="#ffa327" /><path d="M 22 67 Q 16 77 13 87 Q 22 89 27 95 L 31 92 Q 27 79 22 67 M 74 68 L 77 91" stroke="black" stroke-width="1.5" fill="#ffa327" /><path d="M 21 100 Q 31 97 40 92 C 40 88 53 75 58 80 Q 66 75 73 68 L 75 70 C 70 76 65 81 66 88 C 68 89 56 107 45 98 Q 36 97 28 100 Z" stroke="black" stroke-width="1.5" fill="#2e2e2e" /><path d="M 45 98 Q 39 94 40 92 M 58 80 Q 66 84 66 88 M 44 93 L 52 85 Q 53 84 54 85 V 90 Q 53 91 52 90 V 85" stroke="black" stroke-width="1.5" />'];
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
