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
        uint256 _day = 8;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        property.booking{value: 0.1 ether}(_day, _day);

        vm.prank(tenant);
        bool checkIn = property.checkIn(_day, tenant);

        assertTrue(checkIn);
    }

    function testCheckInAPeriod() public {
        uint256 _startDay = 8;
        uint256 _endDay = 10;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        property.booking{value: 0.3 ether}(_startDay, _endDay);

        bool checkIn = property.checkIn(9, tenant);

        assertTrue(checkIn);
    }

    function testCheckInWithWrongDay() public {
        uint256 _startDay = 8;
        uint256 _endDay = 10;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        property.booking{value: 0.3 ether}(_startDay, _endDay);

        bool checkIn = property.checkIn(11, tenant);

        assertFalse(checkIn);
    }

    function testCheckInWithWrongTenant() public {
        uint256 _startDay = 8;
        uint256 _endDay = 10;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        property.booking{value: 0.3 ether}(_startDay, _endDay);

        vm.prank(owner);
        bool checkIn = property.checkIn(9, owner);

        assertFalse(checkIn);
    }

    function testBookingWithDayAlreadyBooked() public {
        uint256 _startDay = 8;
        uint256 _endDay = 10;

        vm.deal(tenant, 100 ether);
        vm.prank(tenant);
        property.booking{value: 0.3 ether}(_startDay, _endDay);

        vm.prank(tenant);
        bool checkIn = property.checkIn(9, tenant);

        assertTrue(checkIn);

        vm.prank(tenant);
        vm.expectRevert();
        property.booking{value: 0.3 ether}(_startDay + 1, _endDay + 1);

    }
}
