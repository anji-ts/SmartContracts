// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract anji_NFT is ERC721URIStorage{
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;
	address NFTMarket;
	constructor(address _NFTMarket) ERC721("anji_NFT","aNFT"){
		NFTMarket=_NFTMarket;
	}

    function CreateNFT(string memory tokenURI) public returns(uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender,newItemId);
        _setTokenURI(newItemId,tokenURI);
        setApprovalForAll(NFTMarket,true);
        return newItemId;
        }
}