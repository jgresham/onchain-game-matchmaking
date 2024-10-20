# Game Matchmaking Queue

> Smart contract SDK for Multiplayer Game Matchmaking

This project aims to create an immutable smart contract that can be used by any game developer to create a matchmaking queue for a multi-player game. Developers can use player rankings and other settings to define how players should be matched for a game.

This project uses Solidity smart contracts written for the EVM. The contracts can be called from game developers to enter players into a matchmaking queue. This project heavily uses Foundry's Forge tool for testing and gas estimates.

> Built during ETHGlobal San Francisco 2024!

## Gas scaling
Send ETH for scale! 21,000 gas for sending ETH!
| **Number of players in the queue** | **Best case gas to enter queue** | **Bad case gas to enter queue** |
| --- | --- | --- |
| 1000 | 69,388 | ? |
| 10000 | 83,132 | ? |
| 100000 | 95,102 | ? |

```
forge test --gas-report --gas-limit 300000000000
[⠊] Compiling...
[⠒] Compiling 1 files with Solc 0.8.24
[⠆] Solc 0.8.24 finished in 1.09s
Compiler run successful!

Ran 1 test for test/BinarySearch.t.sol:MatchmakingQueueGasScalingTest2
[PASS] testFindLeftBoundary_TwoPlayersSameRanking() (gas: 96037)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 5.30ms (315.21µs CPU time)

Ran 4 tests for test/MatchmakingQueue.t.sol:MatchmakingQueueTest
[PASS] testEnterPlayerIntoMatchmaking_ExactPlayersInRange() (gas: 240322)
[PASS] testEnterPlayerIntoMatchmaking_InsufficientPlayers_NoMatch() (gas: 281185)
[PASS] testEnterPlayerIntoMatchmaking_MatchMade() (gas: 241879)
[PASS] testEnterPlayerIntoMatchmaking_NoPlayersInRange() (gas: 295560)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 5.37ms (4.92ms CPU time)

Ran 5 tests for test/MatchmakingQueueGasScaling.t.sol:MatchmakingQueueGasScalingTest
[PASS] testEnterPlayerIntoMatchmaking_GasForEntryAfterHundredThousandPlayers() (gas: 86717)
[PASS] testEnterPlayerIntoMatchmaking_GasForEntryAfterTenThousandPlayers() (gas: 86783)
[PASS] testEnterPlayerIntoMatchmaking_GasForEntryAfterThousandPlayers() (gas: 73616)
[PASS] testEnterPlayerIntoMatchmaking_GasForEntryIntoMiddleOfRankingsAfterTenThousandPlayers() (gas: 63788162)
[PASS] testEnterPlayerIntoMatchmaking_MatchMadeAfterThousandPlayers() (gas: 109785209)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 79.64s (487.59ms CPU time)

Ran 1 test for test/MatchmakingQueueGasScaling2.t.sol:MatchmakingQueueGasScalingTest2
[PASS] testEnterPlayerIntoMatchmaking_GasForEntryAfterHundredThousandPlayers2() (gas: 97690)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 2446.16s (95.46ms CPU time)
| src/MatchmakingQueue.sol:MatchmakingQueue contract |                 |        |        |          |         |
|----------------------------------------------------|-----------------|--------|--------|----------|---------|
| Deployment Cost                                    | Deployment Size |        |        |          |         |
| 1123919                                            | 4992            |        |        |          |         |
| Function Name                                      | min             | avg    | median | max      | # calls |
| enterPlayerIntoMatchmaking                         | 55195           | 145307 | 146321 | 63791832 | 206054  |
| getQueueLength                                     | 588             | 588    | 588    | 588      | 49      |

Ran 4 test suites in 2446.46s (2525.81s CPU time): 11 tests passed, 0 failed, 0 skipped (11 total tests)
```

## Developer Setup and Testing

### Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

### Documentation

https://book.getfoundry.sh/

### Usage

#### Build

```shell
$ forge build
```

#### Test

```shell
$ forge test
```

#### Format

```shell
$ forge fmt
```

#### Gas Snapshots

```shell
$ forge snapshot
```

#### Anvil

```shell
$ anvil
```

#### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

#### Cast

```shell
$ cast <subcommand>
```

#### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
