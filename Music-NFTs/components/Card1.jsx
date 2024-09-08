import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

export default function Card1({ nft }) {
	const [nftData, setNftData] = useState(null);
	const [loading, setLoading] = useState('Loading...');

	const getNftData = async () => {
		try {
			console.log("Fetching from:", nft.tokenUri);
			const res = await fetch(nft.tokenUri);
			if (!res.ok) {
				throw new Error(`HTTP error! status: ${res.status}`);
			}
			const data = await res.json();
			setNftData(data);
			setLoading(nft.amount.toNumber() === 0 ? 'Sold Out!' : '');
		} catch (error) {
			console.error("Error fetching NFT data:", error);
			setLoading('Error fetching NFT');
		}
	};

	useEffect(() => {
		getNftData();
	}, [nft]);

	if (loading) {
		return <div>{loading}</div>;
	}

	if (!nftData) {
		return null;
	}

	return (
		<div>
			<img src={nftData.image} alt={nftData.name} />
			<h2>{nftData.name}</h2>
			<p>{nftData.description}</p>
			<p>Price: {ethers.utils.formatEther(nft.price)} ETH</p>
			{/* Add more details and buy button as needed */}
		</div>
	);
}
