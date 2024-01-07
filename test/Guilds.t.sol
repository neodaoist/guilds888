// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {MarketplaceNFT} from "./MarketplaceNFT.sol";
import {Guilds} from "../src/Guilds.sol";

contract GuildsTest is Test {
    /////////

    MarketplaceNFT public cube;
    Guilds public guilds;

    uint8 private constant NUM_COMMONS = 64;

    address private constant GUILDS_DEPLOYER = address(0xA1);
    address private constant GUILDS_SALES = address(0xA2);
    address private constant NEO_ETH = address(0xA3);
    address private constant FAN_ETH = address(0xA4);

    /////////

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

    ///////// Initial Marketplace

    function test_initialSendCube() public {
        assertEq(cube.balanceOf(address(guilds)), 1);
        assertEq(cube.ownerOf(1), address(guilds));

        for (uint256 i = 1; i <= NUM_COMMONS; i++) {
            assertEq(guilds.balanceOf(GUILDS_SALES, i), 8);
        }
    }
}
