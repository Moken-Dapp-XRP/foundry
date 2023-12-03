// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BookingData} from "@structs/BookingData.sol";

struct PropertyData {
    string uri;
    address moken;
    uint256 rentPerDay;
    mapping(uint256 => BookingData) bookings;
}
