// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";
import {SetupProperty} from "@setup/SetupProperty.sol";

contract DeployProperty is Script {
    address moken = 0x330D0349ed3c5A8a212CC15EeBA92A6b4807dDF4;
    SetupProperty helperConfig = new SetupProperty();

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        (
            string memory _name,
            string memory _symbol,
            string memory _uri,
            uint256 _rentPerDay,
            address _owner
        ) = helperConfig.propertyArgs();

        (bool success, bytes memory data) = moken.call(
            abi.encodeWithSignature(
                "newProperty(string,string,string,uint256,address)",
                _name,
                _symbol,
                _uri,
                _rentPerDay,
                _owner
            )
        );
        vm.stopBroadcast();

        if (!success) {
            console.log("Error deploying property");
            return;
        } else {
            address property;
            assembly {
                property := mload(add(data, 32))
            }
            console.log("Property address:", property);
        }
    }
}
