// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Property} from "@contracts/nft/ERC721/Property.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract Moken is AccessControl {
    address[] public properties;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    mapping(address => address[]) public propertiesByOwner;

    event FeeReceived(address owner, uint256 amount);
    event Withdraw(address owner, uint256 amount);
    event NewProperty(address indexed property, address indexed owner);

    error WithdrawFailed(address owner, uint256 amount);

    constructor() {
        _addNewOwner(msg.sender);
    }

    function addNewOwner(
        address _newOwner
    ) public onlyRole(OWNER_ROLE) returns (bool) {
        return _addNewOwner(_newOwner);
    }

    function _addNewOwner(address _newOwner) private returns (bool) {
        _grantRole(DEFAULT_ADMIN_ROLE, _newOwner);
        _grantRole(OWNER_ROLE, _newOwner);
        return true;
    }

    function newProperty(
        string memory _name,
        string memory _symbol,
        string calldata _uri,
        uint256 _rentPerDay,
        address _owner
    ) public returns (address) {
        Property property = new Property(
            _name,
            _symbol,
            _uri,
            address(this),
            _rentPerDay,
            _owner
        );
        propertiesByOwner[_owner].push(address(property));
        properties.push(address(property));
        emit NewProperty(address(property), _owner);
        return address(property);
    }

    function getAllPropertiesByOwner(
        address _owner
    ) public view returns (address[] memory) {
        return propertiesByOwner[_owner];
    }

    function getAllProperties() public view returns (address[] memory) {
        return properties;
    }

    receive() external payable {
        emit FeeReceived(msg.sender, msg.value);
    }

    function withdraw() public onlyRole(OWNER_ROLE) {
        uint256 balance = address(this).balance;

        (bool payment, ) = payable(msg.sender).call{value: balance}("");

        if (!payment) {
            revert WithdrawFailed(msg.sender, balance);
        }
        emit Withdraw(msg.sender, balance);
    }
}
