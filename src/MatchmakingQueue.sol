// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract MatchmakingQueue {
    struct Player {
        address playerAddress;
        uint8 ranking;
    }

    Player[] public queue;

    // Event for logging new player insertions
    event PlayerInserted(address indexed playerAddress, uint8 ranking);
    event PlayerRemoved(address indexed playerAddress, uint8 ranking);
    // Event for when a match is made
    event MatchMade(address[] players);
    event AvailablePlayers(uint256 availablePlayers, uint256 leftIndex, uint256 rightIndex);

    // Insert a new player into the priority queue
    function insertPlayer(address _playerAddress, uint8 _ranking) internal {
        Player memory newPlayer = Player(_playerAddress, _ranking);
        queue.push(newPlayer);

        // Sort queue after insertion (simple insertion sort for demonstration)
        uint256 i = queue.length - 1;
        while (i > 0 && queue[i].ranking < queue[i - 1].ranking) {
            Player memory temp = queue[i];
            queue[i] = queue[i - 1];
            queue[i - 1] = temp;
            i--;
        }

        emit PlayerInserted(_playerAddress, _ranking);
    }

    // Remove a player from the queue by their index
    function removePlayerByIndex(uint256 index) internal {
        require(index < queue.length, "Index out of bounds");

        // Emit an event before removing the player
        emit PlayerRemoved(queue[index].playerAddress, queue[index].ranking);

        // Shift remaining elements left to fill the gap
        for (uint256 i = index; i < queue.length - 1; i++) {
            queue[i] = queue[i + 1];
        }
        queue.pop(); // Remove the last element
    }

    // Function to enter a player into matchmaking
    /**
     * @notice Enter a player into matchmaking
     * @param newPlayer The player to enter into matchmaking
     * @param numberOfPlayers The number of players to match
     * @param rankingRange The ranking range to match within
     */
    function enterPlayerIntoMatchmaking(Player memory newPlayer, uint256 numberOfPlayers, uint8 rankingRange) public {
        uint256 leftIndex = findLeftBoundary(newPlayer.ranking, rankingRange);
        uint256 rightIndex = findRightBoundary(newPlayer.ranking, rankingRange);

        uint256 availablePlayers = rightIndex >= leftIndex ? (rightIndex - leftIndex + 1) : 0;
        // add 1 because we are adding the new player to the game potentially
        availablePlayers = availablePlayers + 1;

        // for testing purposes
        emit AvailablePlayers(availablePlayers, leftIndex, rightIndex);

        // If enough players are within the ranking range, make the match
        if (availablePlayers >= numberOfPlayers) {
            address[] memory playerAddresses = new address[](numberOfPlayers);

            // Collect player addresses and remove them from the queue
            // Sub 1 from numberOfPlayers because newPlayer doesn't need to be removed from the queue
            // i < 2, i =0, 1
            for (uint256 i = 0; i < (numberOfPlayers - 1); i++) {
                Player memory matchedPlayer = queue[leftIndex]; // as we remove players from left to right
                playerAddresses[i] = matchedPlayer.playerAddress;

                // Remove players from the queue
                removePlayerByIndex(leftIndex); // Always remove from the left after each match
            }
            playerAddresses[numberOfPlayers - 1] = newPlayer.playerAddress;

            // Emit the match event with player addresses
            emit MatchMade(playerAddresses);
        } else {
            // If not enough players, insert the new player into the queue
            insertPlayer(newPlayer.playerAddress, newPlayer.ranking);
        }
    }

    // Helper function to find the left boundary of the ranking range using binary search
    function findLeftBoundary(uint8 ranking, uint8 rankingRange) internal view returns (uint256) {
        uint256 low = 0;
        uint256 high = queue.length;

        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (queue[mid].ranking >= ranking - rankingRange) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return low;
    }

    // Helper function to find the right boundary of the ranking range using binary search
    function findRightBoundary(uint8 ranking, uint8 rankingRange) internal view returns (uint256) {
        uint256 low = 0;
        uint256 high = queue.length;

        while (low < high) {
            uint256 mid = (low + high) / 2;
            if (queue[mid].ranking > ranking + rankingRange) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // Adjust to get the correct boundary index
        return high > 0 ? high - 1 : 0;
    }

    // Fetch the nearest player within a specified ranking range
    function fetchNearestPlayer(uint8 _ranking, uint8 rankingRange)
        public
        view
        returns (int256 nearestIndex, Player memory nearestPlayer)
    {
        nearestIndex = -1;
        uint256 minDiff = type(uint256).max;

        for (uint256 i = 0; i < queue.length; i++) {
            uint256 diff = absDiff(queue[i].ranking, _ranking);

            // Check if player is within the ranking range
            if (rankingRange == 0 || diff <= rankingRange) {
                if (diff < minDiff) {
                    minDiff = diff;
                    nearestIndex = int256(i);
                    nearestPlayer = queue[i];
                }
            }
        }

        require(nearestIndex >= 0, "No players in range found");
        return (nearestIndex, nearestPlayer);
    }

    // Find the first player within the ranking range and return the index and Player
    function findAnyPlayerWithinRankingRange(uint8 _ranking, uint8 rankingRange)
        public
        view
        returns (int256 playerIndex, Player memory player)
    {
        for (uint256 i = 0; i < queue.length; i++) {
            uint256 diff = absDiff(queue[i].ranking, _ranking);

            // Check if player is within the ranking range
            if (diff <= rankingRange) {
                playerIndex = int256(i);
                player = queue[i];
                return (playerIndex, player); // Return the first match found
            }
        }

        revert("No player found within the specified ranking range");
    }

    // Remove a player from the queue
    function removePlayer(address _playerAddress) public {
        // todo: only the player or the game address can remove a player from the queue
        for (uint256 i = 0; i < queue.length; i++) {
            if (queue[i].playerAddress == _playerAddress) {
                emit PlayerRemoved(_playerAddress, queue[i].ranking);
                // Remove player by shifting remaining elements
                for (uint256 j = i; j < queue.length - 1; j++) {
                    queue[j] = queue[j + 1];
                }
                queue.pop(); // Remove last element
                break;
            }
        }
    }

    // Helper function to calculate absolute difference
    function absDiff(uint8 a, uint8 b) private pure returns (uint256) {
        return a >= b ? a - b : b - a;
    }

    // Get total number of players in the queue
    function getQueueLength() public view returns (uint256) {
        return queue.length;
    }
}
