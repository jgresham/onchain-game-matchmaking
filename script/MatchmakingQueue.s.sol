// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MatchmakingQueue} from "../src/MatchmakingQueue.sol";

contract CounterScript is Script {
    MatchmakingQueue public matchmakingQueue;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        matchmakingQueue = new MatchmakingQueue();

        vm.stopBroadcast();
    }
}
