# Game Matchmaking Queue

> Gas efficient smart contract SDK for Multiplayer Game Matchmaking

This project aims to create an immutable smart contract that can be used by any game developer to create a matchmaking queue for a multi-player game. Developers can use player rankings and other settings to define how players should be matched for a game.

This project uses Solidity smart contracts written for the EVM. The contracts can be called from game developers to enter players into a matchmaking queue. This project heavily uses Foundry's Forge tool for testing and gas estimates.

> Built during ETHGlobal San Francisco 2024!

## Gas scaling
Send ETH for scale! 21,000 gas for sending ETH!
| **Number of players in the queue** | **Gas to enter queue** | **?** |
| --- | --- | --- |
| 1000 | 69,388 | ? |
| 10000 | 83,132 | ? |
| 100000 | 95102 | ? |


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
