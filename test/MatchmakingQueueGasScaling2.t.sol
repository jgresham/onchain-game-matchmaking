// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MatchmakingQueue} from "../../src/MatchmakingQueue.sol";

contract MatchmakingQueueGasScalingRBTreeTest2 is Test {
    MatchmakingQueue matchmakingQueue;
    address queueAddress100000Players = address(0x123456); // Added queue address for 100,000 players

    function setUp() public {
        matchmakingQueue = new MatchmakingQueue();

        // ------------------------------------------------------------------------------------------------
        // Enter 100,000 players into a matchmaking queue
        for (uint256 k = 1; k < 100001; k++) {
            // huge match size to avoid match being made
            MatchmakingQueue.Player memory player = MatchmakingQueue.Player(address(uint160(k)), uint256(1));
            matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player, 200000, 2);
        }

        // Check that the queue has all the players
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 100000);

        // Enter the 100001st and 100002nd players into matchmaking
        MatchmakingQueue.Player memory player100001 = MatchmakingQueue.Player(address(0x100002), 100);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player100001, 3, 5);
        MatchmakingQueue.Player memory player100002 = MatchmakingQueue.Player(address(0x100003), 100);
        matchmakingQueue.enterPlayerIntoMatchmaking(queueAddress100000Players, player100002, 3, 5);

        // Check that the queue is now empty after the match
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 100002);
    }

    // needs to be run with:
    // forge test -vvvv --gas-limit 300000000000 --match-test "testEnterPlayerIntoMatchmaking_GasForEntryAfterHundredThousandPlayers2"
    // ideally, we don't care if the setUp function fits in one block gas limit

    // gas history:
    // 4:08pm 10/19: Entering a 3 person game with 100002 players in queue is gas: 110620
    function testEnterPlayerIntoMatchmaking_GasForEntryAfterHundredThousandPlayers2() public {
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
        assertEq(matchmakingQueue.getQueueLength(queueAddress100000Players), 100000);
    }
}
