//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {BookingData} from "@structs/BookingData.sol";
import {Property} from "@contracts/nft/ERC721/Property.sol";

contract PropertyTest is Test {
    Property property;
    address moken = vm.addr(1);
    address owner = vm.addr(2);
    address tenant = vm.addr(3);

    function setUp() public {
        vm.prank(owner);
        property = new Property("name", "symbol", "uri", moken, 0.1 ether, owner);
    }

    function testUpdateUri() public {
        string
            memory newUri = "QmSnz3AgD8JACWCBnbob5UM3RSigLPaNSaiP2sWMMANUMANU";
        vm.prank(owner);
        property.updateUri(newUri);
        (string memory uri, , ) = property.property();
        assertEq(uri, newUri);
    }

    function testUpdateRentPerDay() public {
        uint256 newRentPerDay = 200;
        vm.prank(owner);
        property.updateRentPerDay(newRentPerDay);
        (, , uint256 rentPerDay) = property.property();
        assertEq(rentPerDay, newRentPerDay);
    }

    function testAddNewOwner() public {
        vm.prank(owner);
        property.addNewOwner(tenant);
        bool status = property.hasRole(property.OWNER_ROLE(), tenant);
        assertTrue(status);
    }

    function testCheckInADay() public {
        uint256 day = 8;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        (bool booking, ) = address(property).call{value: 0.1 ether}(
            abi.encodeWithSignature("bookingADay(uint256)", day)
        );

        vm.prank(tenant);
        bool checkIn = property.checkIn(day, tenant);

        assertTrue(checkIn);
    }
}
