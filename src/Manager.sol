// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IDeployer} from "./IDeployer.sol";
import {IManager} from "./IManager.sol";
import {IMinter} from "./IMinter.sol";
import {HTS, IHederaTokenService} from "./hedera/HTS.sol";

contract Manager is IDeployer, IManager {
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
        (bool success, bytes memory data) =
            deployer.delegatecall(abi.encodeWithSignature("deploy(string,string,uint8)", name, symbol, decimals));
        require(success, "Delegatecall failed");
        tokenAddress = abi.decode(data, (address));
    }

    function mint(address tokenAddress, address to, uint64 amount) external {
        IMinter(minter).mintToken(tokenAddress, to, amount);
    }
}
