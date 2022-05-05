// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./libraries/Traits.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @author mande.eth
// @notice 
contract Wardrobe is ERC1155, Ownable {
  string[2][] private _heads = Traits.heads();
  string[2][] private _clothes = Traits.clothes();

  constructor() ERC1155(""){}

  function head(uint256 headIndex_) public view returns(string[2] memory){
    return _heads[headIndex_];
  }

  function clothes(uint256 clothesIndex_) public view returns(string[2] memory){
    return _clothes[clothesIndex_];
  }

  function headTokenId(uint256 headIndex_) external pure returns(uint256){
    return headIndex_ * 2;
  }

  function clothesTokenId(uint256 clothesIndex_) external pure returns(uint256){
    return clothesIndex_ * 2 + 1;
  }

  function mint(address _to, uint256 _tokenId) external {
    _mint(_to, _tokenId, 1, "");
  }

  function burn(address _account, uint256 _tokenId) external {
    _burn(_account, _tokenId, 1);
  }


  function uri(uint256 _tokenId) public view virtual override returns (string memory) {
    return "";
  }
}
