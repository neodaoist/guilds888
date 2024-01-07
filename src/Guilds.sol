// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {ERC1155, ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

contract Guilds is ERC1155, ERC1155TokenReceiver, ERC721TokenReceiver {
    ////////

    enum Guild {
        BLANK,
        GOLDSMITHS,
        BLACKSMITHS,
        EMBROIDERERS,
        STONEMASONS,
        GLASSBLOWERS,
        COBBLERS,
        CANDLEMAKERS,
        ARROWFLETCHERS
    }

    enum Style {
        BLANK,
        CAVE_DRAWING,
        SISTINE_CHAPEL,
        STARRY_NIGHT,
        CUBISM,
        SALVADOR_DALI,
        PSYCHEDELIA,
        ANIME,
        SOLARPUNK
    }

    struct Content {
        string title;
        string description;
        string image;
        string animation_url;
    }

    ////////

    address private immutable GUILDS_SALES;
    address private immutable CUBE_CONTRACT;
    uint256 private immutable CUBE_TOKEN;

    uint8 private constant EDGE_LENGTH = 8;
    uint8 private constant NUM_COMMONS = 64;
    uint8 private constant MOSAIC_ID = 81;
    uint8 private constant CUBE_ID = 0;

    uint16 public constant ROYALTY_PERCENTAGE_IN_BPS = 800;

    ////////

    /// @dev tokenID => Content
    mapping(uint256 => Content) public content;

    //////// Constructor

    constructor(address guildsSales, address cubeContract, uint256 cubeToken) {
        // Store GUILDS sales and royalty receiver
        GUILDS_SALES = guildsSales;

        // Store contract and token info for ultrarare CUBE
        CUBE_CONTRACT = cubeContract;
        CUBE_TOKEN = cubeToken;

        // Store content for common MOMENTS
        for (uint256 i = 1; i <= 8; i++) {
            for (uint256 j = 1; j <= 8; j++) {
                Guild guild = Guild(i);
                Style style = Style(j);

                content[i * j] = Content({title: "", description: "", image: "", animation_url: ""});
            }
        }

        // Store content for uncommon STRIPS

        // Store content for rare SHEET
    }

    //////// Views

    function uri(uint256 id) public view virtual override returns (string memory) {}

    function contractURI() public pure returns (string memory) {
        string memory json = '{"name": "Opensea Creatures","description":"..."}';
        return string.concat("data:application/json;utf8,", json);
    }

    // /// @notice Returns collection metadata
    // function contractURI() public pure returns (string memory) {
    //     /* solhint-disable quotes */
    //     return string(
    //         abi.encodePacked(
    //             "data:application/json;base64,",
    //             Utils.encode(
    //                 bytes(
    //                     string(
    //                         abi.encodePacked(
    //                             '{"name": "XYZ", ',
    //                             '"description": "XYZ", ',
    //                             '"image": "XYZ", ',
    //                             '"external_link": "XYZ"}'
    //                         )
    //                     )
    //                 )
    //             )
    //         )
    //     );
    // }

    // /// @notice Returns token metadata
    // function uri(uint256 tokenId) public view override returns (string memory) {
    //     /* solhint-disable quotes */
    //     return string(
    //         abi.encodePacked(
    //             "data:application/json;base64,",
    //             Utils.encode(
    //                 bytes(
    //                     string(
    //                         abi.encodePacked(
    //                             '{"name": "XYZ", ',
    //                             '"description": "XYZ", ',
    //                             '"image": "XYZ", ',
    //                             '"animation_url": "XYZ", ',
    //                             '"external_url": "XYZ", ',
    //                             '"background_color": "XYZ"}'
    //                         )
    //                     )
    //                 )
    //             )
    //         )
    //     );
    // }

    //////// Actions

    // Melt all 8 common styles of a single guild into 1 uncommon GUILD moment strip

    function meltGuildStrip(uint8 guildId) external {}

    // Unmelt 1 uncommon GUILD moment strip into 8 common styles of a single guild

    function unmeltGuildStrip(uint8 guildId) external {}

    // Melt all 8 common guilds of a single style into 1 uncommon STYLE moment strip

    function meltStyleStrip(uint8 styleId) external {}

    // Unmelt 1 uncommon STYLE moment strip into 8 common guilds of a single style

    function unmeltStyleStrip(uint8 styleId) external {}

    // Melt all 64 common moments into 1 rare MOSAIC moment sheet

    function meltMosaicSheet() external {
        //////// Effects
        // Burn 64x1 common moments
        uint256[] memory ids = new uint256[](NUM_COMMONS);
        uint256[] memory amounts = new uint256[](NUM_COMMONS);
        for (uint256 i = 0; i < NUM_COMMONS; i++) {
            ids[i] = i + 1;
            amounts[i] = 1;
        }
        _batchBurn(msg.sender, ids, amounts);

        // Mint 1 rare MOSAIC moment sheet
        _mint(msg.sender, MOSAIC_ID, 1, "");
    }

    // Unmelt 1 rare MOSAIC moment sheet into 64 common moments

    function unmeltMosaicSheet() external {
        //////// Effects
        // Burn 1 rare MOSAIC moment sheet
        _burn(msg.sender, MOSAIC_ID, 1);

        // Mint 64x1 common moments
        uint256[] memory ids = new uint256[](NUM_COMMONS);
        uint256[] memory amounts = new uint256[](NUM_COMMONS);
        for (uint256 i = 0; i < NUM_COMMONS; i++) {
            ids[i] = i + 1;
            amounts[i] = 1;
        }
        _batchMint(msg.sender, ids, amounts, "");
    }

    // Melt all 64 common moments into 1 ultrarare CUBE

    function meltCube() external {
        //////// Effects
        // Burn all 64x8 common moments
        uint256[] memory ids = new uint256[](NUM_COMMONS);
        uint256[] memory amounts = new uint256[](NUM_COMMONS);
        for (uint256 i = 0; i < NUM_COMMONS; i++) {
            ids[i] = i + 1;
            amounts[i] = EDGE_LENGTH;
        }
        _batchBurn(msg.sender, ids, amounts);

        // Mint 1 ultrarare CUBE
        _mint(msg.sender, CUBE_ID, 1, "");
    }

    // Unmelt 1 ultrarare CUBE into 64 common moments

    function unmeltCube() public {
        //////// Effects
        // Mint all 64x8 common moments
        _unmeltCube(msg.sender);

        // Burn 1 ultrarare CUBE
        _burn(msg.sender, CUBE_ID, 1);
    }

    function _unmeltCube(address recipient) private {
        uint256[] memory ids = new uint256[](NUM_COMMONS);
        uint256[] memory amounts = new uint256[](NUM_COMMONS);
        for (uint256 i = 0; i < NUM_COMMONS; i++) {
            ids[i] = i + 1;
            amounts[i] = EDGE_LENGTH;
        }
        _batchMint(recipient, ids, amounts, "");
    }

    //////// ERC1155 Token Receiver

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

    //////// ERC721 Token Receiver

    function onERC721Received(address, address, uint256, bytes calldata) external virtual override returns (bytes4) {
        // Mint 64 common moments
        _unmeltCube(GUILDS_SALES);

        return ERC721TokenReceiver.onERC721Received.selector;
    }

    //////// ERC2981 Royalty Info

    /// @notice Returns royalty info for a given token and sale price.
    /// @return receiver The author's address.
    /// @return royaltyAmount A fixed 8% royalty based on the sale price.
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {}

    //////// ERC165 Supported Interfaces

    /// @dev see ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == 0x2a55205a // ERC2981 -- royaltyInfo
            || interfaceId == 0x01ffc9a7 // ERC165 -- supportsInterface
            || interfaceId == 0x80ac58cd // ERC721 -- Non-Fungible Tokens
            || interfaceId == 0x5b5e139f; // ERC721Metadata
    }
}
