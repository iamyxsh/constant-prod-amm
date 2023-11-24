// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "forge-std/console.sol";

import {CPAMM} from "../src/CPAMM.sol";
import {TokenA} from "../src/mocks/TokenA.sol";
import {TokenB} from "../src//mocks/TokenB.sol";

contract CPAMMTest is Test {
    CPAMM public cpamm;
    TokenA public tokenA;
    TokenB public tokenB;

    uint initBalance = 1000000000000000000000000;

    function setUp() public {
        tokenA = new TokenA();
        tokenB = new TokenB();
        cpamm = new CPAMM(address(tokenA), address(tokenB));

        tokenA.approveSpender(address(cpamm), initBalance);
        tokenB.approveSpender(address(cpamm), initBalance);

        cpamm.addLiquid(100, 100);
    }

    function test_Swap() public {
        cpamm.swap(address(tokenA), 10);

        assertEq(tokenA.balanceOf(address(this)), initBalance - 10);
    }
}
