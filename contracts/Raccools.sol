// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC721A.sol";
import "./libraries/Base64.sol";
import "./libraries/Traits.sol";
import "./interfaces/IWardrobe.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools is ERC721A, Ownable {
  using Strings for uint256;

  // mint parameters
  uint256 public constant _maxSupply = 10_000;
  uint256 public constant _cost = 0.08 ether;
  uint256 public constant _maxMintPerTx = 20;

  // global random seed
  string public _baseSeed;
  string public _provenance;

  // onchain assets contract
  address private immutable _wardrobe;

  // trait rarities
  uint256[4] private _backgroundRarities = [5, 5];
  uint256[4] private _furRarities = [5, 5];
  uint256[4] private _faceRarities = [5, 5];
  uint256[4] private _headRarities = [0, 0, 5, 5];
  uint256[4] private _clothesRarities = [0, 0, 5, 5];

  // token custom assets
  // @dev encoded by f(a,b) = a * 2^128 + b
  mapping(uint256 => uint256) private _customTraits;

  // json metadata
  string private constant _name1 = '{"name": "Raccools #';
  string private constant _attr1 = '", "attributes": [{"trait_type": "background", "value": "';
  string private constant _attr2 = '"}, {"trait_type": "fur", "value": "';
  string private constant _attr3 = '"}, {"trait_type": "face", "value": "';
  string private constant _attr4 = '"}, {"trait_type": "head", "value": "';
  string private constant _attr5 = '"}, {"trait_type": "clothes", "value": "';
  string private constant _imag1 = '"}], "image": "data:image/svg+xml;base64,';
  string private constant _imag2 = '"}';

  // svg tag
  string private constant _svg1 = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0, 0, 100, 100"><rect width="100" height="100" fill="';
  string private constant _svg2 = '"></rect>';
  string private constant _svg3 = "</svg>";

  struct Raccool {
    string[2] background;
    string[2] fur;
    string[2] face;
    string[2] head;
    string[2] clothes;
  }

  // TODO: test logging
  event HeadTransfer(address indexed from, address indexed to, uint256 indexed id);

  event ClothesTransfer(address indexed from, address indexed to, uint256 indexed id);

  constructor(address wardrobe_) ERC721A("Raccools", "RACCOOL"){
    _wardrobe = wardrobe_;
  }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "Cannot call from a contract");
    _;
  }

  function mint(uint256 amount_) external payable callerIsUser {
    require(_totalMinted() + amount_ <= _maxSupply, "Cannot exceed max supply");
    require(amount_ <= _maxMintPerTx, "Cannot exceed 20 per tx");
    require(msg.value >= amount_ * _cost, "Insufficient funds");

    _mint(msg.sender, amount_);
  }

  // TODO: is it needed to use callerIsUser?
  function customize(uint256 tokenId_, uint256 head_, uint256 clothes_) external {
    require(msg.sender == ownerOf(tokenId_));

    IWardrobe wardrobe = IWardrobe(_wardrobe);

    if(head_ > 0){
//      uint256 currentHead = getCustomHead(tokenId_);
//
//      if(currentHead > 1){
//        wardrobe.mint(msg.sender, currentHead);
//        emit HeadTransfer(address(0), msg.sender, currentHead);
//      }
//      if(head_ > 1){
//        wardrobe.burn(msg.sender, head_);
//        emit HeadTransfer(msg.sender, address(0), head_);
//      }
    }
//
//    if(clothes_ > 0){
//      uint256 currentClothes = getCustomClothes(tokenId_);
//
//      if(currentClothes > 1){
//        wardrobe.mint(msg.sender, currentClothes);
//        emit ClothesTransfer(address(0), msg.sender, currentClothes);
//      }
//      if(clothes_ > 1){
//        wardrobe.burn(msg.sender, clothes_);
//        emit ClothesTransfer(msg.sender, address(0), clothes_);
//      }
//      _customClothes[tokenId_] = clothes_;
//    }
  }

  function encodeCustomTraits(uint256 head_, uint256 clothes_) private pure returns(uint256){
    return (1 << 128) * head_ + clothes_;
  }

  function decodeCustomTraits(uint256 _encoded) private pure returns(uint256, uint256){
    return (uint256(_encoded) / (1 << 128), _encoded % (1 << 128));
  }

  function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
    require(_exists(tokenId_), "Token not minted");

    Raccool memory raccool = getRaccool(tokenId_);
    string memory attributes = raccoolAttributes(raccool);
    string memory svg = raccoolImage(raccool);
    string memory encodedJson = Base64.encode(abi.encodePacked(_name1, tokenId_.toString(), attributes, _imag1, svg, _imag2));

    return string(abi.encodePacked("data:application/json;base64,", encodedJson));
  }

  function raccoolAttributes(Raccool memory raccool_) private pure returns(string memory){
    string memory backgroundName = raccool_.background[0];
    string memory furName = raccool_.fur[0];
    string memory faceName = raccool_.face[0];
    string memory headName = raccool_.head[0];
    string memory clothesName = raccool_.clothes[0];

    return string(abi.encodePacked(_attr1, backgroundName, _attr2, furName, _attr3, faceName, _attr4, headName, _attr5, clothesName));
  }

  function raccoolImage(Raccool memory raccool_) private pure returns(string memory){
    string memory backgroundSvg = raccool_.background[1];
    string memory furSvg = raccool_.fur[1];
    string memory faceSvg = raccool_.face[1];
    string memory headSvg = raccool_.head[1];
    string memory clothesSvg = raccool_.clothes[1];

    return Base64.encode(abi.encodePacked(_svg1, backgroundSvg, _svg2, furSvg, faceSvg, headSvg, clothesSvg, _svg3));
  }

  function getRaccool(uint256 tokenId_) private view returns(Raccool memory raccool){
    if(isRevealed() == false) return getHiddenRaccool();

    (uint256 customHead, uint256 customClothes) = decodeCustomTraits(_customTraits[tokenId_]);

    raccool.background = background(generateTrait(tokenId_, _backgroundRarities));
    raccool.fur = fur(generateTrait(tokenId_, _furRarities));
    raccool.face = face(generateTrait(tokenId_, _faceRarities));
    raccool.head = head(customHead > 0 ? customHead : generateTrait(tokenId_, _headRarities));
    raccool.clothes = clothes(customClothes > 0 ? customClothes : generateTrait(tokenId_, _clothesRarities));
  }

  function getHiddenRaccool() private pure returns(Raccool memory raccool){
    raccool.background = Traits.hiddenBackground();
    raccool.fur = Traits.hiddenFur();
    raccool.face = Traits.hiddenFace();
    raccool.head = Traits.hiddenHead();
    raccool.clothes = Traits.hiddenClothes();
  }

  function isRevealed() public view returns(bool){
    return bytes(_baseSeed).length > 0;
  }

  function background(uint256 backgroundIndex_) private pure returns(string[2] memory){
    return Traits.backgrounds()[backgroundIndex_];
  }

  function fur(uint256 furIndex_) private pure returns(string[2] memory){
    return Traits.furs()[furIndex_];
  }

  function face(uint256 faceIndex_) private pure returns(string[2] memory){
    return Traits.faces()[faceIndex_];
  }

  function head(uint256 headIndex_) private view returns(string[2] memory){
    return IWardrobe(_wardrobe).head(headIndex_);
  }

  function clothes(uint256 clothesIndex_) private view returns(string[2] memory){
    return IWardrobe(_wardrobe).clothes(clothesIndex_);
  }

  function generateTrait(uint256 tokenId_, uint256[4] memory rarities_) private view returns(uint256){
    uint256 n = 1 + random(tokenId_.toString()) % 10;
    uint256 trait = 0;

    while(n > rarities_[trait]){
      n -= rarities_[trait];
      trait++;
    }

    return trait;
  }

  function random(string memory seed_) private view returns (uint256) {
    bytes memory seed = abi.encodePacked(_baseSeed, seed_);
    return uint256(keccak256(seed));
  }

  // ERC721A Metadata

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  // onlyOwner

  function setProvenance(string memory sha256_) external onlyOwner {
    _provenance = sha256_;
  }

  function setBaseSeed(string memory seed_) external onlyOwner {
    _baseSeed = seed_;
  }

  function withdraw() external onlyOwner {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "Ether not sent");
  }
}
