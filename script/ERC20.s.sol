// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";

contract ERC20MockScript is Script {
    ERC20Mock public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new ERC20Mock("TestToken", "TST", 18);

        vm.stopBroadcast();
    }
}
