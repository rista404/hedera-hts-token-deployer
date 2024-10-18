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

    /// @dev Thrown when the amount to mint/burn is invalid (negative or out of bounds).
    error InvalidAmount();

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

    /// Mints an amount of the token to the defined treasury account
    /// @param token The token for which to mint tokens. If token does not exist, transaction results in
    ///              INVALID_TOKEN_ID
    /// @param amount Applicable to tokens of type FUNGIBLE_COMMON. The amount to mint to the Treasury Account.
    ///               Amount must be a positive non-zero number represented in the lowest denomination of the
    ///               token. The new supply must be lower than 2^63.
    /// @return newTotalSupply The new supply of tokens. For NFTs it is the total count of NFTs
    function mintToken(address token, uint256 amount) internal returns (int64 newTotalSupply) {
        if (amount <= 0 || amount > uint256(int256(type(int64).max))) {
            revert InvalidAmount();
        }

        bytes[] memory metadata;
        int64 amountInt64 = int64(int256(amount));
        (bool success, bytes memory result) = PRECOMPILE.call(
            abi.encodeWithSelector(IHederaTokenService.mintToken.selector, token, amountInt64, metadata)
        );
        int32 responseCode;
        (responseCode, newTotalSupply,) = success
            ? abi.decode(result, (int32, int64, int64[]))
            : (HederaResponseCodes.UNKNOWN, int64(0), new int64[](0));
        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert HTSCallFailed(responseCode);
        }
    }

    /// Transfers tokens where the calling account/contract is implicitly the first entry in the token transfer list,
    /// where the amount is the value needed to zero balance the transfers. Regular signing rules apply for sending
    /// (positive amount) or receiving (negative amount)
    /// @param token The token to transfer to/from
    /// @param sender The sender for the transaction
    /// @param receiver The receiver of the transaction
    /// @param amount Non-negative value to send. a negative value will result in a failure.
    function transferToken(address token, address sender, address receiver, uint256 amount) internal {
        if (amount <= 0 || amount > uint256(int256(type(int64).max))) {
            revert InvalidAmount();
        }
        int64 amountInt64 = int64(int256(amount));
        (bool success, bytes memory result) = PRECOMPILE.call(
            abi.encodeWithSelector(IHederaTokenService.transferToken.selector, token, sender, receiver, amountInt64)
        );
        int32 responseCode;
        responseCode = success ? abi.decode(result, (int32)) : HederaResponseCodes.UNKNOWN;
        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert HTSCallFailed(responseCode);
        }
    }

    /// Transfers `amount` tokens from `from` to `to` using the
    ///  allowance mechanism. `amount` is then deducted from the caller's allowance.
    /// Only applicable to fungible tokens
    /// @param token The address of the fungible Hedera token to transfer
    /// @param from The account address of the owner of the token, on the behalf of which to transfer `amount` tokens
    /// @param to The account address of the receiver of the `amount` tokens
    /// @param amount The amount of tokens to transfer from `from` to `to`
    function transferFrom(address token, address from, address to, uint256 amount) external {
        if (amount <= 0 || amount > uint256(int256(type(int64).max))) {
            revert InvalidAmount();
        }
        int64 amountInt64 = int64(int256(amount));
        (bool success, bytes memory result) = PRECOMPILE.call(
            abi.encodeWithSelector(IHederaTokenService.transferFrom.selector, token, from, to, amountInt64)
        );
        int32 responseCode;
        responseCode = success ? abi.decode(result, (int32)) : HederaResponseCodes.UNKNOWN;
        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert HTSCallFailed(responseCode);
        }
    }

    /// Burns an amount of the token from the defined treasury account
    /// @param token The token for which to burn tokens. If token does not exist, transaction results in
    ///              INVALID_TOKEN_ID
    /// @param amount  Applicable to tokens of type FUNGIBLE_COMMON. The amount to burn from the Treasury Account.
    ///                Amount must be a positive non-zero number, not bigger than the token balance of the treasury
    ///                account (0; balance], represented in the lowest denomination.
    /// @return newTotalSupply The new supply of tokens. For NFTs it is the total count of NFTs
    function burnToken(address token, uint256 amount) internal returns (int64 newTotalSupply) {
        if (amount <= 0 || amount > uint256(int256(type(int64).max))) {
            revert InvalidAmount();
        }
        int64 amountInt64 = int64(int256(amount));
        int64[] memory serialNumbers;
        (bool success, bytes memory result) = PRECOMPILE.call(
            abi.encodeWithSelector(IHederaTokenService.burnToken.selector, token, amountInt64, serialNumbers)
        );
        int32 responseCode;
        (responseCode, newTotalSupply) =
            success ? abi.decode(result, (int32, int64)) : (HederaResponseCodes.UNKNOWN, int64(0));
        if (responseCode != HederaResponseCodes.SUCCESS) {
            revert HTSCallFailed(responseCode);
        }
    }
}
