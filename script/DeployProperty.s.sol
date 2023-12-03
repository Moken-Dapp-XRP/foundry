// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";
import {SetupProperty} from "@setup/SetupProperty.sol";

contract DeployLilium is Script {
    address moken = 0x0002Af258b86fAAC590630BB2a07740576E134b8;
    SetupProperty helperConfig = new SetupProperty();

    function run() external {
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
