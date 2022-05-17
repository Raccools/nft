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
  uint256[10] private _backgroundRarities = [0, 0, 0, 0, 0, 1, 1, 1, 1, 1];
  uint256[10] private _furRarities = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  uint256[10] private _faceRarities = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  uint256[10] private _headRarities = [2, 2, 2, 2, 2, 3, 3, 3, 3, 3];
  uint256[10] private _clothesRarities = [2, 2, 2, 2, 2, 3, 3, 3, 3, 3];

  // token custom assets
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

  event Customize(uint256 newTokenId, uint256[2] headChanges, uint256[2] clothesChanges);

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

  function customize(uint256 tokenId_, uint256 head_, uint256 clothes_) external callerIsUser {
    //require(_totalMinted() == _maxSupply, "Not available yet");
    require(msg.sender == ownerOf(tokenId_), "Must be the token owner");  // 5,267 gas

    IWardrobe wardrobe = IWardrobe(_wardrobe);
    (uint256 token, uint256 currentHead, uint256 currentClothes) = customTraits(tokenId_); // 16,828 gas

    if(head_ == 0) head_ = currentHead;
    if(clothes_ == 0) clothes_ = currentClothes;

    if(head_ == currentHead && clothes_ == currentClothes) revert("Would produce same raccool");

    if(head_ != currentHead){
      if(currentHead > 1) wardrobe.mintHead(msg.sender, currentHead); // 32,481 gas
      if(head_ > 1) wardrobe.burnHead(msg.sender, head_); // 5,839 gas
    }

    if(clothes_ != currentClothes){
      if(currentClothes > 1) wardrobe.mintClothes(msg.sender, currentClothes); // 32,481 gas
      if(clothes_ > 1) wardrobe.burnClothes(msg.sender, clothes_); // 5,839 gas
    }

    emit Customize(_currentIndex, [currentHead, head_], [currentClothes, clothes_]); // 3,955 gas
    _customTraits[_currentIndex] = encodeCustomTraits(token, head_, clothes_); // 23,153 gas

    _burn(tokenId_); // 41,804 gas
    _mint(msg.sender, 1); // 26,975 gas
  }

  function customizeSwap(uint256[2] calldata tokenIds_, bool head_, bool clothes_) external callerIsUser {
    //require(_totalMinted() == _maxSupply, "Not available yet");
    require(msg.sender == ownerOf(tokenIds_[0]), "Must be the token owner");  // 5,267 gas
    require(msg.sender == ownerOf(tokenIds_[1]), "Must be the token owner");  // 5,267 gas
    require(head_ || clothes_, "Would produce same raccools");

    (uint256 tokenA, uint256 currentHeadA, uint256 currentClothesA) = customTraits(tokenIds_[0]); // 16,828 gas
    (uint256 tokenB, uint256 currentHeadB, uint256 currentClothesB) = customTraits(tokenIds_[1]); // 16,828 gas

    uint256 headA = currentHeadA;
    uint256 headB = currentHeadB;
    uint256 clothesA = currentClothesA;
    uint256 clothesB = currentClothesB;

    if(head_){
      headA = currentHeadB;
      headB = currentHeadA;
    }

    if(clothes_){
      clothesA = currentClothesB;
      clothesB = currentClothesA;
    }

    emit Customize(_currentIndex, [currentHeadA, headA], [currentClothesA, clothesA]); // 3,955 gas
    _customTraits[_currentIndex] = encodeCustomTraits(tokenA, headA, clothesA); // 23,153 gas

    _burn(tokenIds_[0]); // 41,804 gas
    _mint(msg.sender, 1); // 26,975 gas

    emit Customize(_currentIndex, [currentHeadB, headB], [currentClothesB, clothesB]); // 3,955 gas
    _customTraits[_currentIndex] = encodeCustomTraits(tokenB, headB, clothesB); // 23,153 gas

    _burn(tokenIds_[1]); // 41,804 gas
    _mint(msg.sender, 1); // 26,975 gas
  }

  function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
    require(_exists(tokenId_), "Token not minted");

    Raccool memory raccool = getRaccool(tokenId_);
    string memory attributes = raccoolAttributes(raccool);
    string memory svg = raccoolImage(raccool);
    string memory encodedJson = Base64.encode(abi.encodePacked(_name1, tokenId_.toString(), attributes, _imag1, svg, _imag2));

    return string(abi.encodePacked("data:application/json;base64,", encodedJson));
  }

  // On-chain engine

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

    (uint256 token, uint256 customHead, uint256 customClothes) = customTraits(tokenId_);

    raccool.background = background(generateTrait("background", token, _backgroundRarities));
    raccool.fur = fur(generateTrait("fur", token, _furRarities));
    raccool.face = face(generateTrait("face", token, _faceRarities));
    raccool.head = head(customHead);
    raccool.clothes = clothes(customClothes);
  }

  function getHiddenRaccool() private pure returns(Raccool memory raccool){
    raccool.background = Traits.hiddenBackground();
    raccool.fur = Traits.hiddenFur();
    raccool.face = Traits.hiddenFace();
    raccool.head = Traits.hiddenHead();
    raccool.clothes = Traits.hiddenClothes();
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

  function customTraits(uint256 tokenId_) private view returns(uint256, uint256, uint256){
    (uint256 token, uint256 customHead, uint256 customClothes) = decodeCustomTraits(_customTraits[tokenId_]);

    if(token == 0) token = tokenId_;
    if(customHead == 0) customHead = generateTrait("head", token, _headRarities);
    if(customClothes == 0) customClothes = generateTrait("clothes", token, _clothesRarities);

    return (token, customHead, customClothes);
  }

  function generateTrait(string memory salt_, uint256 tokenId_, uint256[10] storage rarities_) private view returns(uint256){
    uint256 n = random(string(abi.encodePacked(tokenId_.toString(), salt_))) % 10;

    return rarities_[n];
  }

  // Utils

  function isRevealed() private view returns(bool){
    return bytes(_baseSeed).length > 0;
  }

  function random(string memory seed_) private view returns (uint256) {
    bytes memory seed = abi.encodePacked(_baseSeed, seed_);
    return uint256(keccak256(seed));
  }

  function encodeCustomTraits(uint256 token_, uint256 head_, uint256 clothes_) private pure returns(uint256){
    return (1 << 128) * token_ + (1 << 64) * head_ + clothes_;
  }

  function decodeCustomTraits(uint256 _encoded) private pure returns(uint256, uint256, uint256){
    return (_encoded / (1 << 128), (_encoded % (1 << 128)) / (1 << 64), _encoded % (1 << 64));
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
