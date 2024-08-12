// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

interface IStockPrice {
    function getStockPrice(string calldata symbol) external view returns (uint256);
}

contract TokenizeBBCA is ERC20, ERC20Burnable, Ownable {
    uint256 public constant COLLATERALIZATION_RATIO = 150; // 150%
    address public stockPriceContractAddress;

    mapping(address => uint256) public ethCollateral;
    mapping(address => uint256) public bbcaMinted;

    event DepositedETH(address indexed user, uint256 amount);
    event MintedBBCA(address indexed user, uint256 amount);
    event BurnedBBCA(address indexed user, uint256 amount, uint256 releasedCollateral);

    constructor(address _stockPriceContractAddress) ERC20("BBCA Token", "BBCA") Ownable(msg.sender) {
        stockPriceContractAddress = _stockPriceContractAddress;
    }

    function depositETH() external payable {
        require(msg.value > 0, "Must send ETH to deposit");
        ethCollateral[msg.sender] += msg.value;
        emit DepositedETH(msg.sender, msg.value);
    }

    function mintTokens(uint256 _bbcaAmount) external {
        require(_bbcaAmount > 0, "Must specify BBCA amount");

        uint256 bbcaPriceInEth = _getBBCAStockPriceInEth();
        uint256 requiredCollateral = (_bbcaAmount * bbcaPriceInEth * COLLATERALIZATION_RATIO) / 100;

        require(ethCollateral[msg.sender] >= requiredCollateral, "Insufficient collateral to mint this amount of BBCA tokens");

        ethCollateral[msg.sender] -= requiredCollateral;
        bbcaMinted[msg.sender] += _bbcaAmount;

        _mint(msg.sender, _bbcaAmount);
        emit MintedBBCA(msg.sender, _bbcaAmount);
    }

    function burnTokens(uint256 _bbcaAmount) external {
        require(_bbcaAmount > 0, "Must specify BBCA amount");
        require(balanceOf(msg.sender) >= _bbcaAmount, "Insufficient BBCA balance");

        uint256 bbcaPriceInEth = _getBBCAStockPriceInEth();
        uint256 releasedCollateral = (_bbcaAmount * bbcaPriceInEth * COLLATERALIZATION_RATIO) / 100;

        uint256 newRequiredCollateral = (bbcaMinted[msg.sender] * bbcaPriceInEth * COLLATERALIZATION_RATIO) / 100;
        require(ethCollateral[msg.sender] >= newRequiredCollateral, "Burning would make you under-collateralized");

        ethCollateral[msg.sender] -= releasedCollateral;
        bbcaMinted[msg.sender] -= _bbcaAmount;
        _burn(msg.sender, _bbcaAmount);

        (bool success, ) = msg.sender.call{value: releasedCollateral}("");
        require(success, "Transfer failed.");
        
        emit BurnedBBCA(msg.sender, _bbcaAmount, releasedCollateral);
    }

    function _getBBCAStockPriceInEth() internal view returns (uint256) {
        (uint256 priceBBCA, uint256 priceETH) = getCurrentPrices();
        return (priceBBCA * 1 ether) / priceETH;
    }

    function getCurrentPrices() public view returns (uint256 priceBBCA, uint256 priceETH) {
        IStockPrice stockPriceContract = IStockPrice(stockPriceContractAddress);
        priceBBCA = stockPriceContract.getStockPrice("BBCA");
        require(priceBBCA > 0, "Invalid BBCA stock price");

        priceETH = stockPriceContract.getStockPrice("ETH");
        require(priceETH > 0, "Invalid ETH price");
    }
}

