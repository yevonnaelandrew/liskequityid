# LiskEquityID

LiskEquityID is a decentralized application (dApp) built on the Lisk blockchain that allows users to tokenize and trade Indonesian stocks on the blockchain. In this example, the focus is on one particular stock: Bank Central Asia (BBCA). The project enables users to collateralize their ETH tokens and mint BBCA tokens, which represent the value of BBCA stocks.

## Features

- **Collateralization**: Users can deposit ETH tokens as collateral to mint BBCA tokens, which are pegged to the price of BBCA stocks.
- **Minting**: Users can mint BBCA tokens based on the current stock price and the collateralization ratio.
- **Burning**: Users can burn their BBCA tokens to release the collateral back to their wallet.
- **Stock Oracle**: A simple oracle contract is included to update and retrieve stock prices for BBCA and ETH.

## Smart Contracts

### tokenize.sol

This contract manages the core functionality of the LiskEquityID platform.

- **Collateralization Ratio**: The collateralization ratio is set to 150%, ensuring that all minted tokens are backed by ETH at a secure rate.
- **Deposit ETH**: Users deposit ETH tokens, which serve as collateral for minting BBCA tokens.
- **Mint Tokens**: Users mint BBCA tokens by locking up ETH as collateral.
- **Burn Tokens**: Users burn BBCA tokens to release their collateral.

### oracle.sol

This is a simple oracle contract that allows the owner to update stock prices for BBCA and ETH. The contract stores these prices and allows other contracts to retrieve them.
