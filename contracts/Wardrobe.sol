// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./libraries/Traits.sol";
import "./libraries/Base64.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// @author mande.eth
// @notice
contract Wardrobe is ERC1155, Ownable {
  // json metadata
  string private constant _name1 = '{"name": "';
  string private constant _attr1 = '", "attributes": [{"trait_type": "type", "value": "';
  string private constant _imag1 = '"}], "image": "data:image/svg+xml;base64,';
  string private constant _imag2 = '"}';

  // svg tag
  string private constant _svg1 = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0, 0, 100, 100"><rect width="100" height="100" fill="#f54242"></rect>';
  string private constant _svg2= '</svg>';

  address private _raccools;

  string[2][] private _heads = Traits.heads();
  string[2][] private _clothes = Traits.clothes();

  constructor() ERC1155(""){}

  modifier callerIsRaccools(){
    require(msg.sender == _raccools, "Not allowed");
    _;
  }

  function createHead(string[2] memory trait_, uint256 amount_) external onlyOwner {
    _heads.push(trait_);

    uint256 tokenId = _heads.length - 1;

    _mint(msg.sender, tokenId * 2, amount_, "");
  }

  function createClothes(string[2] memory trait_, uint256 amount_) external onlyOwner {
    _clothes.push(trait_);

    uint256 tokenId = _heads.length - 1;

    _mint(msg.sender, tokenId * 2 + 1, amount_, "");
  }

  function setRaccoolsAddress(address raccools_) external {
    _raccools = raccools_;
  }

  function head(uint256 headIndex_) public view returns(string[2] memory){
    return _heads[headIndex_];
  }

  function clothes(uint256 clothesIndex_) public view returns(string[2] memory){
    return _clothes[clothesIndex_];
  }

  function mintHead(address _to, uint256 _tokenId) external callerIsRaccools {
    _mint(_to, _tokenId * 2, 1, "");
  }

  function mintClothes(address _to, uint256 _tokenId) external callerIsRaccools {
    _mint(_to, _tokenId * 2 + 1, 1, "");
  }

  function burnHead(address _account, uint256 _tokenId) external callerIsRaccools {
    _burn(_account, _tokenId * 2, 1);
  }

  function burnClothes(address _account, uint256 _tokenId) external callerIsRaccools {
    _burn(_account, _tokenId * 2 + 1, 1);
  }

  function uri(uint256 tokenId_) public view virtual override returns (string memory) {
    string[2] memory asset;
    string memory traitType;

    if(tokenId_ % 2 == 0) {
      asset = head(tokenId_ / 2);
      traitType = "head";
    }
    else {
      asset = clothes((tokenId_ - 1) / 2);
      traitType = "clothes";
    }

    string memory svg = Base64.encode(abi.encodePacked(_svg1, asset[1], _svg2));
    string memory encodedJson = Base64.encode(abi.encodePacked(_name1, asset[0], _attr1, traitType, _imag1, svg, _imag2));

    return string(abi.encodePacked("data:application/json;base64,", encodedJson));
  }
}
