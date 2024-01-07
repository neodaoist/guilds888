// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC1155, ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

contract Guilds is ERC1155, ERC1155TokenReceiver, ERC721TokenReceiver {
    uint256 public number;

    ///////// Views

    function uri(uint256 id) public view virtual override returns (string memory) {}

    ///////// Actions

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }

    ///////// ERC1155 Token Receiver

    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        virtual
        override
        returns (bytes4)
    {
        // TODO
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        virtual
        override
        returns (bytes4)
    {
        // TODO
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }

    ///////// ERC721 Token Receiver

    function onERC721Received(address, address, uint256, bytes calldata) external virtual override returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }

    ///////// ERC2981 Royalty Info

    /// @notice Returns royalty info for a given token and sale price.
    /// @return receiver The author's address.
    /// @return royaltyAmount A fixed 8% royalty based on the sale price.
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {}

    ///////// ERC165 Supported Interfaces

    /// @dev see ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == 0x2a55205a // ERC2981 -- royaltyInfo
            || interfaceId == 0x01ffc9a7 // ERC165 -- supportsInterface
            || interfaceId == 0x80ac58cd // ERC721 -- Non-Fungible Tokens
            || interfaceId == 0x5b5e139f; // ERC721Metadata
    }
}
