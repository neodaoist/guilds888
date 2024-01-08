// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Base64} from "./Base64.sol";
import {ERC1155} from "solmate/tokens/ERC1155.sol";
import {ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";

//////////////////////////////////////////////////////////////////////////////////////////////////
//   ____________________   .     *      *        *    .                                  *     //
//  /                    \   *    .  *      .  *     .  *   . *    .  *      . *     .  *   .   //
//  !                    !     ..    *    .      *  .  ..  *    ..    *    .      *  .  ..  *   //
//  \____________________/   *    *            .      *   *   *    *     .      .      *   *    //
//           !  !                                                *         *        .           //
//           L_ !      .oooooo.    ooooo     ooo ooooo ooooo        oooooooooo.    .oooooo..o   //
//          / _)!     d8P'  `Y8b   `888'     `8' `888' `888'        `888'   `Y8b  d8P'    `Y8   //
//         / /__L    888            888       8   888   888          888      888 Y88bo.        //
//   _____/ (____)   888            888       8   888   888          888      888  `"Y8888o.    //
//          (____)   888     ooooo  888       8   888   888          888      888      `"Y88b   //
//   _____  (____)   `88.    .88'   `88.    .8'   888   888       o  888     d88' oo     .d8P   //
//        \_(____)     `Y8bood8P'      `YbodP'    o888o o888ooooood8 o888bood8P'   8""88888P'   //
//           !  !       ____________________________________________________________________    //
//           \__/                                                                               //
//////////////////////////////////////////////////////////////////////////////////////////////////

/// @notice Guilds
/// @author neodaoist.eth
/// @dev ERC1155 contract for GUILDS NFTs
contract Guilds is ERC1155, ERC721TokenReceiver {
    ////////

    uint8 private constant NUM_COMMONS = 64;
    uint8 private constant EDGE_LENGTH = 8;
    uint8 private constant MOSAIC_ID = 81;
    uint8 private constant CUBE_ID = 0;

    string private constant BASE_URI = "ipfs://bafybeibinogg7n4gyt5x5rqqogkp4fixn3d52y4rneuewp27qphe7rclfq/";

    uint16 public constant ROYALTY_PERCENTAGE_IN_BPS = 800;

    address private immutable guildsSales;
    address private immutable cubeContract;
    uint256 private immutable cubeToken;

    ////////

    string[] private GUILDS = [
        "GOLDSMITHS",
        "BLACKSMITHS",
        "EMBROIDERERS",
        "STONEMASONS",
        "GLASSBLOWERS",
        "COBBLERS",
        "CANDLEMAKERS",
        "ARROWFLETCHERS"
    ];
    string[] private STYLES = [
        "CAVEDRAWING",
        "SISTINECHAPEL",
        "STARRYNIGHT",
        "CUBISM",
        "SALVADORDALI",
        "PSYCHEDELIA",
        "ANIME",
        "SOLARPUNK"
    ];

    //////// Constructor

    constructor(address _guildsSales, address _cubeContract, uint256 _cubeToken) {
        // Store GUILDS sales and royalty receiver
        guildsSales = _guildsSales;

        // Store contract and token info for ultrarare CUBE
        cubeContract = _cubeContract;
        cubeToken = _cubeToken;
    }

    //////// Views

    /// @notice Returns collection metadata
    function contractURI() public pure returns (string memory) {
        /* solhint-disable quotes */
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string.concat(
                            '{"name": "GUILDS", ',
                            unicode'"description": "An 8x8x8 musical hypercube of audio-emotional moments, inspired by the Medieval craft guilds of Transilvania. For flute, bassoon, violin, viola, percussion. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠", ',
                            '"image": "',
                            string.concat(BASE_URI, "CUBE.jpg"),
                            '", ',
                            '"external_link": "https://github.com/neodaoist/guilds888/"}'
                        )
                    )
                )
            )
        );
    }

    /// @notice Returns token metadata
    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory name;
        string memory description;
        string memory image;
        string memory animation_url;
        string memory rarity;
        string memory guild = "GUILDS";
        string memory style = "STYLES";

        if (tokenId == CUBE_ID) {
            // CUBE
            name = "ULTRARARE CUBE";
            description =
                unicode"This 8x8x8 CUBE is the rarest of all GUILDS NFTs (1/1). It is a 3D representation of all 8 editions of all 64 common GUILDS audio-emotional moments. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠";
            image = string.concat(BASE_URI, "CUBE.jpg");
            animation_url = string.concat(BASE_URI, "CUBEvideo.mp4");
            rarity = "ULTRARARE";
        } else if (tokenId == MOSAIC_ID) {
            // MOSAIC
            name = "RARE MOSAIC";
            description =
                unicode"This 8x8 MOSAIC is a rare GUILDS NFT (Edition of 8). It is a 2D representation of all 64 common GUILDS audio-emotional moments. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠";
            image = string.concat(BASE_URI, "SHEET.jpg");
            animation_url = string.concat(BASE_URI, "SHEETvideo.mp4");
            rarity = "RARE";
        } else if (tokenId > NUM_COMMONS + EDGE_LENGTH) {
            // STYLE STRIP
            uint8 styleId = _parseStyleStrip(tokenId);
            style = STYLES[styleId - 1];

            name = string.concat("UNCOMMON ", style, " STYLE");
            description = string.concat(
                unicode"Ths 8x1 STRIP is an uncommon GUILDS NFT (Edition of 8 x 8 styles). It is a 1D representation of all 8 common GUILD audio-emotional moments of the STYLE. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠"
            );
            image = string.concat(BASE_URI, style, "-STYLESTRIP.jpg");
            animation_url = string.concat(BASE_URI, style, "-STYLESTRIPvideo.mp4");
            rarity = "UNCOMMON";
        } else if (tokenId > NUM_COMMONS) {
            // GUILD STRIP
            uint8 guildId = _parseGuildStrip(tokenId);
            guild = GUILDS[guildId - 1];

            name = string.concat("UNCOMMON ", guild, " GUILD");
            description = string.concat(
                unicode"Ths 1x8 STRIP is an uncommon GUILDS NFT (Edition of 8 x 8 guilds). It is a 1D representation of all 8 common STYLE audio-emotional moments of the GUILD. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠"
            );
            image = string.concat(BASE_URI, guild, "-GUILDSTRIP.jpg");
            animation_url = string.concat(BASE_URI, guild, "-GUILDSTRIPvideo.mp4");
            rarity = "UNCOMMON";
        } else {
            // MOMENT
            (uint8 guildId, uint8 styleId) = _parseMoment(tokenId);
            guild = GUILDS[guildId - 1];
            style = STYLES[styleId - 1];

            name = string.concat(guild, " x ", style, " MOMENT");
            description = string.concat(
                unicode"This is a common GUILDS NFT (Edition of 64). It is a single audio-emotional moment. Enjoy the MUSIC and ❤️‍🔥 MELT 🫠"
            );
            image = string.concat(BASE_URI, guild, "x", style, ".jpg");
            animation_url = string.concat(BASE_URI, guild, "x", style, "video.mp4");
            rarity = "COMMON";
        }

        /* solhint-disable quotes */
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        string.concat(
                            '{"name": "',
                            name,
                            '", "description": "',
                            description,
                            '", "image": "',
                            image,
                            '", ',
                            '"animation_url": "',
                            animation_url,
                            '", "attributes": [{"trait_type": "Rarity", "value": "',
                            rarity,
                            '"}, {"trait_type": "Guild", "value": "',
                            guild,
                            '"}, {"trait_type": "Style", "value": "',
                            style,
                            '"}]}'
                        )
                    )
                )
            )
        );
    }

    function _parseStyleStrip(uint256 tokenId) private pure returns (uint8 styleId) {
        require(tokenId > NUM_COMMONS + EDGE_LENGTH);
        require(tokenId <= NUM_COMMONS + EDGE_LENGTH + EDGE_LENGTH);

        styleId = uint8(tokenId - NUM_COMMONS - EDGE_LENGTH);
    }

    function _parseGuildStrip(uint256 tokenId) private pure returns (uint8 guildId) {
        require(tokenId > NUM_COMMONS);
        require(tokenId <= NUM_COMMONS + EDGE_LENGTH);

        guildId = uint8(tokenId - NUM_COMMONS);
    }

    function _parseMoment(uint256 tokenId) private pure returns (uint8 guildId, uint8 styleId) {
        require(tokenId > 0);
        require(tokenId <= NUM_COMMONS);

        guildId = uint8((tokenId) % EDGE_LENGTH);
        if (guildId == 0) {
            guildId = 8;
        }
        styleId = uint8((tokenId - 1) / EDGE_LENGTH) + 1;
    }

    //////// Actions

    /// @notice Melt all 8 common styles of a single guild into 1 uncommon GUILD moment strip
    function meltGuildStrip(uint8 guildId) external {
        // Burn all 8 styles of this 1 guild
        uint256[] memory ids = new uint256[](EDGE_LENGTH);
        uint256[] memory amounts = new uint256[](EDGE_LENGTH);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            ids[i] = (i * EDGE_LENGTH) + guildId;
            amounts[i] = 1;
        }
        _batchBurn(msg.sender, ids, amounts);

        // Mint 1 uncommon GUILD moment strip
        _mint(msg.sender, NUM_COMMONS + guildId, 1, "");
    }

    /// @notice Unmelt 1 uncommon GUILD moment strip into 8 common styles of a single guild
    function unmeltGuildStrip(uint8 guildId) external {
        // Burn 1 uncommon GUILD moment strip
        _burn(msg.sender, NUM_COMMONS + guildId, 1);

        // Mint all 8 styles of this 1 guild
        uint256[] memory ids = new uint256[](EDGE_LENGTH);
        uint256[] memory amounts = new uint256[](EDGE_LENGTH);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            ids[i] = (i * EDGE_LENGTH) + guildId;
            amounts[i] = 1;
        }
        _batchMint(msg.sender, ids, amounts, "");
    }

    /// @notice Melt all 8 common guilds of a single style into 1 uncommon STYLE moment strip
    function meltStyleStrip(uint8 styleId) external {
        // Burn all 8 guilds of this 1 style
        uint256[] memory ids = new uint256[](EDGE_LENGTH);
        uint256[] memory amounts = new uint256[](EDGE_LENGTH);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            ids[i] = ((styleId - 1) * EDGE_LENGTH) + i + 1;
            amounts[i] = 1;
        }
        _batchBurn(msg.sender, ids, amounts);

        // Mint 1 uncommon STYLE moment strip
        _mint(msg.sender, NUM_COMMONS + EDGE_LENGTH + styleId, 1, "");
    }

    /// @notice Unmelt 1 uncommon STYLE moment strip into 8 common guilds of a single style
    function unmeltStyleStrip(uint8 styleId) external {
        // Burn 1 uncommon STYLE moment strip
        _burn(msg.sender, NUM_COMMONS + EDGE_LENGTH + styleId, 1);

        // Mint all 8 guilds of this 1 style
        uint256[] memory ids = new uint256[](EDGE_LENGTH);
        uint256[] memory amounts = new uint256[](EDGE_LENGTH);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            ids[i] = ((styleId - 1) * EDGE_LENGTH) + i + 1;
            amounts[i] = 1;
        }
        _batchMint(msg.sender, ids, amounts, "");
    }

    /// @notice Melt all 64 common moments into 1 rare MOSAIC moment sheet
    function meltMosaicSheet() external {
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

    /// @notice Unmelt 1 rare MOSAIC moment sheet into 64 common moments
    function unmeltMosaicSheet() external {
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

    /// @notice Melt all 64 common moments into 1 ultrarare CUBE
    function meltCube() external {
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

    /// @notice Unmelt 1 ultrarare CUBE into 64 common moments
    function unmeltCube() external {
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

    //////// ERC721 Token Receiver

    /// @notice Handle ERC721 token transfer
    function onERC721Received(address, address, uint256, bytes calldata) external override returns (bytes4) {
        // Mint 64 common moments
        _unmeltCube(guildsSales);

        return ERC721TokenReceiver.onERC721Received.selector;
    }

    //////// ERC2981 Royalty Info

    /// @notice Returns royalty info for a given token and sale price
    function royaltyInfo(uint256, /*tokenId*/ uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = guildsSales;
        royaltyAmount = (salePrice * ROYALTY_PERCENTAGE_IN_BPS) / 10_000;
    }

    //////// ERC165 Supported Interfaces

    /// @dev ERC2981 royaltyInfo
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == 0x2a55205a || super.supportsInterface(interfaceId);
    }
}
