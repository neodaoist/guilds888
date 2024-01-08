// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {MarketplaceNFT} from "../test/MarketplaceNFT.sol";
import {Guilds} from "../src/Guilds.sol";

// Deploy the contracts --
// forge script script/TestnetDeploy.s.sol --rpc-url $RPC --broadcast --slow --account testDeployer --sender 0x79847aA966193633a706A644AEaB42ae9675da27
// export M=
// export G=
// forge verify-contract $G src/Guilds.sol:Guilds --constructor-args $(cast abi-encode "constructor(address,address,uint256)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 $M 1) --chain 84532 --watch --verifier etherscan

// Mint the cube and send the cube to GUILDS --
// cast send $M "mint()" --account guildsSales --rpc-url $RPC
// cast send $M "safeTransferFrom(address,address,uint256)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 $G 1 --rpc-url $RPC --account guildsSales

// Send some moments to FAN --
// cast send $G "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 0x4ab68ce2dD8dBDD17f925b5Ab49E6f7aD433013B "[1,2,3,4,5,6,7,8]" "[1,1,1,1,1,1,1,1]" "" --rpc-url $RPC --account guildsSales
// cast send $G "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 0x4ab68ce2dD8dBDD17f925b5Ab49E6f7aD433013B "[2,10,18,26,34,42,50,58]" "[2,2,2,2,2,2,2,2]" "" --rpc-url $RPC --account guildsSales
// cast send $G "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 0x4ab68ce2dD8dBDD17f925b5Ab49E6f7aD433013B "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64]" "[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]" "" --rpc-url $RPC --account guildsSales

// FAN melts 2 strips and a mosaic sheet --
// cast send $G "meltStyleStrip(uint8)" 1 --rpc-url $RPC --account classicalMusicFan
// cast send $G "meltGuildStrip(uint8)" 2 --rpc-url $RPC --account classicalMusicFan
// cast send $G "meltMosaicSheet()" --rpc-url $RPC --account classicalMusicFan

contract TestnetDeployScript is Script {
    address private constant GUILDS_DEPLOYER = 0x79847aA966193633a706A644AEaB42ae9675da27;
    address private constant GUILDS_SALES = 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9;
    address private constant NEO_ETH = 0x4BBa239C9cC83619228457502227D801e4738bA0;
    address private constant FAN_ETH = 0x4ab68ce2dD8dBDD17f925b5Ab49E6f7aD433013B;

    function run() public {
        vm.startBroadcast();
        MarketplaceNFT cube = new MarketplaceNFT();
        new Guilds(GUILDS_SALES, address(cube), 1);
        vm.stopBroadcast();
    }
}
