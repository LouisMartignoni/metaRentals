const { expect } = require("chai");
const { ethers } = require("hardhat");
import { NFTStorage, File } from "nft.storage";
import dotenv from 'dotenv';

const NFT_STORAGE_KEY = process.env.NFT_STORAGE_API_KEY

describe("List a new NFT", function () {
  it("Should return store the metadata with NFT storage and mint the token", async function () {
    const propertyContract = await ethers.getContractFactory("propertyNFT");

    // deploy the contract
    const deployedPropertyContract = await propertyContract.deploy();

    await deployedPropertyContract.deployed();

    const client = new NFTStorage({ token: NFT_STORAGE_KEY });
    const metadata = await client.store(
      {
        name: 'Test',
        description: 'First test to write metadata'
      }
      );
    
    console.log("Metadata stored on Filecoin and IPFS with URL:", metadata.url);

    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
