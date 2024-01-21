## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## How to run:

- *Run the command below to generate the .env file and install the project dependencies contained in the `./.gitmodules` file:*

```bash
make setup
```

- *Run the command below to execute the tests:*
```bash
make test
```

> [!IMPORTANT]
> Before running the command below, confirm that the `./.env` file contains all the necessary variables for deployment.

- *Run the command below to deploy the contracts:*
```bash
make moken
```

Moken Contract on EVM-Sidechain XRP: 0x330D0349ed3c5A8a212CC15EeBA92A6b4807dDF4
