// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./libraries/Traits.sol";

// @author mande.eth
// @notice 
contract Wardrobe {
  string[2][] private _heads = Traits.heads();
  string[2][] private _clothes = Traits.clothes();

  function head(uint256 headIndex_) public view returns(string[2] memory){
    return _heads[headIndex_];
  }

  function clothes(uint256 clothesIndex_) public view returns(string[2] memory){
    return _clothes[clothesIndex_];
  }
}
