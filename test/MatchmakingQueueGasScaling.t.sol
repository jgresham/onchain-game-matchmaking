// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MatchmakingQueue} from "../src/MatchmakingQueue.sol";

contract MatchmakingQueueGasScalingTest is Test {
    MatchmakingQueue matchmakingQueue;
    address queueAddress = address(0x123);
    address queueAddress1000Players = address(0x1234);
    address queueAddress10000Players = address(0x12345);
    address queueAddress100000Players = address(0x123456); // Added queue address for 100000 players

    function setUp() public {
        matchmakingQueue = new MatchmakingQueue();

        // ------------------------------------------------------------------------------------------------
        // Enter 1000 players into a matchmaking queue
        for (uint256 i = 0; i < 1000; i++) {
            // rankings spread out to avoid matching range
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(i)), uint16(i * 2));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player, 3, 1);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1000);

        // Enter the 1001st and 1002nd players into matchmaking
        MatchmakingQueue.Player memory player1001 = MatchmakingQueue.Player(address(0x1001), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1001, 3, 5);
        MatchmakingQueue.Player memory player1002 = MatchmakingQueue.Player(address(0x1002), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress1000Players, player1002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress1000Players), 1002);

        // ------------------------------------------------------------------------------------------------
        // Enter 10000 players into a matchmaking queue
        for (uint256 j = 0; j < 10000; j++) {
            // rankings spread out to avoid matching range
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(j)), uint16(j * 2));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress10000Players, player, 3, 1);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress10000Players), 10000);

        // Enter the 10001st and 10002nd players into matchmaking
        MatchmakingQueue.Player memory player10001 = MatchmakingQueue.Player(address(0x10001), 30000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress10000Players, player10001, 3, 5);
        MatchmakingQueue.Player memory player10002 = MatchmakingQueue.Player(address(0x10002), 30000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress10000Players, player10002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress10000Players), 10002);

        // ------------------------------------------------------------------------------------------------
        // Enter 100000 players into a matchmaking queue
        for (uint256 k = 0; k < 10000; k++) {
            // huge match size to avoid match being made
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(k)), uint16(1));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player, 200000, 1);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 10000);

        // Enter the 100001st and 100002nd players into matchmaking
        MatchmakingQueue.Player memory player100001 = MatchmakingQueue.Player(address(0x100001), 100);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player100001, 3, 5);
        MatchmakingQueue.Player memory player100002 = MatchmakingQueue.Player(address(0x100002), 100);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player100002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 10002);
    }

    // gas history:
    // 3:28pm 10/19: 1000 players: gas: 43457563
    function testEnterPlayerIntoMatchmaking_MatchMadeAfterThousandPlayers() public {
        // Enter 1000 players into matchmaking
        for (uint256 i = 0; i < 1000; i++) {
            // rankings spread out to avoid matching range
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(i)), uint16(i * 2));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player, 3, 1);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 1000);

        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x1001);
        expectedPlayers[1] = address(0x1002);
        expectedPlayers[2] = address(0x1003);

        // Enter the 1001st player into matchmaking
        MatchmakingQueue.Player memory player1001 = MatchmakingQueue.Player(address(0x1001), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1001, 3, 5);
        MatchmakingQueue.Player memory player1002 = MatchmakingQueue.Player(address(0x1002), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 1002);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress, expectedPlayers);

        MatchmakingQueue.Player memory player1003 = MatchmakingQueue.Player(address(0x1003), 3000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress, player1003, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress), 1000);
    }

    // gas history:
    // 3:28pm 10/19: Entering a 3 person game with 1002 players in queue is gas: 69388
    function testEnterPlayerIntoMatchmaking_GasForEntryAfterThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x1001);
        expectedPlayers[1] = address(0x1002);
        expectedPlayers[2] = address(0x1003);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress1000Players, expectedPlayers);

        MatchmakingQueue.Player memory player1003 = MatchmakingQueue.Player(address(0x1003), 3000);
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

    // gas history:
    // 3:48pm 10/19: Entering a 3 person game with 10002 players in queue is gas: 83132
    function testEnterPlayerIntoMatchmaking_GasForEntryAfterTenThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x10001);
        expectedPlayers[1] = address(0x10002);
        expectedPlayers[2] = address(0x10003);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress10000Players, expectedPlayers);

        MatchmakingQueue.Player memory player10003 = MatchmakingQueue.Player(address(0x10003), 30000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress10000Players, player10003, 3, 5);

        // Check that the queue is now 10000 after the match is made
        assertEq(matchmakingQueue.getQueueLength(queueAddress10000Players), 10000);
    }

    // gas history:
    // 3:48pm 10/19: Entering a 3 person game with 10002 players into the middle of the queue is gas: 63,785,562
    function testEnterPlayerIntoMatchmaking_GasForEntryIntoMiddleOfRankingsAfterTenThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x0000000000000000000000000000000000001386);
        expectedPlayers[1] = address(0x0000000000000000000000000000000000001387);
        expectedPlayers[2] = address(0x10003);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress10000Players, expectedPlayers);

        MatchmakingQueue.Player memory player10003 = MatchmakingQueue.Player(address(0x10003), 10000);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress10000Players, player10003, 3, 5);

        // Check that the queue is now 10000 after the match is made
        assertEq(matchmakingQueue.getQueueLength(queueAddress10000Players), 10000);
    }

    // gas history:
    // 4:08pm 10/19: Entering a 3 person game with 100002 players in queue is gas: 110620
    function testEnterPlayerIntoMatchmaking_GasForEntryAfterHundredThousandPlayers() public {
        // Prepare to listen for the MatchMade event
        address[] memory expectedPlayers = new address[](3);
        expectedPlayers[0] = address(0x100001);
        expectedPlayers[1] = address(0x100002);
        expectedPlayers[2] = address(0x100003);

        vm.expectEmit(true, true, true, true);
        // We emit the event we expect to see.
        emit MatchmakingQueue.MatchMade(queueAddress100000Players, expectedPlayers);

        MatchmakingQueue.Player memory player100003 = MatchmakingQueue.Player(address(0x100003), 100);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player100003, 3, 5);

        // Check that the queue is now 100000 after the match is made
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 10000);
    }
}
