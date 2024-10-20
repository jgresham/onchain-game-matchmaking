// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MatchmakingQueue} from "../src/MatchmakingQueue.sol";

contract MatchmakingQueueTest is Test {
    MatchmakingQueue matchmakingQueue;
    address queueAddress = address(0x123); // Assuming this is the queue address for the matchmaking queue

    function setUp() public {
        matchmakingQueue = new MatchmakingQueue();
    }

    // gas history:
    // early testing used 83766 gas
    // increased to 91776 with multi-queue, queueMap / queueAddress
    function testEnterPlayerIntoMatchmaking_MatchMade() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x1);
        expectedPlayers[1] = address(0x2);
        expectedPlayers[2] = address(0x3);

        // Enter 3 players into matchmaking
        MatchmakingQueue.Player memory player1 = MatchmakingQueue.Player(address(0x1), 10);
        MatchmakingQueue.Player memory player2 = MatchmakingQueue.Player(address(0x2), 11);
        MatchmakingQueue.Player memory player3 = MatchmakingQueue.Player(address(0x3), 12);

        // args: player, number of players to match, ranking range
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1, 3, 5);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player2, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 2);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress, expectedPlayers);

        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player3, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 0);
    }

    function testEnterPlayerIntoMatchmaking_InsufficientPlayers_NoMatch() public {
        // Enter 2 players into matchmaking
        MatchmakingQueue.Player memory player1 = MatchmakingQueue.Player(address(0x1), 10);
        MatchmakingQueue.Player memory player2 = MatchmakingQueue.Player(address(0x2), 12);

        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1, 3, 5);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player2, 3, 5);

        // Check that the queue contains 2 players and no match has been made
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 2);

        // Enter a third player, but with insufficient ranking range to match the other two
        MatchmakingQueue.Player memory player3 = MatchmakingQueue.Player(address(0x3), 15);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player3, 3, 2);

        // Verify that all 3 players are still in the queue (no match)
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 3);
    }

    function testEnterPlayerIntoMatchmaking_ExactPlayersInRange() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x1);
        expectedPlayers[1] = address(0x2);
        expectedPlayers[2] = address(0x3);

        // Enter 3 players with exact ranking range to match
        MatchmakingQueue.Player memory player1 = MatchmakingQueue.Player(address(0x1), 10);
        MatchmakingQueue.Player memory player2 = MatchmakingQueue.Player(address(0x2), 11);
        MatchmakingQueue.Player memory player3 = MatchmakingQueue.Player(address(0x3), 10);

        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1, 3, 2);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player2, 3, 2);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress, expectedPlayers);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player3, 3, 2);

        // Ensure the queue is empty after match
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 0);
    }

    function testEnterPlayerIntoMatchmaking_NoPlayersInRange() public {
        // Enter two players with distant rankings
        MatchmakingQueue.Player memory player1 = MatchmakingQueue.Player(address(0x1), 5);
        MatchmakingQueue.Player memory player2 = MatchmakingQueue.Player(address(0x2), 25);

        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1, 3, 3);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player2, 3, 3);

        // Check that both players are in the queue
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 2);

        // Enter a third player with a ranking that should not match the others
        MatchmakingQueue.Player memory player3 = MatchmakingQueue.Player(address(0x3), 15);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player3, 3, 3);

        // Verify that all three players are still in the queue since no match was made
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 3);
    }
}
