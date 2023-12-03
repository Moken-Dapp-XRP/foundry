// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";
import {SetupProperty} from "@setup/SetupProperty.sol";

contract DeployLilium is Script {
    SetupProperty helperConfig = new SetupProperty();

    function run() external {
        (
            string memory _name,
            string memory _symbol,
            string memory _uri,
            uint256 _rentPerDay,
            address _owner
        ) = helperConfig.propertyArgs();
        address property;
        address mokenAddress = 0x0002Af258b86fAAC590630BB2a07740576E134b8;

        (bool success, bytes memory data) = mokenAddress.call(
            abi.encodeWithSignature(
                "newProperty(string,string,string,uint256,address)",
                _name,
                _symbol,
                _uri,
                _rentPerDay,
                _owner
            )
        );

        require(success, "Failed to call newProperty");
        
        assembly {
            property := mload(add(data, 32))
        }

        console.log("Property address:", property);
    }
}
