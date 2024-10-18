// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IDeployer} from "./IDeployer.sol";
import {IManager} from "./IManager.sol";
import {IMinter} from "./IMinter.sol";
import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Manager is IManager {
    address public deployer;
    address public minter;

    constructor(address _deployer, address _minter) {
        deployer = _deployer;
        minter = _minter;
    }

    function deploy(string memory name, string memory symbol, uint8 decimals)
        public
        payable
        returns (address tokenAddress)
    {
        bytes32 salt;
        (bool success, bytes memory data) =
            deployer.delegatecall(abi.encodeWithSelector(IDeployer.deploy.selector, salt, name, symbol, decimals));
        require(success, "Delegatecall failed");
        tokenAddress = abi.decode(data, (address));
    }

    function mint(address tokenAddress, address to, uint64 amount) external {
        HTS.mintToken(tokenAddress, amount);
        HTS.transferToken(tokenAddress, address(this), to, amount);
    }

    function burn(address tokenAddress, address from, uint64 amount) external {
        HTS.transferFrom(tokenAddress, from, address(this), amount);
        HTS.burnToken(tokenAddress, amount);
    }
}
