// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

// NOT SURE WHAT THSI CONTRACT DOES, but you claim stuff
interface IveDist {
    function claimable(uint _tokenId) external view returns (uint);
    function claim(uint _tokenId) external returns (uint);
    function claim_many(uint[] memory _tokenIds) external returns (bool);
}