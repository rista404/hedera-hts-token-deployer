// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Deployer} from "../src/Deployer.sol";
import {Caller} from "../src/Caller.sol";
import {Minter} from "../src/Minter.sol";

contract DeployScript is Script {
    Deployer public deployer;
    Caller public caller;
    Minter public minter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the Minter contract with the address of the Deployer contract
        minter = new Minter();
        console.log("Minter deployed at:", address(minter));

        // Deploy the Deployer contract
        deployer = new Deployer();
        console.log("Deployer deployed at:", address(deployer));

        // Deploy the Caller contract with the address of the Deployer contract
        caller = new Caller(address(deployer));
        console.log("Caller deployed at:", address(caller));

        vm.stopBroadcast();
    }
}
