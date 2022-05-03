// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract propertyNFT is ERC721, ERC721URIStorage, Ownable {
    using Strings for uint256;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // price for a day
    uint256 public _price = 0.01 ether;

    /**
        * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
        * name in our case is `LW3Punks` and symbol is `LW3P`.
        * Constructor for LW3P takes in the baseURI to set _baseTokenURI for the collection.
        */
    constructor () ERC721("propertyNFT", "PNT") {}


    /**
    * @dev mint allows an user to mint 1 NFT per transaction.
    */
    function mintToken(address owner, string memory metadataURI) public payable returns (uint256)
    {
        require(msg.value >= _price, "Value sent is not enough");
        _tokenIds.increment();

        uint256 id = _tokenIds.current();
        _safeMint(owner, id);
        _setTokenURI(id, metadataURI);

        return id;
    }

    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
    * @dev tokenURI overides the Openzeppelin's ERC721 implementation for tokenURI function
    * This function returns the URI from where we can extract the metadata for a given tokenId
    */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        // Here it checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
        // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given 
        // tokenId stored on IPFS
        // If baseURI is empty return an empty string
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }


    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}