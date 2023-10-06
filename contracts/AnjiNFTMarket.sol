// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is ReentrancyGuard,Ownable{
    using Counters for Counters.Counter;

    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    uint listingPrice = 0.01 ether;
    address payable _owner;

    constructor() payable{
        _owner = payable(msg.sender);
    }

    struct MarketItem{
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    mapping(uint=>MarketItem) private idtoMarketItem;

    event MarketItemCreated(
        uint itemId,
        address nftContract,
        uint tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    function getListingPrice() public view returns(uint){
        return listingPrice;
    }

    function setListingPrice(uint newPrice) public onlyOwner{
        listingPrice = newPrice;
    }

    function CreateMarketItem(
        address nftContract,
        uint tokenId,
        uint price
    ) public payable nonReentrant{
        require(msg.value==listingPrice,"Pay the required listingPrice to list NFT in MarketPlace");
        require(price>0,"price should be atleast 1 wei to sell");

        _itemIds.increment();
        uint newItemId = _itemIds.current();

        idtoMarketItem[newItemId] = MarketItem(
            newItemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender,address(this),tokenId);

        emit MarketItemCreated(
            newItemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    function CreateMarketSale(
        address nftContract,
        uint itemId
    ) public payable nonReentrant{
        uint price = idtoMarketItem[itemId].price;
        uint tokenId = idtoMarketItem[itemId].tokenId;

        require(msg.value==price,"Pay the required price of NFT to buy it");
        idtoMarketItem[itemId].seller.transfer(msg.value);

        ERC721(nftContract).transferFrom(address(this),msg.sender,tokenId);

        idtoMarketItem[itemId].owner = payable(msg.sender);
        idtoMarketItem[itemId].sold = true;
        _itemsSold.increment();
    }

    function FetchAllNFTs() public view returns(MarketItem[] memory){
        uint totalitems = _itemIds.current();
        uint unsoldItems = _itemIds.current()-_itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItems);

        for(uint i=0;i<totalitems;i++){
            if(idtoMarketItem[i+1].owner == address(0)){
                uint currentId = i+1;
                MarketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns(MarketItem[] memory){
        uint totalItems = _itemIds.current();
        uint currentIndex = 0;
        uint itemCount = 0;

        for(uint i=0;i<totalItems;i++){
            if(idtoMarketItem[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint i=0;i<totalItems;i++){
            if(idtoMarketItem[i+1].owner == msg.sender){
                uint currentId = i+1;
                MarketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function FetchMyCreatedNFTs() public view returns(MarketItem[] memory){
        uint totalItems = _itemIds.current();
        uint currentIndex = 0;
        uint itemCount = 0;

        for(uint i=0;i<totalItems;i++){
            if(idtoMarketItem[i+1].seller == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);

        for(uint i=0;i<totalItems;i++){
            if(idtoMarketItem[i+1].seller == msg.sender){
                uint currentId = i+1;
                MarketItem storage currentItem = idtoMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
