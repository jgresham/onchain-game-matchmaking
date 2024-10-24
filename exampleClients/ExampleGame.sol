// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IMatchmakingQueueClient} from "../src/IMatchmakingQueueClient.sol";
import {MatchmakingQueue} from "../src/MatchmakingQueue.sol";

contract ExampleGame is IMatchmakingQueueClient {
    event ExampleGameMatchMade(address[] players);

    MatchmakingQueue public matchmakingQueue;
    mapping(address => uint256) public playerRankings;

    constructor(address matchmakingQueueAddress) {
        matchmakingQueue = MatchmakingQueue(matchmakingQueueAddress);
        playerRankings[address(0x1)] = 100;
        playerRankings[address(0x2)] = 200;
        playerRankings[address(0x3)] = 300;
    }

    function getPlayerRanking(address player) external view returns (uint256) {
        // Called by MatchmakingQueue when a player joins the queue
        // Players with similar rankings are matched together!
        // If there are no player rankings, just return the same value for all players
        if (playerRankings[player] != 0) {
            return playerRankings[player];
        }
        return 0;
    }

    function onMatchMade(address[] memory players) external {
        // Handler called by MatchmakingQueue when a match is made
        // TODO: Emit your own event, start the game with the players, etc.
        emit ExampleGameMatchMade(players);
        // If not a smart contract game, then just listen for the MatchMade event on your frontend!
    }
}
