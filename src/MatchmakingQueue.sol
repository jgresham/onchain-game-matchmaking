// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract MatchmakingQueue {
    struct Player {
        address playerAddress;
        uint256 ranking;
    }

    mapping(address => Player[]) public queueMap;

    // Event for logging new player insertions
    event PlayerInserted(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
    event PlayerRemoved(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
    // Event for when a match is made
    event MatchMade(address indexed queueAddress, address[] players);
    event AvailablePlayers(
        address indexed queueAddress, uint256 availablePlayers, uint256 leftIndex, uint256 rightIndex
    );
    event LogIndex(address indexed queueAddress, uint256 index);

    // Insert a new player into the priority queue
    function insertPlayer(address _queueAddress, address _playerAddress, uint256 _ranking) internal {
        Player memory newPlayer = Player(_playerAddress, _ranking);
        queueMap[_queueAddress].push(newPlayer);

        // Sort queue after insertion (simple insertion sort for demonstration)
        uint256 i = queueMap[_queueAddress].length - 1;
        while (i > 0 && queueMap[_queueAddress][i].ranking < queueMap[_queueAddress][i - 1].ranking) {
            Player memory temp = queueMap[_queueAddress][i];
            queueMap[_queueAddress][i] = queueMap[_queueAddress][i - 1];
            queueMap[_queueAddress][i - 1] = temp;
            i--;
        }

        emit PlayerInserted(_queueAddress, _playerAddress, _ranking);
    }

    // Remove a player from the queue by their index
    function removePlayerByIndex(address _queueAddress, uint256 index) internal {
        require(index < queueMap[_queueAddress].length, "Index out of bounds");

        // Emit an event before removing the player
        emit PlayerRemoved(
            _queueAddress, queueMap[_queueAddress][index].playerAddress, queueMap[_queueAddress][index].ranking
        );

        // VERY EXPENSIVE OPERATION
        // Shift remaining elements left to fill the gap
        for (uint256 i = index; i < queueMap[_queueAddress].length - 1; i++) {
            queueMap[_queueAddress][i] = queueMap[_queueAddress][i + 1];
        }
        queueMap[_queueAddress].pop(); // Remove the last element
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
        uint256 leftIndex = findLeftBoundary(_queueAddress, newPlayer.ranking, rankingRange);
        emit LogIndex(_queueAddress, leftIndex);
        uint256 rightIndex = findRightBoundary(_queueAddress, newPlayer.ranking, rankingRange);
        emit LogIndex(_queueAddress, rightIndex);

        uint256 availablePlayers = rightIndex >= leftIndex ? (rightIndex - leftIndex + 1) : 0;
        if (rightIndex == 0 && leftIndex == 0) {
            availablePlayers = 0;
        }
        // add 1 because we are adding the new player to the game potentially
        availablePlayers = availablePlayers + 1;

        // for testing purposes
        emit AvailablePlayers(_queueAddress, availablePlayers, leftIndex, rightIndex);

        // If enough players are within the ranking range, make the match
        if (availablePlayers >= numberOfPlayers) {
            address[] memory playerAddresses = new address[](numberOfPlayers);

            // Collect player addresses and remove them from the queue
            // Sub 1 from numberOfPlayers because newPlayer doesn't need to be removed from the queue
            // i < 2, i =0, 1
            for (uint256 i = 0; i < (numberOfPlayers - 1); i++) {
                Player memory matchedPlayer = queueMap[_queueAddress][leftIndex]; // as we remove players from left to right
                playerAddresses[i] = matchedPlayer.playerAddress;

                // Remove players from the queue
                removePlayerByIndex(_queueAddress, leftIndex); // Always remove from the left after each match
            }
            playerAddresses[numberOfPlayers - 1] = newPlayer.playerAddress;

            // Emit the match event with player addresses
            emit MatchMade(_queueAddress, playerAddresses);
        } else {
            // If not enough players, insert the new player into the queue
            insertPlayer(_queueAddress, newPlayer.playerAddress, newPlayer.ranking);
        }
    }

    // Helper function to safely compute ranking - rankingRange without underflow
    function safeSubRanking(uint256 ranking, uint256 rankingRange) private pure returns (uint256) {
        if (ranking >= rankingRange) {
            return ranking - rankingRange;
        } else {
            return 0; // Treat underflow as 0 since ranking can't be negative
        }
    }

    // Helper function to find the left boundary of the ranking range using binary search
    function findLeftBoundary(address _queueAddress, uint256 ranking, uint256 rankingRange)
        internal
        view
        returns (uint256)
    {
        uint256 low = 0;
        uint256 high = queueMap[_queueAddress].length;
        uint256 lowerBound = safeSubRanking(ranking, rankingRange);

        while (low < high) {
            uint256 mid = (low + high) / 2;

            if (queueMap[_queueAddress][mid].ranking >= lowerBound) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return low;
    }

    // Helper function to find the right boundary of the ranking range using binary search
    function findRightBoundary(address _queueAddress, uint256 ranking, uint256 rankingRange)
        internal
        view
        returns (uint256)
    {
        uint256 low = 0;
        uint256 high = queueMap[_queueAddress].length;

        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (queueMap[_queueAddress][mid].ranking > ranking + rankingRange) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // Adjust to get the correct boundary index
        return high > 0 ? high - 1 : 0;
    }

    // Fetch the nearest player within a specified ranking range
    function fetchNearestPlayer(address _queueAddress, uint256 _ranking, uint256 rankingRange)
        public
        view
        returns (int256 nearestIndex, Player memory nearestPlayer)
    {
        nearestIndex = -1;
        uint256 minDiff = type(uint256).max;

        for (uint256 i = 0; i < queueMap[_queueAddress].length; i++) {
            uint256 diff = absDiff(queueMap[_queueAddress][i].ranking, _ranking);

            // Check if player is within the ranking range
            if (rankingRange == 0 || diff <= rankingRange) {
                if (diff < minDiff) {
                    minDiff = diff;
                    nearestIndex = int256(i);
                    nearestPlayer = queueMap[_queueAddress][i];
                }
            }
        }

        require(nearestIndex >= 0, "No players in range found");
        return (nearestIndex, nearestPlayer);
    }

    // Find the first player within the ranking range and return the index and Player
    function findAnyPlayerWithinRankingRange(address _queueAddress, uint256 _ranking, uint256 rankingRange)
        public
        view
        returns (int256 playerIndex, Player memory player)
    {
        for (uint256 i = 0; i < queueMap[_queueAddress].length; i++) {
            uint256 diff = absDiff(queueMap[_queueAddress][i].ranking, _ranking);

            // Check if player is within the ranking range
            if (diff <= rankingRange) {
                playerIndex = int256(i);
                player = queueMap[_queueAddress][i];
                return (playerIndex, player); // Return the first match found
            }
        }

        revert("No player found within the specified ranking range");
    }

    // Remove a player from the queue
    function removePlayer(address _queueAddress, address _playerAddress) public {
        // todo: only the player or the game address can remove a player from the queue
        for (uint256 i = 0; i < queueMap[_queueAddress].length; i++) {
            if (queueMap[_queueAddress][i].playerAddress == _playerAddress) {
                emit PlayerRemoved(
                    _queueAddress, queueMap[_queueAddress][i].playerAddress, queueMap[_queueAddress][i].ranking
                );
                // Remove player by shifting remaining elements
                for (uint256 j = i; j < queueMap[_queueAddress].length - 1; j++) {
                    queueMap[_queueAddress][j] = queueMap[_queueAddress][j + 1];
                }
                queueMap[_queueAddress].pop(); // Remove last element
                break;
            }
        }
    }

    // Helper function to calculate absolute difference
    function absDiff(uint256 a, uint256 b) private pure returns (uint256) {
        return a >= b ? a - b : b - a;
    }

    // Get total number of players in the queue
    function getQueueLength(address _queueAddress) public view returns (uint256) {
        return queueMap[_queueAddress].length;
    }
}
