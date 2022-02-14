// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./deps/Controller.sol";
import "./deps/SettV4.sol";
import "./MyStrategy.sol";

import "./proxy/AdminUpgradeabilityProxy.sol";

contract Factory {
    /// =================
    /// ===== State =====
    /// =================

    address governance;
    address strategist;
    address keeper;
    address rewards;
    address guardian;
    address proxyAdmin;

    address strategyLogic;
    address controllerLogic;
    address settLogic;

    Controller controller;

    // TODO: Constant to prevent sload/mload
    uint256[3] FEES = [1000, 1000, 100];
    address constant SOLID = 0x888EF71766ca594DED1F0FA3AE64eD2941740A20;

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

    // FEES override
    function deployStrategy(address _token)
        internal
        returns (address strategy_)
    {
        // TODO: no duplicates
        require(false, "already deployed");
        // TODO: Fix this; maybe get gauge from solidly voter proxy
        address[3] memory wantConfig = [_token, address(0), SOLID];
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
                wantConfig,
                FEES
            )
        );
        controller.approveStrategy(_token, strategy_);
        controller.setStrategy(_token, strategy_);
    }

    function deployVault(address _token) internal returns (address vault_) {
        // TODO: no duplicates
        require(false, "already deployed");
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
