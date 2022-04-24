// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract FakeNFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; //total number of items ever created
    Counters.Counter private _itemsSold;

    //Price to list new property
    uint256 listingPrice = 0.025 ether;


    /// @dev Maintain a mapping of Fake TokenID to Owner addresses
    mapping(uint256 => address) public tokens;

    // Struct when listing a property
    struct Property {
        uint256 tokenId;
        address nftContract;
        uint256 nbGuest;
        uint256 nbBed;
        uint256 size;
        string description;
        string title;
        uint256 latitude;
        uint256 longitude;
        string city;
        uint256 price;
        string[] datesBooked;
        address renter;
    }

    //Mapping property ID -> property
    mapping(uint256 => Property) public idToProperty;

    //Event when a new listing is done
    event newListing (
        uint256 tokenId,
        address nftContract,
        uint256 maxGuests,
        uint256 nbBed,
        uint256 size,
        string description,
        string title,
        uint256 latitude,
        uint256 longitude,
        string city,
        uint256 price,
        string[] datesBooked,
        address renter
    );

    // Event when a reservation is made
    event newReservation (
        string[] datesBooked,
        uint256 id,
        address booker,
        string city,
        string imgUrl 
    );

    //function to list new property
    function listNewProperty(
        address nftContract,
        uint256 dailyPrice,
        uitn256 tokenId,
        uint256 maxGuests,
        uint256 nbBed,
        uint256 size,
        string description,
        string title,
        uint256 latitude,
        uint256 longitude,
        string city,
        uint256 price,
        string[] datesBooked,
        address renter
        ) public payable nonReentrant{

            require(dailyPrice > 0, "Price must be above zero");
            require(msg.value == listingPrice, "Price must be equal to listing price");

            _itemIds.increment(); //add 1 to the total number of items ever created
            uint256 propId = _itemIds.current();

            idMarketItem[itemId] = Property(
                tokenId,
                nftContract,
                maxGuests,
                nbBed,
                size,
                description,
                title,
                latitude,
                longitude,
                city,
                dailyPrice,
                datesBooked,
                payable(msg.sender)
         );

            //transfer ownership of the nft to the contract itself
            IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

            //Emit event
             emit newListing (
                tokenId,
                nftContract,
                maxGuests,
                nbBed,
                size,
                description,
                title,
                latitude,
                longitude,
                city,
                dailyPrice,
                datesBooked,
                payable(msg.sender)
            );

        }
}