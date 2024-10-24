/**
 * @title MatchmakingQueueClient
 * @notice Interface for a client that interacts with the MatchmakingQueue contract.
 */
interface IMatchmakingQueueClient {
    function getPlayerRanking(address player) external view returns (uint256);
    function onMatchMade(address[] memory players) external;
}
