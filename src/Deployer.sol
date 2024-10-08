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

        address treasury = address(0x8d5AF9D897a80afCAf854202ACf6d2641378ba6C);

        IHederaTokenService.HederaToken memory token;
        token.name = name;
        token.symbol = symbol;
        token.treasury = treasury;

        IHederaTokenService.TokenKey[] memory tokenKeys = new IHederaTokenService.TokenKey[](1);

        // Define the supply keys - minters
        IHederaTokenService.KeyValue memory supplyKeyITS = IHederaTokenService.KeyValue({
            inheritAccountKey: false,
            contractId: msg.sender,
            ed25519: "",
            ECDSA_secp256k1: "",
            delegatableContractId: address(0)
        });
        tokenKeys[0] = IHederaTokenService.TokenKey({keyType: HTS.SUPPLY_KEY_BIT, key: supplyKeyITS});

        IHederaTokenService.Expiry memory expiry = IHederaTokenService.Expiry(0, treasury, 8000000);
        token.expiry = expiry;

        token.tokenKeys = tokenKeys;

        address createdTokenAddress = HTS.createFungibleToken(token, 100, int32(uint32(decimals)));

        tokenAddress = createdTokenAddress;

        emit TokenDeployed(tokenAddress);
    }
}
