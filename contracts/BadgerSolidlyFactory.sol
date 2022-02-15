// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./deps/Controller.sol";
import "./deps/SettV4.sol";
import "./MyStrategy.sol";
import "./proxy/AdminUpgradeabilityProxy.sol";
import "../interfaces/solidly/IBaseV1Voter.sol";

contract BadgerSolidlyFactory {
    /// =====================
    /// ===== Constants =====
    /// =====================

    // TODO: Maybe make settable and not constants
    uint256 public constant PERFORMANCE_FEE_GOVERNANCE = 1000;
    uint256 public constant PERFORMANCE_FEE_STRATEGIST = 1000;
    uint256 public constant WITHDRAW_FEE = 100;

    address public constant SOLID = 0x888EF71766ca594DED1F0FA3AE64eD2941740A20;

    IBaseV1Voter public constant SOLIDLY_VOTER =
        IBaseV1Voter(0xdC819F5d05a6859D2faCbB4A44E5aB105762dbaE);

    /// =================
    /// ===== State =====
    /// =================

    address public governance;
    address public strategist;
    address public keeper;
    address public rewards;
    address public guardian;
    address public proxyAdmin;

    address public strategyLogic;
    address public controllerLogic;
    address public settLogic;

    Controller public controller;

    constructor(
        address _governance,
        address _strategist,
        address _keeper,
        address _guardian,
        address _rewards,
        address _proxyAdmin
    ) public {
        governance = _governance;
        strategist = _strategist;
        keeper = _keeper;
        guardian = _guardian;
        rewards = _rewards;
        proxyAdmin = _proxyAdmin;

        strategyLogic = address(new MyStrategy());
        controllerLogic = address(new Controller());
        settLogic = address(new SettV4());

        controller = Controller(
            deployProxy(
                controllerLogic,
                _proxyAdmin,
                abi.encodeWithSelector(
                    Controller.initialize.selector,
                    _governance,
                    _strategist,
                    _keeper,
                    _rewards
                )
            )
        );
    }

    /// ====================
    /// ===== External =====
    /// ====================

    function deploy(address _want)
        external
        returns (address strategy_, address vault_)
    {
        strategy_ = deployStrategy(_want);
        vault_ = deployVault(_want);
    }

    /// ============================
    /// ===== Internal helpers =====
    /// ============================

    function deployStrategy(address _token)
        internal
        returns (address strategy_)
    {
        require(
            controller.strategies(_token) == address(0),
            "already deployed"
        );

        strategy_ = deployProxy(
            strategyLogic,
            proxyAdmin,
            abi.encodeWithSelector(
                MyStrategy.initialize.selector,
                governance,
                strategist,
                address(controller),
                keeper,
                guardian,
                [_token, SOLIDLY_VOTER.gauges(_token), SOLID],
                [
                    PERFORMANCE_FEE_GOVERNANCE,
                    PERFORMANCE_FEE_STRATEGIST,
                    WITHDRAW_FEE
                ]
            )
        );
        controller.approveStrategy(_token, strategy_);
        controller.setStrategy(_token, strategy_);
    }

    function deployVault(address _token) internal returns (address vault_) {
        require(controller.vaults(_token) == address(0), "already deployed");

        vault_ = deployProxy(
            settLogic,
            proxyAdmin,
            abi.encodeWithSelector(
                SettV4.initialize.selector,
                _token,
                address(controller),
                governance,
                keeper,
                guardian,
                false,
                "",
                ""
            )
        );
        controller.setVault(_token, vault_);
    }

    function deployProxy(
        address _logic,
        address _admin,
        bytes memory _data
    ) internal returns (address proxy_) {
        proxy_ = address(new AdminUpgradeabilityProxy(_logic, _admin, _data));
    }
}
