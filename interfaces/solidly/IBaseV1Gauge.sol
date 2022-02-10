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
}
