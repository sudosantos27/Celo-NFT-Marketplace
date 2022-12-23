# Celo NFT Marketplace DApp
Welcome to the Celo NFT Marketplace DApp! This decentralized application (dApp) allows users to buy and sell non-fungible tokens (NFTs) on the Celo blockchain.

## Features
* Browse and search for available NFTs
* View details about each NFT, including the owner, price, and metadata
* Place bids or offers to buy or sell NFTs
* User profile system to view and manage your own NFTs

## Smart Contract
The smart contract defines a marketplace for buying and selling non-fungible tokens (NFTs). An NFT is a type of digital asset that represents ownership of a unique item, such as a digital collectible, a piece of art, or a virtual real estate.

The contract has a Listing struct that stores information about a listed NFT, including its price and the address of its seller. The contract also has a listings mapping that stores all the listings indexed by the address of the NFT contract and the ID of the NFT.

The contract defines several events, including ListingCreated, ListingCancelled, ListingUpdated, and ListingPurchased, which are emitted when an NFT is listed, cancelled, updated, or purchased.

The contract also has several functions for creating, updating, and cancelling listings, as well as for purchasing listed NFTs. The createListing function allows users to list an NFT for sale by specifying its contract address, ID, and price. The updateListing function allows the owner of a listed NFT to change its price. The cancelListing function allows the owner of a listed NFT to remove it from the marketplace. The purchaseListing function allows a buyer to purchase a listed NFT by paying its price.

The contract uses several modifier functions, such as isNFTOwner, isNotListed, and isListed, to ensure that only the owner of an NFT can perform certain actions on it, and to check whether an NFT is already listed or not.

Finally, the contract uses the IERC721 interface, which defines the standard functions for interacting with NFT contracts, to check that the caller has the necessary approvals to manage an NFT on behalf of its owner, or that the contract itself has been approved to manage the NFT.

We hope you enjoy using the Celo NFT Marketplace DApp!