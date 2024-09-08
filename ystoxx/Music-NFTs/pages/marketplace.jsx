import Card1 from '../components/Card1';
import Navbar from '../components/Navbar';
import { useState, useEffect } from 'react';
import { getProviderOrSigner } from '../store/util';
import { Contract } from 'ethers';
import { abi, NFT_CONTRACT_ADDRESS } from '../constants';
import useweb3store from '../store/web3store';

export default function Marketplace() {
    const [marketItems, setMarketItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const { web3modalRef } = useweb3store((state) => ({
        web3modalRef: state.web3Modal,
    }));

    const getMarketItems = async () => {
        try {
            const provider = await getProviderOrSigner(web3modalRef, false);
            console.log("Provider:", provider);

            const network = await provider.getNetwork();
            console.log("Network:", network);

            console.log("NFT_CONTRACT_ADDRESS:", NFT_CONTRACT_ADDRESS);
            console.log("ABI:", abi);

            const nftContract = new Contract(NFT_CONTRACT_ADDRESS, abi, provider);
            console.log("Contract instance created");

            // Check if the contract is properly initialized
            if (!nftContract.functions || !nftContract.functions.fetchMarketItems) {
                throw new Error('Contract not properly initialized or missing fetchMarketItems function');
            }

            console.log("Calling fetchMarketItems...");
            const _marketItems = await nftContract.fetchMarketItems();
            console.log("fetchMarketItems result:", _marketItems);

            // Ensure _marketItems is an array before setting state
            if (Array.isArray(_marketItems)) {
                setMarketItems(_marketItems);
            } else {
                throw new Error('Unexpected response format from fetchMarketItems');
            }
        } catch (error) {
            console.error("Detailed error:", error);
            let errorMessage = 'Error fetching market items NFTs: ';
            if (error.reason) {
                errorMessage += error.reason;
            } else if (error.message) {
                errorMessage += error.message;
            } else {
                errorMessage += 'Unknown error occurred';
            }
            setError(errorMessage);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        getMarketItems();
    }, [web3modalRef]);

    return (
        <div className='bg-bgBlue min-h-screen px-8 md:px-12'>
            <Navbar />

            <h1 className='mb-12 text-center text-transparent text-2xl md:text-4xl bg-rainbow bg-clip-text font-display'>
                Marketplace
            </h1>
            {loading && <p className='mt-5 text-white text-center'>Loading...</p>}
            {error && <p className='mt-5 text-red-500 text-center'>{error}</p>}
            {!loading && marketItems.length === 0 && (
                <p className='mt-5 text-white text-center'>No MNFTs in market yet!</p>
            )}
            <div className='grid gap-8 pb-5 grid-cols-1 sm:grid-cols-2 md:grid-cols-4'>
                {marketItems.map((nft) => {
                    return <Card1 nft={nft} key={nft.tokenId} />;
                })}
            </div>
        </div>
    );
}