// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface IBaseV1Gauge {
    function stake() external view returns (address);

    function balanceOf(address) external view returns (uint);
    function deposit(uint amount, uint tokenId) external;
    function withdrawAll() external;
    function withdraw(uint amount) external;
    function earned(address token, address account) external view returns (uint);

    function getReward(address account, address[] memory tokens) external;
    function derivedBalance(address account) external view returns (uint);
    function rewardRate(address) external view returns (uint);
    function rewardPerToken(address token) external view returns (uint);
    function rewardPerTokenStored(address token) external view returns (uint);
    function userRewardPerTokenStored(address token, address account) external view returns (uint);
    function lastTimeRewardApplicable(address token) external view returns (uint);
    function lastUpdateTime(address token) external view returns (uint);
    function periodFinish(address token) external view returns (uint);

    function checkpoints(address, uint) external view returns (uint, uint);
    function numCheckpoints(address) external view returns (uint);
    function getPriorBalanceIndex(address, uint) external view returns (uint);
    function getPriorRewardPerToken(address, uint) external view returns (uint, uint);

}
