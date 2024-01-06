// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Guilds} from "../src/Guilds.sol";

contract GuildsTest is Test {
    Guilds public guilds;

    function setUp() public {
        guilds = new Guilds();
        guilds.setNumber(0);
    }

    function test_Increment() public {
        guilds.increment();
        assertEq(guilds.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        guilds.setNumber(x);
        assertEq(guilds.number(), x);
    }
}
