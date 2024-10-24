// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MatchmakingQueue} from "../../src/MatchmakingQueue.sol";

contract MatchmakingQueueGasScaling1000PlayersTest is Test {
    MatchmakingQueue matchmakingQueue;
    address queueAddress1000Players = address(0x1234);

    function setUp() public {
        matchmakingQueue = new MatchmakingQueue();

        // ------------------------------------------------------------------------------------------------
        // Enter 1000 players into a matchmaking queue
        for (uint256 i = 1; i < 1001; i++) {
            // rankings spread out to avoid matching range
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(i)), uint16(i * 2));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player, 3, 1);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1000);

        // Enter the 1001st and 1002nd players into matchmaking
        MatchmakingQueue.Player memory player1001 = MatchmakingQueue.Player(address(0x1002), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1001, 3, 5);
        MatchmakingQueue.Player memory player1002 = MatchmakingQueue.Player(address(0x1003), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1002);
    }

    // gas history:
    // 3:28pm 10/19: Entering a 3 person game with 1002 players in queue is gas: 69388
    function testEnterPlayerIntoMatchmaking_GasForEntryAfterThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x1002);
        expectedPlayers[1] = address(0x1003);
        expectedPlayers[2] = address(0x1004);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress1000Players, expectedPlayers);

        MatchmakingQueue.Player memory player1003 = MatchmakingQueue.Player(address(0x1004), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1003, 3, 5);

        // Check that the queue is now 1000 after the match is made
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1000);
    }

    // gas history:
    // 8m 10/19: Entering a 3 person game with 1002 players in queue is gas:
    function testEnterPlayerIntoMatchmaking_GasForEntryIntoMiddleOfRankingsAfterThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x0000000000000000000000000000000000000062);
        expectedPlayers[1] = address(0x0000000000000000000000000000000000000063);
        expectedPlayers[2] = address(0x1003);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress1000Players, expectedPlayers);
        // 1000: 6,482,384 gas
        // 800: 7,732,357 gas
        // 200: 11,550,971 gas -> worse case is lower, moving more elements in the queue
        MatchmakingQueue.Player memory player1003 = MatchmakingQueue.Player(address(0x1003), 200);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1003, 3, 5);

        // Check that the queue is now 1000 after the match is made
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1000);
    }
}
