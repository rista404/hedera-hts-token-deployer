// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IManager {
    function mint(address tokenAddress, address to, uint64 amount) external;
}
