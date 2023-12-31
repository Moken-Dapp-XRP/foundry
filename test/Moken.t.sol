//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";
import {Property} from "@contracts/nft/ERC721/Property.sol";

contract MokenTest is Test {
    Moken moken;
    Property property;
    address mokenOwner = vm.addr(1);
    address propertyOwner = vm.addr(2);
    address newMokenOwner = vm.addr(3);
    address tenant = vm.addr(4);

    function setUp() public {
        vm.prank(mokenOwner);
        moken = new Moken();

        vm.prank(propertyOwner);
        address property_address = moken.newProperty(
            "name",
            "symbol",
            "uri",
            0.1 ether,
            propertyOwner
        );

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        Property(property_address).booking{value: 0.4 ether}(8, 11);
    }

    function testAddNewOwner() public {
        vm.prank(mokenOwner);
        moken.addNewOwner(newMokenOwner);
        bool status = moken.hasRole(moken.OWNER_ROLE(), newMokenOwner);
        assertTrue(status);
    }

    function testNewProperty() public {
        vm.prank(propertyOwner);
        moken.newProperty("name", "symbol", "uri", 0.1 ether, propertyOwner);
        address[] memory properties = moken.getAllProperties();
        assertEq(properties.length, 2);
    }

    function testGetAllProperties() public {
        address[] memory properties = moken.getAllProperties();
        assertEq(properties.length, 1);
    }

    function testGetAllPropertiesByOwner() public {
        address[] memory propertiesByOwner = moken.getAllPropertiesByOwner(
            propertyOwner
        );
        assertEq(propertiesByOwner.length, 1);
    }

    function testWithdraw() public {
        vm.prank(mokenOwner);
        moken.withdraw();
        uint256 balance = address(moken).balance;
        assertEq(balance, 0);
    }
}
