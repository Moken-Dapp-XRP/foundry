//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Moken} from "@contracts/factory/Moken.sol";
import {Property} from "@contracts/nft/ERC721/Property.sol";

contract MokenTest is Test {
    Moken moken;
    address mokenOwner = vm.addr(1);
    address propertyOwner = vm.addr(2);
    address newMokenOwner = vm.addr(3);
    address tenant = vm.addr(4);

    function setUp() public {
        vm.prank(mokenOwner);
        moken = new Moken();

        vm.prank(propertyOwner);
        address property = moken.newProperty(
            "name",
            "symbol",
            "uri",
            0.1 ether,
            propertyOwner
        );

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        (bool success, ) = property.call{value: 0.1 ether}(
            abi.encodeWithSignature("bookingADay(uint256)", 8)
        );
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

    function testWithdraw() public {
        vm.prank(mokenOwner);
        moken.withdraw();
        uint256 balance = address(moken).balance;
        assertEq(balance, 0);
    }
}
