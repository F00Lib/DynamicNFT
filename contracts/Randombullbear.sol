// SPDX-License-Identifier: NONLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Chainlink Imports
//The Chainlink Keepers Network will check our checkUpkeep() function every time 
//a new block is added to the blockchain 
//and simulate the execution of our function off-chain!
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Dev imports. This only works on a local dev network
// and will not work on any test or main livenets.
import "hardhat/console.sol";


contract BullBear is ERC721, ERC721Enumerable, ERC721URIStorage, KeeperCompatible, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    AggregatorV3Interface public pricefeed;

    uint public interval;
    uint public lastTimeStamp;
    int256 public currentPrice;

    // IPFS URIs for the dynamic nft graphics/metadata.
    string[] bullUrisIpfs = [
        "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
        "https://ipfs.io/ipfs/QmUveY3PgfLD9TahrAEH2WieCG1PfU9Ybdq9WbZe8wXwvQ?filename=party_bull.png",
        "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];
    string[] bearUrisIpfs = [
        "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
        "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bear.json",
        "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"
    ];
    event TokenUpdated(string marketTrend);

    //
    constructor(uint updateInterval, address _pricefeed) ERC721("Bull&Bear", "BBTK") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        pricefeed = AggregatorV3Interface(_pricefeed);
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public {
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // Default to a bull NFT
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);

        console.log(
            "DONE!!! minted token ",
            tokenId,
            " and assigned token url: ",
            defaultUri
        );
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory){
        upkeepNeeded = (block.timestamp-lastTimeStamp)>interval;
    }

    function performUpkeep(bytes calldata) external override{
        if((block.timestamp-lastTimeStamp)>interval){
            lastTimeStamp = block.timestamp;
            int latestPrice = getLatestPrice();
            if(latestPrice==currentPrice){
                console.log("No change ->returning");
                return;
            }
            if(latestPrice<currentPrice){
                console.log("ITS BEAR TIME");
                updateAllTokenUris("bear");
            }else{
                console.log("ITS BULL TIME");
                updateAllTokenUris("bull");
            }
            currentPrice = latestPrice;
        }else{
            console.log("INTERVAL NOT UP");
            return;
        }
    }

    function getLatestPrice() public view returns (int256){
        
        (
            //uint80 roundID
            ,
            int price,
            //uint startedAt
            ,
            //uint updatedAt
            ,
            //uint80 answeredInRound
        ) =pricefeed.latestRoundData();
        return price;
    }

    function updateAllTokenUris(string memory trend) internal{
        if(compareStrings("bear",trend)){
            console.log("UPDATING TOKEN URIS WITH","bear",trend);
            for(uint i=0;i<_tokenIdCounter.current();i++){
                _setTokenURI(i, bearUrisIpfs[0]);
            }
        }else{
            console.log("UPDATING TOKEN URIS WITH","bull",trend);
            for(uint i=0;i<_tokenIdCounter.current();i++){
                _setTokenURI(i, bearUrisIpfs[0]);
            }
        }
        emit TokenUpdated(trend);
    }

    function setPriceFeed(address newFeed) public onlyOwner{
        pricefeed = AggregatorV3Interface(newFeed);
    }

    function setInterval(uint256 newInterval)public onlyOwner{
        interval = newInterval;
    }

    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId,batchSize);
    }

     
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}