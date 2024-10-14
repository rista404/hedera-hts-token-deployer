// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Minter {
    // assuming the caller is the Treasury (Manager)
    function mintToken(address tokenAddress, address to, uint64 amount) public {
        HTS.mintToken(tokenAddress, amount);
        HTS.transferToken(tokenAddress, msg.sender, to, amount);
    }
}
