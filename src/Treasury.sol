// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Treasury {
    address[] public minters;

    constructor(address[] memory _minters) {
        minters = _minters;
    }

    modifier onlyMinters() {
        bool isMinter = false;
        for (uint256 i = 0; i < minters.length; i++) {
            if (minters[i] == msg.sender) {
                isMinter = true;
                break;
            }
        }
        require(isMinter, "Not authorized");
        _;
    }

    function addMinter(address newMinter) public onlyMinters {
        minters.push(newMinter);
    }

    function mintToken(address tokenAddress, address to, uint64 amount) public onlyMinters {
        HTS.mintToken(tokenAddress, amount);
        HTS.transferToken(tokenAddress, address(this), to, amount);
    }
}
