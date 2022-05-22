// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract DaoNFT is VRFConsumerBaseV2, ERC721URIStorage, ERC721Enumerable {
    using Strings for uint256;

    bytes32 public keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    address public vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
    uint64 private s_subscriptionId;
    
    string public carURI;

    // Default VRF Value      
    uint32 callbackGasLimit = 200000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;

    mapping(uint256 => address) requestToSender;
    uint256 public s_requestId;

    event RandomnessRequested(uint256 requestId);

    constructor(
        address vrfCoordinator,
        bytes32 keyHash,
        string memory _carURI,
        uint64 subscriptionId
        )
        ERC721("DaoNFT", "DNT") VRFConsumerBaseV2(vrfCoordinator) {
        carURI = _carURI;
        s_subscriptionId = subscriptionId;
    }

    function requestRandomWords() public {
        s_requestId = VRFCoordinatorV2Interface(vrfCoordinator).requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
            );
        requestToSender[s_requestId] = msg.sender;
        
        emit RandomnessRequested(s_requestId);
    }


    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
          // Get random image for metadata
          uint256 randomValue = (randomWords[0] % 10);
          string memory metadataURI = tokenURI(randomValue);
          uint256 tokenId = totalSupply();
          // Mint token and attributer metadata
         _safeMint(requestToSender[requestId], tokenId);
         _setTokenURI(tokenId, metadataURI);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return bytes(carURI).length > 0 ? string(abi.encodePacked(carURI, tokenId.toString(), ".png")) : "";
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}