// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MatchmakingQueue} from "../src/MatchmakingQueue.sol";

contract MatchmakingQueueGasScalingTest2 is Test {
    MatchmakingQueue matchmakingQueue;
    address queueAddress100000Players = address(0x123456); // Added queue address for 100,000 players

    function setUp() public {
        matchmakingQueue = new MatchmakingQueue();

        // huge match size to avoid match being made
        MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(0)), uint256(1));
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player, 200000, 2);

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 1);
    }

    // gas history:
    // 4:08pm 10/19: Entering a 3 person game with 100002 players in queue is gas: 110620
    function testFindLeftBoundary_TwoPlayersSameRanking() public {
        MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(1)), uint256(1));
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player, 200000, 2);

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 2);
    }
}
