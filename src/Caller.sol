// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IDeployer.sol";

contract Caller {
    IDeployer public immutable deployer;

    constructor(address _deployer) {
        deployer = IDeployer(_deployer);
    }

    function deploy(string memory name, string memory symbol, uint8 decimals) public payable {
        deployer.deploy{value: msg.value}(name, symbol, decimals);
    }
}
