// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BookingData} from "@structs/BookingData.sol";
import {PropertyData} from "@structs/PropertyData.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Property is
    ERC721,
    ERC721URIStorage,
    ERC721Pausable,
    AccessControl,
    ERC721Burnable
{
    PropertyData public property;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    uint256 private _nextTokenId;

    event FeePayment(address owner, uint256 amount);
    event Withdraw(address owner, uint256 amount);
    event NewBooking(uint256 startDay, uint256 endDay, address tenant);
    event CheckIn(uint256 day, address tenant);

    error FeePaymentFailed(address owner, uint256 amount);
    error WithdrawFailed(address owner, uint256 amount);
    error GrantAllowanceFailed(address sender, uint256 amount);
    error CheckInFailed(uint256 day, address tenant);
    error DayAlreadyBooked(address tenant, uint256 day);
    error BookingFailed(address tenant, uint256 startDay, uint256 endDay, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        address _moken,
        uint256 _rentPerDay,
        address _owner
    ) ERC721(_name, _symbol) {
        property.uri = _uri;
        property.moken = _moken;
        property.rentPerDay = _rentPerDay;
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(OWNER_ROLE, _owner);
    }

    function pause() public onlyRole(OWNER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(OWNER_ROLE) {
        _unpause();
    }

    function updateUri(string memory _uri) public onlyRole(OWNER_ROLE) {
        property.uri = _uri;
    }

    function updateRentPerDay(uint256 _rentPerDay) public onlyRole(OWNER_ROLE) {
        property.rentPerDay = _rentPerDay;
    }

    function addNewOwner(address _newOwner) public onlyRole(OWNER_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _newOwner);
        _grantRole(OWNER_ROLE, _newOwner);
    }

    function booking(uint256 _startDay, uint256 _endDay) public payable {
        if (
            msg.value < property.rentPerDay * (_endDay - _startDay + 1) ||
            _startDay > _endDay
        ) {
            revert BookingFailed(msg.sender, _startDay, _endDay, msg.value);
        } else {
            for (uint256 i = _startDay; i <= _endDay; i++) {
                if (property.bookings[i].status == true) {
                    revert DayAlreadyBooked(msg.sender, i);
                } else {
                    uint256 tokenId = _nextTokenId++;
                    _payFee(msg.value);
                    _safeMint(msg.sender, tokenId);
                    _setTokenURI(tokenId, property.uri);

                    property.bookings[i] = BookingData({
                        tenant: msg.sender,
                        status: true
                    });
                }
            }
        }
    }

    function _payFee(uint256 _amount) private {
        uint256 fee = _amount * 5 / 100;
        (bool success, ) = payable(property.moken).call{value: fee}("");

        if (!success) {
            revert FeePaymentFailed(address(this), fee);
        }
        emit FeePayment(address(this), fee);
    }

    function checkIn(uint256 day, address _tenant) public returns (bool) {
        emit CheckIn(day, _tenant);
        return property.bookings[day].tenant == _tenant;
    }

    function withdraw() public onlyRole(OWNER_ROLE) {
        uint256 balance = address(this).balance;

        (bool payment, ) = payable(property.moken).call{value: balance}("");

        if (!payment) {
            revert WithdrawFailed(msg.sender, balance);
        }

        emit Withdraw(msg.sender, balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Pausable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
