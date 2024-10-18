// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IManager.sol";

contract Caller {
    IManager public immutable manager;

    constructor(address _manager) {
        manager = IManager(_manager);
    }

    function deploy(string memory name, string memory symbol, uint8 decimals) public payable {
        manager.deploy{value: msg.value}(name, symbol, decimals);
    }
}
