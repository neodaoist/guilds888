// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {MarketplaceNFT} from "../test/MarketplaceNFT.sol";
import {Guilds} from "../src/Guilds.sol";

// Deploy the contract --
// forge script script/TestnetDeploy.s.sol --rpc-url $RPC --broadcast --slow --account testDeployer --sender 0x79847aA966193633a706A644AEaB42ae9675da27
// forge verify-contract $G src/Guilds.sol:Guilds --constructor-args $(cast abi-encode "constructor(address,address,uint256)" 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9 0xfCa43c4595893D353b6D3596D2Bc9182e691a643 1) --chain 8453 --watch --verifier etherscan

contract MainnetDeployScript is Script {
    ////////

    address private constant CUBE_CONTRACT = 0x4DB3AB8e606eAdF3d94cf5349a35c415156b89B3;
    uint256 private constant CUBE_TOKEN = 1;

    ////////

    address private constant GUILDS_SALES = 0x1Dca4D8ecc422aC5016EFd1b5127077B9490b4E9;

    function run() public {
        vm.startBroadcast();
        new Guilds(GUILDS_SALES, CUBE_CONTRACT, CUBE_TOKEN);
        vm.stopBroadcast();
    }
}
