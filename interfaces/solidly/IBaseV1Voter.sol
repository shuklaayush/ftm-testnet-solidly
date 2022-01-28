// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


interface IBaseV1Voter {
    function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint _tokenId) external;
    function claimFees(address[] memory _bribes, address[][] memory _tokens, uint _tokenId) external;
    function distribute() external;
    function vote(uint tokenId, address[] calldata _poolVote, uint[] calldata _weights) external;
    function claimable(address gauge) external view returns (uint256);

    function claimRewards(address[] memory _gauges, address[][] memory _tokens) external;
}