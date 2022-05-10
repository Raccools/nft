// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// @author mande.eth
// @notice
library Traits {
  function hiddenBackground() external pure returns(string[2] memory){
    return ["?", "#979da6"];
  }

  function hiddenFur() external pure returns(string[2] memory){
    return ["?", '<path xmlns="http://www.w3.org/2000/svg" d="M 33 33 C 44 26 57 26 67 31 L 79 24 C 85 26 86 40 79 48 Q 80 54 84 59 C 67 82 32 69 15 64 L 23 50 C 13 47 13 28 18 24 Z M 24 67 Q 15 84 10 100 L 83 100 Q 81 83 73 69 Q 55 76 24 67 M 32 91 Q 24 96 21 100 M 78 100 Q 78 92 75 84" stroke="black" fill="#444"/>'];
  }

  function hiddenFace() external pure returns(string[2] memory){
    return ["?", ""];
  }

  function hiddenHead() external pure returns(string[2] memory){
    return ["?", ""];
  }

  function hiddenClothes() external pure returns(string[2] memory){
    return ["?", ""];
  }

  // 

  function backgrounds() external pure returns(string[2][2] memory){
    return [
      ["yellow", "#f9d100"],
      ["turquoise", "#00efb9"]
    ];
  }

  function furs() external pure returns(string[2][1] memory){
    return [
      ["brown", '<path d="M 33 33 C 44 26 57 26 67 31 L 79 24 C 85 26 86 40 79 48 Q 80 54 84 59 C 67 82 32 69 15 64 L 23 50 C 13 47 13 28 18 24 Z M 24 67 Q 15 84 10 100 L 83 100 Q 81 83 73 69 Q 55 76 24 67 M 32 91 Q 24 96 21 100 M 78 100 Q 78 92 75 84" stroke="black" stroke-width="1.5" fill="#a48d76" /><path d="M 40 100 L 74 100 Q 72 85 65 79 T 48 80 Q 40 88 40 99 M 52 69 Q 43 64 44 59 Q 49 50 61 49 Q 74 47 74 59 Q 74 64 70 67 Q 61 74 52 69" fill="#d2d0c9" /><path d="M 40 100 H 74" stroke="black" stroke-width="1.5" /><path d="M 21 39 Q 17 27 25 31 Q 30 35 31 40 C 30 44 23 46 21 39 M 72 36 Q 75 27 79 29 Q 80 30 80 31 C 79 41 76 42 72 36" fill="#8d755e" /><path d="M 21 39 Q 17 27 25 31 Q 30 35 31 40 M 72 36 Q 75 27 79 29 Q 80 30 80 31" stroke="black" fill="none" /><path d="M 28 54 Q 26 53 40 44 Q 48 40 51 43 T 57 44 Q 58 43 57 41 Q 56 38 58 37 Q 62 36 62 38 Q 61 43 63 44 Q 65 44 66 42 C 68 41 71 41 73 42 Q 75 43 80 56 Q 78 59 70 55 Q 67 52 66 54 Q 63 56 59 53 C 58 52 56 52 55 53 Q 52 56 50 56 Q 31 58 28 54" fill="#3e3838" />']
    ];
  }

  function faces() external pure returns(string[2][1] memory){
    return [
      ["yum", '<path d="M 59 54 C 61 53 64 53 66 54 Q 68 55 65 57 C 63 58 61 58 60 57 Q 57 55 59 54" stroke="black" fill="black"/><path d="M 66 60 Q 59 61 51 61" stroke="black" fill="none"/><path d="M 55 61 H 52 Q 50 61 51 58 C 52 56 54 56 55 58 V 61" stroke="black" fill="#ff859c"/>']
    ];
  }

  function heads() external pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["mohawk", '<path d="M 61 33 V 17 L 56 16 L 47 16 L 46 20 L 43 15 C 38 17 32 23 33 32 C 42 28 49 27 57 34 L 61 33 M 56 16 L 57 34" stroke="black" stroke-width="1.5" fill="#bcf118" />'],
      ["flower", '<path d="M 28 27 C 29 22 33 21 36 25 C 41 22 48 30 39 32 C 44 36 40 41 35 37 C 31 43 24 39 29 33 C 20 34 23 26 28 27" stroke="black" fill="#fcd558"/><path d="M 31 30 A 1 1 0 0 0 36 31 A 1 1 0 0 0 31 30 M 28 27 Q 29 29 31 30 M 36 25 Q 35 27 35 28 M 39 32 Q 38 31 36 31 M 35 37 Q 33 35 34 33 M 29 33 Q 30 32 31 32" stroke="black" fill="#441d09"/>']
    ];
  }

  function clothes() external pure returns(string[2][4] memory){
    return [
      ["", ""],
      ["", ""],
      ["suit", '<path d="M 43 73 C 50 75 64 77 68 72 L 60 89 Z" stroke="black" fill="#e0e0e0"/><path d="M 23 68 L 44 72 L 58 85 L 60 88 L 68 71 L 74 69 L 78 73 L 84 100 L 9 100 L 16 72 Z" stroke="black" fill="#212121"/><path d="M 16 72 C 22 76 27 82 30 90 L 27 100 M 33 70 C 36 71 38 73 39 76 L 46 74 L 45 81 L 60 88 M 74 69 C 73 70 71 73 71 75 L 67 73 L 70 79 L 60 88 M 78 73 C 77 76 76 80 76 83 L 79 100 M 60 88 C 61 89 61 91 60 92 L 55 100 M 60 92 L 62 100" stroke="black" fill="none"/><circle cx="58" cy="90" r="1.5" stroke="black" fill="#2a375a"/>'],
      ["bag", '<path d="M 22 67 Q 37 72 51 72 C 54 79 58 79 61 72 Q 68 72 74 68 L 84 88 L 77 91 L 78 100 L 20 100 L 27 94 Z" stroke="black" fill="#ffa327"/><path d="M 22 67 Q 16 77 13 87 Q 22 89 27 95 L 31 92 Q 27 79 22 67 M 74 68 L 77 91" stroke="black" fill="#ffa327"/><path d="M 21 100 Q 31 97 40 92 C 40 88 53 75 58 80 Q 66 75 73 68 L 75 70 C 70 76 65 81 66 88 C 68 89 56 107 45 98 Q 36 97 28 100 Z" stroke="black" fill="#2e2e2e"/><path d="M 45 98 Q 39 94 40 92 M 58 80 Q 66 84 66 88 M 44 93 L 52 85 Q 53 84 54 85 V 90 Q 53 91 52 90 V 85" stroke="black"/>']
    ];
  }
}
