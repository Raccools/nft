// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC721A.sol";
import "./libraries/Base64.sol";
import "./libraries/Traits.sol";
import "./interfaces/IWardrobe.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/utils/Strings.sol';

import "hardhat/console.sol";

// @author mande.eth
// @notice
contract Raccools is ERC721A, Ownable {
  using Strings for uint256;

  // mint parameters
  uint256 public constant _maxSupply = 10_000;
  uint256 public constant _cost = 0.08 ether;
  uint256 public constant _maxMintPerTx = 20;
  bool public _isRevealed;

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
  mapping(uint256 => uint256) _customHead;
  mapping(uint256 => uint256) _customClothes;

  // metadata
  string private constant _name1 = '{"name": "Raccools #';
  string private constant _attr1 = '", "attributes": [{"trait_type": "background", "value": "';
  string private constant _attr2 = '"}, {"trait_type": "fur", "value": "';
  string private constant _attr3 = '"}, {"trait_type": "face", "value": "';
  string private constant _attr4 = '"}, {"trait_type": "head", "value": "';
  string private constant _attr5 = '"}, {"trait_type": "clothes", "value": "';
  string private constant _imag1 = '"}], "image": "data:application/json;base64,';
  string private constant _imag2 = '"}';

  struct Raccool {
    string[2] background;
    string[2] fur;
    string[2] face;
    string[2] head;
    string[2] clothes;
  }

  constructor(address wardrobe_) ERC721A("Raccools", "RACCOOL"){
    _wardrobe = wardrobe_;

    Raccool memory rac = getRaccool(6965);
    console.log(rac.background[0]);
    console.log(rac.fur[0]);
    console.log(rac.face[0]);
    console.log(rac.head[0]);
    console.log(rac.clothes[0]);
  }

  modifier callerIsUser() {
    require(tx.origin == msg.sender, "Cannot call from a contract");
    _;
  }

  function mint(uint amount_) external payable callerIsUser {
    require(_totalMinted() + amount_ <= _maxSupply, "Cannot exceed max supply");
    require(amount_ <= _maxMintPerTx, "Cannot exceed 20 per tx");
    require(msg.value >= amount_ * _cost, "Insufficient funds");

    _mint(msg.sender, amount_);
  }

  function customize(uint256 tokenId_, uint256 head_, uint256 clothes_) external {
    require(msg.sender == ownerOf(tokenId_));

    uint256 currentHead = _customHead[tokenId_];
    uint256 currentClothes = _customClothes[tokenId_];

    IWardrobe wardrobe = IWardrobe(_wardrobe);

    if(head_ > 0){
      if(currentHead > 1) wardrobe.mint(msg.sender, currentHead);
      if(head_ > 1) wardrobe.burn(msg.sender, head_);
      _customHead[tokenId_] = head_;
    }

    if(clothes_ > 0){
      if(currentClothes > 1) wardrobe.mint(msg.sender, currentHead);
      if(clothes_ > 0) wardrobe.burn(msg.sender, clothes_);
      _customClothes[tokenId_] = clothes_;
    }
  }

  function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
    require(_exists(tokenId_), "Token not minted");
    return _isRevealed? tokenMetadata(tokenId_) : hiddenMetadata(tokenId_);
  }

  function tokenMetadata(uint256 tokenId_) private pure returns(string memory){
    return tokenId_.toString();
  }

  function hiddenMetadata(uint256 tokenId_) private pure returns(string memory){
    Raccool memory raccool = Raccool(["?", ""], ["?", ""], ["?", ""], ["?", ""], ["?", ""]);
    string memory attributes = raccoolAttributes(raccool);
    string memory svg = Base64.encode("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0, 0, 100, 100'><rect width='100' height='100' fill='#f9d100' /></svg>");
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

  function getRaccool(uint256 tokenId_) private view returns(Raccool memory raccool){
    raccool.background = background(generateTrait(tokenId_, _backgroundRarities));
    raccool.fur = fur(generateTrait(tokenId_, _furRarities));
    raccool.face = face(generateTrait(tokenId_, _faceRarities));
    raccool.head = head(customTrait(tokenId_, _headRarities, _customHead));
    raccool.clothes = clothes(customTrait(tokenId_, _clothesRarities, _customClothes));
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

  function customTrait(uint256 tokenId_, uint256[4] memory rarities_, mapping(uint256 => uint256) storage custom_) private view returns(uint256){
    uint256 n = custom_[tokenId_];
    if(n == 0) return generateTrait(tokenId_, rarities_);

    return n;
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

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function setProvenance(string memory sha256_) external onlyOwner {
    _provenance = sha256_;
  }

  function setBaseSeed(string memory seed_) external onlyOwner {
    _baseSeed = seed_;
  }

  function setIsRelealed(bool value_) external onlyOwner {
    _isRevealed = value_;
  }

  function withdraw() external onlyOwner {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "Ether not sent");
  }
}
