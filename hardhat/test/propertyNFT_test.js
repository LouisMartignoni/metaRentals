const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');

describe("DAO NFT Test", function () {
  beforeEach(async function () {
    const [owner, impostor] = await ethers.getSigners();
    this.owner = owner;
    this.impostor = impostor;
    this.DaoNFT = await ethers.getContractAt(
      "DaoNFT",
      "0x64Ef30C55B779089a67e29A145A77d37BF45103B"
    );
  });

  it("should work", async function () {});

  describe("requestRandomWords", function () {

    it("Must be possible to request random if admin", async function () {
      const requestRandom =
        await this.DaoNFT.requestRandomWords();
      const receipt = await requestRandom.wait();

      //expectEvent(receipt, 'RandomnessRequested');


      const event = receipt.events.find(
        (event) => event.event === "RandomnessRequested"
      );
      console.log(event);
      const eventArgs = event.args;
      //expect(eventArgs.to).to.equal(this.owner.address);
      //expect(eventArgs.to).to.equal()
      expect(eventArgs.requestId);
      

    });
  });
});
