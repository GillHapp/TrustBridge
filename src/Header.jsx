import React, { useState } from "react";
import { ethers } from "ethers";
import "./Header.css";

const Header = () => {
    const [walletAddress, setWalletAddress] = useState(null);

    const connectWallet = async () => {
        if (!window.ethereum) {
            alert("Please install MetaMask to connect your wallet.");
            return;
        }

        try {
            const provider = new ethers.BrowserProvider(window.ethereum);
            const network = await provider.getNetwork();
            console.log("newtworks", network)
            const CROSSFI_CHAIN_ID = 4157n;
            if (network.chainId !== CROSSFI_CHAIN_ID) {
                alert(
                    "You are not connected to the CrossFi Testnet. Please switch your network."
                );
                return;
            }

            const accounts = await provider.send("eth_requestAccounts", []);
            setWalletAddress(accounts[0]);

            alert("Wallet connected successfully!");
        } catch (error) {
            console.error("Error connecting wallet:", error);
            alert("Failed to connect wallet.");
        }
    };

    return (
        <header className="header">
            <div className="logo">
                Trust<span className="highlight">Bridge</span>
            </div>
            {walletAddress ? (
                <button className="connect-wallet-btn connected">
                    {walletAddress.slice(0, 6)}...{walletAddress.slice(-4)}
                </button>
            ) : (
                <button className="connect-wallet-btn" onClick={connectWallet}>
                    Connect Wallet
                </button>
            )}
        </header>
    );
};

export default Header;
