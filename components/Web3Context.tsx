import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { ethers } from 'ethers';
import Web3Modal from 'web3modal';
import DonationPlatform from '../artifacts/contracts/DonationPlatform.sol/DonationPlatform.json';
import DonaToken from '../artifacts/contracts/DonaToken.sol/DonaToken.json';

declare global {
  interface Window {
    ethereum?: any;
  }
}

interface Web3ContextType {
  account: string | null;
  contract: ethers.Contract | null;
  tokenContract: ethers.Contract | null;
  provider: ethers.providers.Web3Provider | null;
  connectWallet: () => Promise<void>;
  loading: boolean;
}

const Web3Context = createContext<Web3ContextType>({
  account: null,
  contract: null,
  tokenContract: null,
  provider: null,
  connectWallet: async () => {},
  loading: false,
});

export const useWeb3 = () => useContext(Web3Context);

interface Web3ProviderProps {
  children: ReactNode;
}

export const Web3Provider: React.FC<Web3ProviderProps> = ({ children }) => {
  const [account, setAccount] = useState<string | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [tokenContract, setTokenContract] = useState<ethers.Contract | null>(null);
  const [provider, setProvider] = useState<ethers.providers.Web3Provider | null>(null);
  const [loading, setLoading] = useState(false);

  const connectWallet = async () => {
    try {
      setLoading(true);
      const web3Modal = new Web3Modal({
        cacheProvider: true,
        providerOptions: {},
      });

      const instance = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(instance);
      const signer = provider.getSigner();
      const account = await signer.getAddress();

      // Replace with your deployed contract addresses
      const platformAddress = "YOUR_PLATFORM_CONTRACT_ADDRESS";
      const tokenAddress = "YOUR_TOKEN_CONTRACT_ADDRESS";

      const platformContract = new ethers.Contract(
        platformAddress,
        DonationPlatform.abi,
        signer
      );

      const donaTokenContract = new ethers.Contract(
        tokenAddress,
        DonaToken.abi,
        signer
      );

      setProvider(provider);
      setAccount(account);
      setContract(platformContract);
      setTokenContract(donaTokenContract);
    } catch (error) {
      console.error("Error connecting wallet:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", (accounts: string[]) => {
        setAccount(accounts[0] || null);
      });
    }
  }, []);

  return (
    <Web3Context.Provider
      value={{
        account,
        contract,
        tokenContract,
        provider,
        connectWallet,
        loading,
      }}
    >
      {children}
    </Web3Context.Provider>
  );
}; 