// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace {
    
    struct Listing {
        uint256 price;
        address seller;
        }

    mapping(address => mapping(uint256 => Listing)) public listings;

    // Requires the msg.sender is the owner of the specified NFT
    modifier isNFTOwner(address nftAddress, uint256 tokenId) {
        require(
            IERC721(nftAddress).ownerOf(tokenId) == msg.sender,
            "MRKT: Not the owner"
        );
        _;
    }

    // Requires that the specified NFT is not already listed for sale
    modifier isNotListed(address nftAddress, uint256 tokenId) {
        require(
            listings[nftAddress][tokenId].price == 0,
            "MRKT: Already listed"
        );
        _;
    }

    // Requires that the specified NFT is already listed for sale
    modifier isListed(address nftAddress, uint256 tokenId) {
        require(listings[nftAddress][tokenId].price > 0, "MRKT: Not listed");
        _;
    }


    event ListingCreated(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address seller
    );

    event ListingCanceled(address nftAddress, uint256 tokenId, address seller);

    event ListingUpdated(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice,
        address seller
    );

    event ListingPurchased(
        address nftAddress,
        uint256 tokenId,
        address seller,
        address buyer
    );


    /**
    * @title Create a new listing for an NFT on the marketplace
    * @notice Creates a new listing for an NFT on the marketplace, and emits a
    * ListingCreated event to signal the creation of the new listing
    * @dev The function checks that the NFT is not already listed, that the caller
    * is the owner of the NFT, and that the price is greater than zero. The function
    * also checks that the caller has been approved to manage the NFT on behalf of
    * the owner, or that the contract itself has been approved to manage the NFT.
    * @param nftAddress The address of the contract that manages the NFT
    * @param tokenId The unique identifier of the NFT being listed
    * @param price The price at which the NFT is being offered for sale
    * @return None
    */

    /** The function is marked as external, which means it can be called by other 
    contracts or by users via a transaction. The function also has two modifier functions, 
    isNotListed and isNFTOwner, which are used to ensure that the NFT is not already listed 
    and that the caller is the owner of the NFT, respectively. */

    function createListing(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        isNotListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        require(price > 0, "MRKT: Price must be > 0");
        IERC721 nftContract = IERC721(nftAddress);
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) ||
                nftContract.getApproved(tokenId) == address(this),
            "MRKT: No approval for NFT"
        );
        listings[nftAddress][tokenId] = Listing({
            price: price,
            seller: msg.sender
        });

        emit ListingCreated(nftAddress, tokenId, price, msg.sender);
    }

    /** 
    * @dev Removes a listed NFT from the market.
    * @notice The NFT must be listed and the caller must be the owner of the NFT.
    * @param nftAddress The address of the NFT contract.
    * @param tokenId The ID of the NFT token to be removed from the market.
    * The NFT with ID `tokenId` must be listed.
    * The caller must be the owner of the NFT with ID `tokenId`.
    * The NFT with ID `tokenId` will no longer be listed.
    * emits ListingCanceled(nftAddress, tokenId, msg.sender) when the listing is successfully canceled.
     */

    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        // Delete the Listing struct from the mapping
        // Freeing up storage saves gas!
        delete listings[nftAddress][tokenId];

        // Emit the event
        emit ListingCanceled(nftAddress, tokenId, msg.sender);
    }

    /**
    @dev Updates the price of a listed NFT.
    @notice The NFT must be listed and the caller must be the owner of the NFT.
    @param nftAddress The address of the NFT contract.
    @param tokenId The ID of the NFT token whose price is being updated.
    @param newPrice The new price for the NFT.
    The NFT with ID `tokenId` must be listed.
    The caller must be the owner of the NFT with ID `tokenId`.
    The `newPrice` must be greater than 0.
    The price of the NFT with ID `tokenId` will be updated to `newPrice`.
    ListingUpdated(nftAddress, tokenId, newPrice, msg.sender) when the listing is successfully updated. */

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId) {
        // Cannot update the price to be < 0
        require(newPrice > 0, "MRKT: Price must be > 0");

        // Update the listing price
        listings[nftAddress][tokenId].price = newPrice;

        // Emit the event
        emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
    }

    /**
    @dev Purchases a listed NFT from the market.
    @notice The NFT must be listed and the caller must send the correct amount of ETH to the contract.
    @param nftAddress The address of the NFT contract.
    @param tokenId The ID of the NFT token being purchased.
    The NFT with ID `tokenId` must be listed.
    The caller must send the correct amount of ETH as specified in the listing.
    The NFT with ID `tokenId` will be transferred from the seller to the caller.
    The ETH sent by the caller will be transferred to the seller.
    emits ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender) when the purchase is successful. */

    function purchaseListing(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        // Load the listing in a local copy
        Listing memory listing = listings[nftAddress][tokenId];

        // Buyer must have sent enough ETH
        require(msg.value == listing.price, "MRKT: Incorrect ETH supplied");

        // Delete listing from storage, save some gas
        delete listings[nftAddress][tokenId];

        // Transfer NFT from seller to buyer
        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        // Transfer ETH sent from buyer to seller
        (bool sent, ) = payable(listing.seller).call{value: msg.value}("");
        require(sent, "Failed to transfer eth");

        // Emit the event
        emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
    }
}