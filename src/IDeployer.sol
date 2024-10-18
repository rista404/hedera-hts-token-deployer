// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDeployer {
    error TokenNameEmpty();
    error TokenSymbolEmpty();

    event TokenDeployed(address indexed tokenAddress);

    function deploy(bytes32 salt, string memory name, string memory symbol, uint8 decimals)
        external
        payable
        returns (address tokenAddress);
}
