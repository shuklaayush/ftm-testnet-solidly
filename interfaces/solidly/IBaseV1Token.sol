// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IBaseV1Token {
    function minter() external view returns (address);

    function approve(address spender, uint value) external returns (bool);
    function mint(address, uint) external;
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function transfer(address, address, uint) external returns (bool);
}
