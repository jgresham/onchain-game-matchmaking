// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.24;

// contract MatchmakingQueue {
//     struct Player {
//         address playerAddress;
//         uint256 ranking;
//     }

//     struct TreeNode {
//         Player player;
//         address left; // Store the address of the left node
//         address right; // Store the address of the right node
//     }

//     mapping(address => TreeNode) public queueMap; // Address maps to tree nodes

//     // Event for logging new player insertions
//     event PlayerInserted(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
//     event PlayerRemoved(address indexed queueAddress, address indexed playerAddress, uint256 ranking);
//     // Event for when a match is made
//     event MatchMade(address indexed queueAddress, address[] players);
//     event AvailablePlayers(
//         address indexed queueAddress, uint256 availablePlayers, uint256 leftIndex, uint256 rightIndex
//     );
//     event LogIndex(address indexed queueAddress, uint256 index);

//     // Insert a new player into the BST
//     function insertPlayer(address _queueAddress, address _playerAddress, uint256 _ranking) internal {
//         Player memory newPlayer = Player(_playerAddress, _ranking);
//         queueMap[_queueAddress] = insertIntoBST(queueMap[_queueAddress], newPlayer);

//         emit PlayerInserted(_queueAddress, _playerAddress, _ranking);
//     }

//     function insertIntoBST(TreeNode storage node, Player memory newPlayer) internal returns (TreeNode storage) {
//         if (node.player.playerAddress == address(0)) {
//             // If the node is empty
//             node.player = newPlayer;
//             return node;
//         }

//         if (newPlayer.ranking < node.player.ranking) {
//             if (node.left == address(0)) {
//                 node.left = newPlayer.playerAddress; // Assign left address
//             } else {
//                 insertIntoBST(queueMap[node.left], newPlayer); // Recursive call using address
//             }
//         } else {
//             if (node.right == address(0)) {
//                 node.right = newPlayer.playerAddress; // Assign right address
//             } else {
//                 insertIntoBST(queueMap[node.right], newPlayer); // Recursive call using address
//             }
//         }
//         return node;
//     }

//     // Remove a player from the BST
//     function removePlayerByAddress(address _queueAddress, address _playerAddress) internal {
//         queueMap[_queueAddress] = removeFromBST(queueMap[_queueAddress], _playerAddress);
//     }

//     function removeFromBST(TreeNode storage node, address _playerAddress) internal returns (TreeNode storage) {
//         if (node.player.playerAddress == address(0)) return node; // Base case: node not found

//         if (_playerAddress < node.player.playerAddress) {
//             node.left = removeFromBST(queueMap[node.left], _playerAddress); // Recursive call using address
//         } else if (_playerAddress > node.player.playerAddress) {
//             node.right = removeFromBST(queueMap[node.right], _playerAddress); // Recursive call using address
//         } else {
//             // Node to be deleted found
//             if (node.left == address(0)) {
//                 return queueMap[node.right]; // No left child, replace with right child
//             } else if (node.right == address(0)) {
//                 return queueMap[node.left]; // No right child, replace with left child
//             } else {
//                 // Node with two children: Get the inorder successor (smallest in the right subtree)
//                 Player memory successor = findMin(queueMap[node.right]);
//                 node.player = successor;
//                 node.right = removeFromBST(queueMap[node.right], successor.playerAddress);
//             }
//         }
//         return node;
//     }

//     function findMin(TreeNode storage node) internal view returns (Player memory) {
//         while (node.left != address(0)) {
//             node = queueMap[node.left];
//         }
//         return node.player;
//     }

//     // Function to enter a player into matchmaking
//     function enterPlayerIntoMatchmaking(
//         address _queueAddress,
//         Player memory newPlayer,
//         uint256 numberOfPlayers,
//         uint256 rankingRange
//     ) public {
//         // Use a traversal method to gather players in the ranking range
//         address[] memory matchedPlayers =
//             gatherPlayersInRange(_queueAddress, newPlayer.ranking, rankingRange, numberOfPlayers);

//         if (matchedPlayers.length >= numberOfPlayers) {
//             emit MatchMade(_queueAddress, matchedPlayers);
//         } else {
//             // If not enough players, insert the new player into the queue
//             insertPlayer(_queueAddress, newPlayer.playerAddress, newPlayer.ranking);
//         }
//     }

//     function gatherPlayersInRange(address _queueAddress, uint256 ranking, uint256 rankingRange, uint256 numberOfPlayers)
//         internal
//         view
//         returns (address[] memory)
//     {
//         address[] memory matchedPlayers = new address[](numberOfPlayers);
//         uint256 index = 0;

//         findPlayersInRange(
//             queueMap[_queueAddress], ranking - rankingRange, ranking + rankingRange, matchedPlayers, index
//         );

//         return matchedPlayers;
//     }

//     function findPlayersInRange(
//         TreeNode storage node,
//         uint256 minRanking,
//         uint256 maxRanking,
//         address[] memory matchedPlayers,
//         uint256 index
//     ) internal view {
//         if (node.player.playerAddress == address(0)) return; // Base case

//         if (node.player.ranking >= minRanking && node.player.ranking <= maxRanking) {
//             matchedPlayers[index] = node.player.playerAddress;
//             index++;
//         }

//         if (node.left != address(0)) {
//             findPlayersInRange(queueMap[node.left], minRanking, maxRanking, matchedPlayers, index);
//         }
//         if (node.right != address(0)) {
//             findPlayersInRange(queueMap[node.right], minRanking, maxRanking, matchedPlayers, index);
//         }
//     }

//     // Helper function to safely compute ranking - rankingRange without underflow
//     function safeSubRanking(uint256 ranking, uint256 rankingRange) private pure returns (uint256) {
//         return ranking >= rankingRange ? ranking - rankingRange : 0;
//     }

//     // Fetch the nearest player within a specified ranking range
//     function fetchNearestPlayer(address _queueAddress, uint256 _ranking, uint256 rankingRange)
//         public
//         view
//         returns (Player memory)
//     {
//         TreeNode storage root = queueMap[_queueAddress];
//         Player memory nearestPlayer;
//         uint256 minDiff = type(uint256).max;

//         findNearestPlayer(root, _ranking, rankingRange, nearestPlayer, minDiff);

//         require(nearestPlayer.playerAddress != address(0), "No players in range found");
//         return nearestPlayer;
//     }

//     function findNearestPlayer(
//         TreeNode storage node,
//         uint256 _ranking,
//         uint256 rankingRange,
//         Player memory nearestPlayer,
//         uint256 minDiff
//     ) internal view {
//         if (node.player.playerAddress == address(0)) return; // Base case

//         uint256 diff = absDiff(node.player.ranking, _ranking);

//         // Check if player is within the ranking range
//         if (rankingRange == 0 || diff <= rankingRange) {
//             if (diff < minDiff) {
//                 minDiff = diff;
//                 nearestPlayer = node.player;
//             }
//         }

//         findNearestPlayer(queueMap[node.left], _ranking, rankingRange, nearestPlayer, minDiff);
//         findNearestPlayer(queueMap[node.right], _ranking, rankingRange, nearestPlayer, minDiff);
//     }

//     // Helper function to calculate absolute difference
//     function absDiff(uint256 a, uint256 b) private pure returns (uint256) {
//         return a >= b ? a - b : b - a;
//     }

//     // Get total number of players in the queue (this will not be accurate for a BST without a counter)
//     function getQueueLength(address _queueAddress) public view returns (uint256) {
//         return countNodes(queueMap[_queueAddress]);
//     }

//     function countNodes(TreeNode storage node) internal view returns (uint256) {
//         if (node.player.playerAddress == address(0)) return 0; // Base case
//         return 1 + countNodes(queueMap[node.left]) + countNodes(queueMap[node.right]);
//     }
// }
