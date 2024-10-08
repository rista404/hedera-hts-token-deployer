// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {HederaResponseCodes} from "./HederaResponseCodes.sol";
import {IHederaTokenService} from "./IHederaTokenService.sol";

/**
 * @title HTS
 * @notice This library provides a set of functions to interact with the Hedera Token Service (HTS).
 * It includes functionalities for creating, transferring, minting, and burning tokens, as well as querying token information and associating tokens with accounts.
 *
 * @dev This library includes a subset of the Hedera provided system library [HederaTokenService](https://github.com/hashgraph/hedera-smart-contracts/blob/bc3a549c0ca062c51b0045fd1916fdaa0558a360/contracts/system-contracts/hedera-token-service/HederaTokenService.sol).
 * Functions are modified to revert instead of returning response codes.
 * The library includes custom errors and additional functions.
 */
library HTS {
    address private constant PRECOMPILE = address(0x167);

    // 4th bit: supplyKey
    uint256 internal constant SUPPLY_KEY_BIT = 1 << 4;

    // 90 days in seconds
    int32 private constant DEFAULT_AUTO_RENEW = 7776000;

    /// @dev See HederaResponseCodes for a list of possible response codes.
    error HTSCallFailed(int32 responseCode);

    /// Creates a Fungible Token with the specified properties
    /// @param token the basic properties of the token being created
    /// @param initialTotalSupply Specifies the initial supply of tokens to be put in circulation. The
    /// initial supply is sent to the Treasury Account. The supply is in the lowest denomination possible.
    /// @param decimals the number of decimal places a token is divisible by
    /// @return tokenAddress the created token's address
    function createFungibleToken(IHederaTokenService.HederaToken memory token, int64 initialTotalSupply, int32 decimals)
        internal
        returns (address tokenAddress)
    {
        if (token.expiry.second == 0 && token.expiry.autoRenewPeriod == 0) {
            token.expiry.autoRenewPeriod = DEFAULT_AUTO_RENEW;
        }

        (bool success, bytes memory result) = PRECOMPILE.call{value: msg.value}(
            abi.encodeWithSelector(
                IHederaTokenService.createFungibleToken.selector, token, initialTotalSupply, decimals
            )
        );

        int32 responseCode;
        (responseCode, tokenAddress) =
            success ? abi.decode(result, (int32, address)) : (HederaResponseCodes.UNKNOWN, address(0));

        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert HTSCallFailed(responseCode);
        }
    }
}
