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
    
    function pools(uint256) external view returns (address);
    function gauges(address) external view returns (address);
    function poolForGauge(address) external view returns (address);
    function bribes(address) external view returns (address);
    function weights(address) external view returns (uint);
    function votes(uint, address) external view returns (uint);
    function poolVote(uint) external view returns (address[] memory);
}