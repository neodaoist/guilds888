// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "solmate/tokens/ERC721.sol";

contract MarketplaceNFT is ERC721 {
    //////// Constructor

    constructor() ERC721("MarketplaceNFT", "MPNFT") {}

    //////// Views

    function tokenURI(uint256 id) public view virtual override returns (string memory) {}

    //////// Actions

    function mint() external {
        _mint(msg.sender, 1);
    }
}
