// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
    
contract AIGeneratedNFT is ERC721URIStorage, Ownable, ReentrancyGuard, IERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIds;
    
    event NFTMinted(uint256 tokenId, address owner, string tokenURI, string prompt);
    uint256 public mintingFee;
    string private _baseTokenURI = "ipfs://";

    constructor(address initialOwner) 
        ERC721("AI Generated NFT", "AINFT") 
        Ownable(initialOwner) 
    {}

    function mintNFT(
        address recipient, 
        string memory tokenURI, 
        string memory prompt
    ) public payable returns (uint256) {
        require(msg.value >= mintingFee, "Insufficient payment");
        require(bytes(tokenURI).length > 0, "Empty tokenURI");
        require(bytes(prompt).length > 0, "Empty prompt");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        emit NFTMinted(newTokenId, recipient, tokenURI, prompt);
        return newTokenId;
    }

    function setMintingFee(uint256 newFee) public onlyOwner {
        mintingFee = newFee;
    }

    function withdraw() public onlyOwner nonReentrant {
        payable(owner()).transfer(address(this).balance);
    }

    // ERC2981 Royalty Support
    function royaltyInfo(uint256, uint256 salePrice) external view override returns (address, uint256) {
        return (owner(), (salePrice * 500) / 10000); // 5%
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}