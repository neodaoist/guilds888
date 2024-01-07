// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {MarketplaceNFT} from "./MarketplaceNFT.sol";
import {Guilds} from "../src/Guilds.sol";

contract GuildsTest is Test {
    ////////

    MarketplaceNFT public cube;
    Guilds public guilds;

    uint8 private constant EDGE_LENGTH = 8;
    uint8 private constant NUM_COMMONS = 64;
    uint8 private constant MOSAIC_ID = 81;
    uint8 private constant CUBE_ID = 0;

    uint8 private constant RANDOM_MOMENT = 8;
    uint8 private constant RANDOM_OFFSET = 3;

    uint8 private constant GUILD_ID_BLACKSMITHS = 2;
    uint8 private constant STYLE_ID_SISTINE_CHAPEL = 2;

    address private constant GUILDS_DEPLOYER = address(0xA1);
    address private constant GUILDS_SALES = address(0xA2);
    address private constant NEO_ETH = address(0xA3);
    address private constant FAN_ETH = address(0xA4);

    ////////

    function setUp() public {
        vm.label(GUILDS_DEPLOYER, "Guilds Deployer");
        vm.label(GUILDS_SALES, "Guilds Sales");
        vm.label(NEO_ETH, "Neodaoist.eth");
        vm.label(FAN_ETH, "ClassicalMusicFan.eth");

        // Deploy contracts
        vm.prank(NEO_ETH);
        cube = new MarketplaceNFT();
        vm.prank(GUILDS_DEPLOYER);
        guilds = new Guilds(GUILDS_SALES, address(cube), 1);

        // Mint initial 8x8x8 ultrarare CUBE
        vm.prank(GUILDS_SALES);
        cube.mint();

        assertEq(cube.balanceOf(GUILDS_SALES), 1);
        assertEq(cube.ownerOf(1), GUILDS_SALES);

        // Send ultrarare CUBE to meltable contract, first time and only time
        vm.prank(GUILDS_SALES);
        cube.safeTransferFrom(GUILDS_SALES, address(guilds), 1);
    }

    //////// Initial Marketplace

    function test_initialSendCube() public {
        // Then
        assertEq(cube.balanceOf(address(guilds)), 1);
        assertEq(cube.ownerOf(1), address(guilds));

        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), EDGE_LENGTH);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, CUBE_ID), 0);
    }

    //////// Meltable Functions

    // Melt all 8 common styles of a single guild into 1 uncommon GUILD moment strip

    function test_meltGuildStrip() public {
        // Do this for BLACKSMITHS, Guild #2
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS, 1, "");
        }
        vm.stopPrank();

        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS), EDGE_LENGTH - 1);
            assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS), 1);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + GUILD_ID_BLACKSMITHS), 0);

        // When
        vm.prank(FAN_ETH);
        guilds.meltGuildStrip(GUILD_ID_BLACKSMITHS);

        // Then
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS), 0);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + GUILD_ID_BLACKSMITHS), 1);
    }

    function test_meltGuildStrip_many() public {
        // Do this for all 8 guilds
        for (uint8 guildId = 1; guildId <= EDGE_LENGTH; guildId++) {
            // Given
            vm.startPrank(GUILDS_SALES);
            for (uint256 i = 0; i < EDGE_LENGTH; i++) {
                guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, (i * EDGE_LENGTH) + guildId, 1, "");
            }
            vm.stopPrank();

            for (uint256 i = 0; i < EDGE_LENGTH; i++) {
                assertEq(guilds.balanceOf(GUILDS_SALES, (i * EDGE_LENGTH) + guildId), EDGE_LENGTH - 1);
                assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + guildId), 1);
            }
            assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + guildId), 0);

            // When
            vm.prank(FAN_ETH);
            guilds.meltGuildStrip(guildId);

            // Then
            for (uint256 i = 0; i < EDGE_LENGTH; i++) {
                assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + guildId), 0);
            }
            assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + guildId), 1);
        }
    }

    function testRevert_meltGuildStrip_missingStyle() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS, 1, "");
        }
        vm.stopPrank();

        vm.prank(FAN_ETH);
        guilds.safeTransferFrom(FAN_ETH, GUILDS_SALES, (RANDOM_OFFSET * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS, 1, "");

        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.meltGuildStrip(GUILD_ID_BLACKSMITHS);
    }

    // Unmelt 1 uncommon GUILD moment strip into 8 common styles of a single guild

    function test_unmeltGuildStrip() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS, 1, "");
        }
        vm.stopPrank();

        vm.prank(FAN_ETH);
        guilds.meltGuildStrip(GUILD_ID_BLACKSMITHS);

        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS), 0);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + GUILD_ID_BLACKSMITHS), 1);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltGuildStrip(GUILD_ID_BLACKSMITHS);

        // Then
        for (uint256 i = 0; i < EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, (i * EDGE_LENGTH) + GUILD_ID_BLACKSMITHS), 1);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + GUILD_ID_BLACKSMITHS), 0);
    }

    function testRevert_unmeltGuildStrip_missingGuildStrip() public {
        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltGuildStrip(GUILD_ID_BLACKSMITHS);
    }

    // Melt all 8 common guilds of a single style into 1 uncommon STYLE moment strip

    function test_meltStyleStrip() public {
        // Do this for SISTINE CHAPEL, Style #2
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i, 1, "");
        }
        vm.stopPrank();

        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i), EDGE_LENGTH - 1);
            assertEq(guilds.balanceOf(FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i), 1);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + EDGE_LENGTH + STYLE_ID_SISTINE_CHAPEL), 0);

        // When
        vm.prank(FAN_ETH);
        guilds.meltStyleStrip(STYLE_ID_SISTINE_CHAPEL);

        // Then
        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i), 0);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + EDGE_LENGTH + STYLE_ID_SISTINE_CHAPEL), 1);
    }

    function test_meltStyleStrip_many() public {
        // Do this for all 8 styles
        for (uint8 styleId = 1; styleId <= EDGE_LENGTH; styleId++) {
            // Given
            vm.startPrank(GUILDS_SALES);
            for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
                guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, ((styleId - 1) * EDGE_LENGTH) + i, 1, "");
            }
            vm.stopPrank();

            for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
                assertEq(guilds.balanceOf(GUILDS_SALES, ((styleId - 1) * EDGE_LENGTH) + i), EDGE_LENGTH - 1);
                assertEq(guilds.balanceOf(FAN_ETH, ((styleId - 1) * EDGE_LENGTH) + i), 1);
            }
            assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + EDGE_LENGTH + styleId), 0);

            // When
            vm.prank(FAN_ETH);
            guilds.meltStyleStrip(styleId);

            // Then
            for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
                assertEq(guilds.balanceOf(FAN_ETH, ((styleId - 1) * EDGE_LENGTH) + i), 0);
            }
            assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + EDGE_LENGTH + styleId), 1);
        }
    }

    function testRevert_meltStyleStrip_missingGuild() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i, 1, "");
        }
        vm.stopPrank();

        vm.prank(FAN_ETH);
        guilds.safeTransferFrom(
            FAN_ETH, GUILDS_SALES, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + RANDOM_OFFSET, 1, ""
        );

        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.meltStyleStrip(STYLE_ID_SISTINE_CHAPEL);
    }

    // Unmelt 1 uncommon STYLE moment strip into 8 common guilds of a single style

    function test_unmeltStyleStrip() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i, 1, "");
        }
        vm.stopPrank();

        vm.prank(FAN_ETH);
        guilds.meltStyleStrip(STYLE_ID_SISTINE_CHAPEL);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltStyleStrip(STYLE_ID_SISTINE_CHAPEL);

        // Then
        for (uint256 i = 1; i <= EDGE_LENGTH; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, ((STYLE_ID_SISTINE_CHAPEL - 1) * EDGE_LENGTH) + i), 1);
        }
        assertEq(guilds.balanceOf(FAN_ETH, NUM_COMMONS + EDGE_LENGTH + STYLE_ID_SISTINE_CHAPEL), 0);
    }

    function testRevert_unmeltStyleStrip_missingStyleStrip() public {
        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltStyleStrip(STYLE_ID_SISTINE_CHAPEL);
    }

    // Melt all 64 common moments into 1 rare MOSAIC moment sheet

    function test_meltMosaicSheet() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, i, 1, "");
        }
        vm.stopPrank();

        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), EDGE_LENGTH - 1);
            assertEq(guilds.balanceOf(FAN_ETH, i), 1);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, MOSAIC_ID), 0);

        // When
        vm.prank(FAN_ETH);
        guilds.meltMosaicSheet();

        // Then
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, i), 0);
        }
        assertEq(guilds.balanceOf(FAN_ETH, MOSAIC_ID), 1);
    }

    function testRevert_meltMosaicSheet_missingToken() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, i, 1, "");
        }
        vm.stopPrank();

        vm.prank(FAN_ETH);
        guilds.safeTransferFrom(FAN_ETH, GUILDS_SALES, RANDOM_MOMENT, 1, "");

        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.meltMosaicSheet();
    }

    // Unmelt 1 rare MOSAIC moment sheet into 64 common moments

    function test_unmeltMosaicSheet() public {
        // Given
        vm.startPrank(GUILDS_SALES);
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, i, 1, "");
        }
        vm.stopPrank();
        vm.prank(FAN_ETH);
        guilds.meltMosaicSheet();

        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, i), 0);
        }
        assertEq(guilds.balanceOf(FAN_ETH, MOSAIC_ID), 1);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltMosaicSheet();

        // Then
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(FAN_ETH, i), 1);
        }
        assertEq(guilds.balanceOf(FAN_ETH, MOSAIC_ID), 0);
    }

    function testRevert_unmeltMosaicSheet_missingMosaic() public {
        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(FAN_ETH);
        guilds.unmeltMosaicSheet();
    }

    // Melt all 64 common moments into 1 ultrarare CUBE

    function test_meltCube() public {
        // Given
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), EDGE_LENGTH);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, CUBE_ID), 0);

        // When
        vm.prank(GUILDS_SALES);
        guilds.meltCube();

        // Then
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), 0);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, CUBE_ID), 1);
    }

    function testRevert_meltCube_missingToken() public {
        // Given
        vm.prank(GUILDS_SALES);
        guilds.safeTransferFrom(GUILDS_SALES, FAN_ETH, RANDOM_MOMENT, 1, "");

        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(GUILDS_SALES);
        guilds.meltCube();
    }

    // Unmelt 1 ultrarare CUBE into 64 common moments

    function test_unmeltCube() public {
        // Given
        vm.prank(GUILDS_SALES);
        guilds.meltCube();

        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), 0);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, CUBE_ID), 1);

        // When
        vm.prank(GUILDS_SALES);
        guilds.unmeltCube();

        // Then
        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), EDGE_LENGTH);
        }
        assertEq(guilds.balanceOf(GUILDS_SALES, CUBE_ID), 0);
    }

    function testRevert_unmeltCube_missingCube() public {
        // Then
        vm.expectRevert(stdError.arithmeticError);

        // When
        vm.prank(GUILDS_SALES);
        guilds.unmeltCube();
    }
}
