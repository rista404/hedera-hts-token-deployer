// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IManager {
    function mint(address tokenAddress, address to, uint64 amount) external;

    function deploy(string memory name, string memory symbol, uint8 decimals)
        external
        payable
        returns (address tokenAddress);
}
