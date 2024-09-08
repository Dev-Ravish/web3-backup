// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT1155 is ERC1155, Ownable {
    event Log(string message);

    uint256 private _tokenIds;
    uint256 private _itemsSold;

    mapping(uint256 => string) internal _tokenURIs;
    mapping(uint256 => MarketItem) private idToMarketItem;
    mapping(address => mapping(uint256 => bool)) private userHasItem;

    struct MarketItem {
        uint256 tokenId;
        address payable creator;
        uint256 price;
        uint256 amount;
        string tokenUri;
    }

    event MarketItemCreated(
        uint256 tokenId,
        address payable creator,
        uint256 price,
        uint256 amount
    );

    constructor() ERC1155("") Ownable(msg.sender) {}

    function mintToken(
        string memory tokenURI,
        uint256 amount,
        uint256 price
    ) public {
        require(price > 0, "Price must be at least 1 wei");

        _tokenIds++;
        uint256 newItemId = _tokenIds;

        _mint(msg.sender, newItemId, amount, "");
        _setTokenUri(newItemId, tokenURI);

        idToMarketItem[newItemId] = MarketItem(
            newItemId,
            payable(msg.sender),
            price,
            amount,
            tokenURI
        );

        emit MarketItemCreated(
            newItemId,
            payable(msg.sender),
            price,
            amount
        );
    }

    function createMarketSale(uint256 tokenId) public payable {
        uint256 _price = idToMarketItem[tokenId].price;
        uint256 _amount = idToMarketItem[tokenId].amount;
        address _creator = idToMarketItem[tokenId].creator;

        require(_amount > 1, "This MNFT is sold out");
        require(
            msg.value >= _price,
            "Please submit the asking price in order to complete the purchase"
        );
        require(!userHasItem[msg.sender][tokenId], "You already own this NFT");

        userHasItem[msg.sender][tokenId] = true;
        idToMarketItem[tokenId].amount = _amount - 1;

        safeTransferFrom(_creator, msg.sender, tokenId, 1, "");

        (bool sent, ) = _creator.call{value: msg.value}("");
        require(sent, "Eth not sent to creator");
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds;
        uint256 currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            MarketItem storage currentItem = idToMarketItem[i];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (userHasItem[msg.sender][i]) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (userHasItem[msg.sender][i]) {
                MarketItem storage currentItem = idToMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i].creator == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i].creator == msg.sender) {
                MarketItem storage currentItem = idToMarketItem[i];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function _setTokenUri(uint256 tokenId, string memory tokenURI) private {
        _tokenURIs[tokenId] = tokenURI;
    }

    function onERC1155Received(
        address /*_operator*/,
        address /*_from*/,
        uint256 /*_id*/,
        uint256 /*_value*/,
        bytes calldata /*_data*/
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }
}