import { Contract, providers } from "ethers";
import { formatEther } from "ethers/lib/utils";
import Head from "next/head";
import { useEffect, useRef, useState } from "react";
import Web3Modal from "web3modal";
import {
  PROPERTY_ABI,
  PROPERTY_CONTRACT_ADDRESS,
  NFT_STORAGE_KEY,
} from "../constants";
import styles from "../styles/Home.module.css";
import { NFTStorage, File } from "nft.storage";
//import fs from 'fs';

export default function Home() {
  // True if waiting for a transaction to be mined, false otherwise.
  const [loading, setLoading] = useState(false);
  // True if user has connected their wallet, false otherwise
  const [walletConnected, setWalletConnected] = useState(false);
  const web3ModalRef = useRef();

  // Helper function to connect wallet
  const connectWallet = async () => {
    try {
      await getProviderOrSigner();
      setWalletConnected(true);
    } catch (error) {
      console.error(error);
    }
  };

  async function fileFromPath(filePath) {
    const content = await fs.promises.readFile(filePath)
    const type = mime.getType(filePath)
    return new File([content], path.basename(filePath), { type })
}

  // Calls the `executeProposal` function in the contract, using
  // the passed proposal ID
  const listRent = async () => {
    try {
      const signer = await getProviderOrSigner(true);
      const propertyContract = getPropertyContractInstance(signer);


      const client = new NFTStorage({ token: NFT_STORAGE_KEY });
      const metadata = await client.store({
        name: 'Test',
        description: 'First test to write metadata',
        image: new File(
          [await fs.promises.readFile('public/pesky2.jpg')],
          'MyExampleNFT.png',
          { type: 'image/jpg' }
          )
      });

      const metadataURI = metadata.url.href.replace(/^ipfs:\/\//, "");

      const [owner] = await ethers.getSigners();

      const txn = await propertyContract.mintToken(owner, metadataURI, {
        value: utils.parseEther("0.01"),
      });

      setLoading(true);
      await txn.wait();
      setLoading(false);
    } catch (error) {
      console.error(error);
      window.alert(error.data.message);
    }
  };

  // Helper function to fetch a Provider/Signer instance from Metamask
  const getProviderOrSigner = async (needSigner = false) => {
    // Connect to Metamask
    // Since we store `web3Modal` as a reference, we need to access the `current` value to get access to the underlying object
    const provider = await web3ModalRef.current.connect();
    const web3Provider = new providers.Web3Provider(provider);

    // If user is not connected to the Mumbai network, let them know and throw an error
    const { chainId } = await web3Provider.getNetwork();
    if (chainId !== 80001) {
      window.alert("Change the network to Mumbai");
      throw new Error("Change network to Mumbai");
    }

    if (needSigner) {
      const signer = web3Provider.getSigner();
      return signer;
    }
    return web3Provider;
  };

  // Helper function to return a DAO Contract instance
  // given a Provider/Signer
  const getPropertyContractInstance = (providerOrSigner) => {
    return new Contract(
      PROPERTY_CONTRACT_ADDRESS,
      PROPERTY_ABI,
      providerOrSigner
    );
  };


  // piece of code that runs everytime the value of `walletConnected` changes
  // so when a wallet connects or disconnects
  // Prompts user to connect wallet if not connected
  // and then calls helper functions to fetch the
  // DAO Treasury Balance, User NFT Balance, and Number of Proposals in the DAO
  useEffect(() => {
    if (!walletConnected) {
      web3ModalRef.current = new Web3Modal({
        network: "mumbai",
        providerOptions: {},
        disableInjectedProvider: false,
      });

      connectWallet().then(() => {
      });
    }
  }, [walletConnected]);


  /*
  renderButton: Returns a button based on the state of the dapp
*/
  const renderButton = () => {
    // If wallet is not connected, return a button which allows them to connect their wallet
    if (!walletConnected) {
      return (
        <button onClick={connectWallet} className={styles.button}>
          Connect your wallet
        </button>
      );
    }

    // If we are currently waiting for something, return a loading button
    if (loading) {
      return <button className={styles.button}>Loading...</button>;
    }

    return (
      <button className={styles.button} onClick={listRent}>
        List new rent
      </button>
    );
  };


  return (
    <div>
      <Head>
        <title>METARENTALS</title>
        <meta name="description" content="Metarentals test" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className={styles.main}>
        <div>
          <h1 className={styles.title}>Welcome to metarentals!</h1>
          <div className={styles.flex}>
          {renderButton()}
          </div>
        </div>
      </div>

      <footer className={styles.footer}>
        Made with &#10084; by Crypto Devs
      </footer>
    </div>
  );
}