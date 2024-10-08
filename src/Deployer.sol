// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Deployer {
    error TokenNameEmpty();
    error TokenSymbolEmpty();

    event TokenDeployed(address indexed tokenAddress);

    function deploy(string memory name, string memory symbol, uint8 decimals)
        public
        payable
        returns (address tokenAddress)
    {
        if (bytes(name).length == 0) revert TokenNameEmpty();
        if (bytes(symbol).length == 0) revert TokenSymbolEmpty();

        IHederaTokenService.HederaToken memory token;
        token.name = name;
        token.symbol = symbol;

        IHederaTokenService.TokenKey[] memory tokenKeys = new IHederaTokenService.TokenKey[](0);

        token.tokenKeys = tokenKeys;

        address createdTokenAddress = HTS.createFungibleToken(token, 0, int32(uint32(decimals)));

        tokenAddress = createdTokenAddress;

        emit TokenDeployed(tokenAddress);
    }
}
