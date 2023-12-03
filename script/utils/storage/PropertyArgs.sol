// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BookingData} from "@structs/BookingData.sol";

struct PropertyArgs {
    string name;
    string symbol;
    string uri;
    uint256 rentPerDay;
    address owner;
}
