// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./RBTree.sol";

contract MatchmakingQueue {
    struct Player {
        address playerAddress;
        uint256 ranking;
    }

    mapping(address => RBTree.Tree) public queueMap;

    // Event for logging new player insertions
    event PlayerInserted(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
    event PlayerRemoved(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
    // Event for when a match is made
    event MatchMade(address indexed queueAddress, address[] players);
    event AvailablePlayers(address indexed queueAddress, uint256 availablePlayers, address[] matchedPlayers);
    event LogIndex(address indexed queueAddress, uint256 index);

    // Insert a new player into the priority queue
    function insertPlayer(address _queueAddress, address _playerAddress, uint256 _ranking) internal {
        // Assuming RBTree.insert method is implemented to insert a node with a key and value
        // The key here is the playerAddress and the value is the ranking
        RBTree.insert(queueMap[_queueAddress], _playerAddress, _ranking);

        emit PlayerInserted(_queueAddress, _playerAddress, _ranking);
    }

    // Function to enter a player into matchmaking
    /**
     * @notice Enter a player into matchmaking
     * @param _queueAddress The address of the queue to enter the player into
     * @param newPlayer The player to enter into matchmaking
     * @param numberOfPlayers The number of players to match
     * @param rankingRange The ranking range to match within
     */
    function enterPlayerIntoMatchmaking(
        address _queueAddress,
        Player memory newPlayer,
        uint256 numberOfPlayers,
        uint256 rankingRange
    ) public {
        // Assuming RBTree.findNodesInRange method is implemented to find nodes within a range
        // This method would need to be modified to return the indices of the nodes within the range
        // For demonstration, we'll assume the indices are directly mapped to the nodes within the range
        // This is a simplification and actual implementation would require finding the nodes by range
        // and then mapping them to the indices

        uint256 minRanking = rankingRange > newPlayer.ranking ? 0 : newPlayer.ranking - rankingRange;

        address[] memory matchedPlayers = RBTree.findNodesInRange(
            queueMap[_queueAddress], numberOfPlayers, minRanking, newPlayer.ranking + rankingRange
        );

        uint256 availablePlayers = matchedPlayers.length;

        // for testing purposes
        emit AvailablePlayers(_queueAddress, availablePlayers, matchedPlayers);

        // If enough players are within the ranking range, make the match
        // Subtract 1 because the newPlayer doesn't need to be removed from the queue
        if (availablePlayers >= (numberOfPlayers - 1)) {
            address[] memory playerAddresses = new address[](numberOfPlayers);

            // Collect player addresses and remove them from the queue
            // Sub 1 from numberOfPlayers because newPlayer doesn't need to be removed from the queue
            for (uint256 i = 0; i < (numberOfPlayers - 1); i++) {
                // The key here is the playerAddress
                playerAddresses[i] = matchedPlayers[i];
                RBTree.remove(queueMap[_queueAddress], playerAddresses[i]); // Always remove from the left after each match
            }
            playerAddresses[numberOfPlayers - 1] = newPlayer.playerAddress;

            // Emit the match event with player addresses
            emit MatchMade(_queueAddress, playerAddresses);
        } else {
            // If not enough players, insert the new player into the queue
            insertPlayer(_queueAddress, newPlayer.playerAddress, newPlayer.ranking);
        }
    }

    // Remove a player from the queue
    function removePlayer(address _queueAddress, address _playerAddress) public {
        // Assuming RBTree.remove method is implemented to remove a node by its key
        // The key here is the playerAddress
        RBTree.remove(queueMap[_queueAddress], _playerAddress);
    }

    // Get total number of players in the queue
    function getQueueLength(address _queueAddress) public view returns (uint256) {
        // Assuming RBTree.size method is implemented to return the size of the tree
        return RBTree.size(queueMap[_queueAddress]);
    }
}
