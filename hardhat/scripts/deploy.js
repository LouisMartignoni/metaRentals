const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  // URL from where we can extract the metadata for a LW3Punks
  //const metadataURL = "ipfs://Qmbygo38DWF1V8GttM1zy89KzyZTPU2FLUzQtiDvB7q6i5/";
  /*
  A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
  so lw3PunksContract here is a factory for instances of our LW3Punks contract.
  */
  const DaoNFTFactory = await ethers.getContractFactory("DaoNFT");

  // deploy the contract
  const DaoNFT = await DaoNFTFactory.deploy(
    //"0xB677dd9Ae9217Fbb4E3d072b9F7F68947C2a4AA6",
    "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed",
    "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f",
    "ipfs://test/",
    324
    );

  await DaoNFT.deployed();

  // print the address of the deployed contract
  console.log("Property Contract Address:", DaoNFT.address);
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
