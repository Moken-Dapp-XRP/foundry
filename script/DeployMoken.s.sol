// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";

contract DeployLilium is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Moken moken = new Moken();
        vm.stopBroadcast();
        console.log("Moken address:", address(moken));
    }
}
