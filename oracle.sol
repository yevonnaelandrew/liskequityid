// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StockOracle {
    address public owner;
    mapping(string => uint256) public stockPrices;

    event StockPriceUpdated(string symbol, uint256 price);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateStockPrice(string memory symbol, uint256 price) public onlyOwner {
        stockPrices[symbol] = price;
        emit StockPriceUpdated(symbol, price);
    }

    function getStockPrice(string memory symbol) public view returns (uint256) {
        return stockPrices[symbol];
    }
}

