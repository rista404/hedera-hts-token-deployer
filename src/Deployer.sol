// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IDeployer} from "./IDeployer.sol";
import {Treasury} from "./Treasury.sol";
import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Deployer is IDeployer {
    function deploy(bytes32, string calldata name, string calldata symbol, uint8 decimals)
        public
        payable
        returns (address tokenAddress)
    {
        if (bytes(name).length == 0) revert TokenNameEmpty();
        if (bytes(symbol).length == 0) revert TokenSymbolEmpty();

        address manager = address(this);

        IHederaTokenService.HederaToken memory token;
        token.name = name;
        token.symbol = symbol;
        token.treasury = manager;

        IHederaTokenService.TokenKey[] memory tokenKeys = new IHederaTokenService.TokenKey[](1);
        // Define the supply keys - minters
        IHederaTokenService.KeyValue memory supplyKeyITS = IHederaTokenService.KeyValue({
            inheritAccountKey: false,
            contractId: manager,
            ed25519: "",
            ECDSA_secp256k1: "",
            delegatableContractId: address(0)
        });
        tokenKeys[0] = IHederaTokenService.TokenKey({keyType: HTS.SUPPLY_KEY_BIT, key: supplyKeyITS});
        token.tokenKeys = tokenKeys;

        IHederaTokenService.Expiry memory expiry = IHederaTokenService.Expiry(0, manager, 8000000);
        token.expiry = expiry;

        address createdTokenAddress = HTS.createFungibleToken(token, 100, int32(uint32(decimals)));

        tokenAddress = createdTokenAddress;

        emit TokenDeployed(tokenAddress);
    }
}
