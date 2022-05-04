// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract daoNFT is VRFConsumerBase, ERC721, ERC721URIStorage, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    //Chainlink variables
    // The amount of LINK to send with the request
    uint256 public fee;
    // ID of public key against which randomness is generated
    bytes32 public keyHash;
    uint256 public randomResult;
    address public VRFCoordinator;
    // mumbai: 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
    address public LinkToken;
    // mumbai: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB

    // mapping of the random number requests and the sender
    mapping(bytes32 => address) requestToSender;


    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Minting price ?
    uint256 public _price = 0.01 ether;

    /**
        * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
        * name in our case is `LW3Punks` and symbol is `LW3P`.
        * Constructor for LW3P takes in the baseURI to set _baseTokenURI for the collection.
        */
    constructor (address _VRFCoordinator, address _LinkToken, bytes32 _keyhash, baseURI)
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("DaoNFT", "DNT") {
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
        _baseTokenURI = baseURI;
    }

    // Request the random number
    function requestNewRandomCharacter() public returns (bytes32) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = msg.sender;
        return requestId;
    }

    // Get the answer back
    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();

        // Define 
        uint256 randomValue = (randomNumber % 10);

        //QmQBHarz2WFczTjz5GnhjHrbUPDnB48W5BM2v2h6HbE1rZ/1.png => baseURI/randomValue.png
        const metadataURI = tokenURI(randomValue);

        _safeMint(requestToSender[requestId], newId);
        _setTokenURI(newId, metadataURI);
    }


    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal pure override returns (string memory) {
        return _baseTokenURI;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /**
    * @dev tokenURI overides the Openzeppelin's ERC721 implementation for tokenURI function
    * This function returns the URI from where we can extract the metadata for a given tokenId
    */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {

        string memory baseURI = _baseURI();
        // Here it checks if the length of the baseURI is greater than 0, if it is return the baseURI and attach
        // the tokenId and `.json` to it so that it knows the location of the metadata json file for a given 
        // tokenId stored on IPFS
        // If baseURI is empty return an empty string
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".png")) : "";
    }


    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}