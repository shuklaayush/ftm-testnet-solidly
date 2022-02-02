from brownie import (
    accounts,
    interface,
    Controller,
    SettV4,
    MyStrategy,
)
from config import (
    BADGER_DEV_MULTISIG,
    WANT,
    LP_COMPONENT,
    REWARD_TOKEN,
    PROTECTED_TOKENS,
    FEES,
)
from dotmap import DotMap
import pytest

@pytest.fixture
def pair():
    return interface.underlying("0xa3502f18766b17a07B487C6F395A23d3ef67D4DE")

@pytest.fixture
def router():
    return interface.IBaseV1Router01("0x22460Cd07159EC690166860f15966C1446ED762B")

@pytest.fixture
def minter():
    return interface.IBaseV1Minter("0x3230F944a26288f49F5010b11BA96b0b9dC84e79")

@pytest.fixture
def ve(): 
    return interface.ve("0xBE6bb6d9F4B1Bc2Ea1C0d69a17471b98bd164ab6")

@pytest.fixture
def voter():  
    return interface.IBaseV1Voter("0xd2F7fF8e5b362bafE2b57a82c5865B4355F884Ae")

@pytest.fixture
def gauge():  
    return interface.IBaseV1Gauge("0xdeb44B8d020952942734b370768F44b4F3226afd")

@pytest.fixture
def baseToken():  
    return interface.underlying("0x0673e1CF8EE91095232CFC98Ee1EbCeF42A1977E")
    
@pytest.fixture
def custom_setup(pair, router, minter, ve, voter, gauge, baseToken):
    wftm = interface.underlying("0x27Ce41c3cb9AdB5Edb2d8bE253A1c6A64Db8c96d")
    ftm = interface.WETH("0x27Ce41c3cb9AdB5Edb2d8bE253A1c6A64Db8c96d")
    usdt = interface.underlying("0x8ad96050318043166114884b59E2fc82210273b3")

    dev = accounts[0]
    AMT = 1000e18
    ## Mint token
    baseToken.mint(dev, AMT, {"from": dev})
    ## Approve for locking
    baseToken.approve(ve, AMT, {"from": dev})
    ## Lock for 4 years
    lock_tx = ve.create_lock(AMT, 4 * 365 * 86400, {"from": dev})

    ## Vote
    LOCK_ID = lock_tx.return_value
    voter.vote(LOCK_ID, [pair], [100], {"from": dev})


    ## Mint wFTM
    ftm.deposit({"from": dev, "value": 1e18})
    wftm.balanceOf(dev)
    # Mint USDT
    usdt.mint(dev, 3000e18, {"from": dev})

    ## Approve router
    wftm.approve(router, wftm.balanceOf(dev), {"from": dev})
    usdt.approve(router, usdt.balanceOf(dev), {"from": dev})

    ## Add liquidity
    router.addLiquidity(wftm, usdt, False, wftm.balanceOf(dev), usdt.balanceOf(dev), 0, 0, dev, 999999999999999999999, {"from": dev})

    ## Confirm liqudiity is in
    pair.balanceOf(dev)

    ## Approve the gauge
    pair.approve(gauge, pair.balanceOf(dev), {"from": dev})

@pytest.fixture
def deployed(custom_setup):
    """
    Deploys, vault, controller and strats and wires them up for you to test
    """
    deployer = accounts[0]

    strategist = deployer
    keeper = deployer
    guardian = deployer

    governance = accounts.at(BADGER_DEV_MULTISIG, force=True)

    controller = Controller.deploy({"from": deployer})
    controller.initialize(BADGER_DEV_MULTISIG, strategist, keeper, BADGER_DEV_MULTISIG)

    sett = SettV4.deploy({"from": deployer})
    sett.initialize(
        WANT,
        controller,
        BADGER_DEV_MULTISIG,
        keeper,
        guardian,
        False,
        "prefix",
        "PREFIX",
    )

    sett.unpause({"from": governance})
    controller.setVault(WANT, sett)

    ## TODO: Add guest list once we find compatible, tested, contract
    # guestList = VipCappedGuestListWrapperUpgradeable.deploy({"from": deployer})
    # guestList.initialize(sett, {"from": deployer})
    # guestList.setGuests([deployer], [True])
    # guestList.setUserDepositCap(100000000)
    # sett.setGuestList(guestList, {"from": governance})

    ## Start up Strategy
    strategy = MyStrategy.deploy({"from": deployer})
    strategy.initialize(
        BADGER_DEV_MULTISIG,
        strategist,
        controller,
        keeper,
        guardian,
        PROTECTED_TOKENS,
        FEES,
    )

    ## Tool that verifies bytecode (run independently) <- Webapp for anyone to verify

    ## Set up tokens
    want = interface.IERC20(WANT)
    lpComponent = interface.IERC20(LP_COMPONENT)
    rewardToken = interface.IERC20(REWARD_TOKEN)

    ## Wire up Controller to Strart
    ## In testing will pass, but on live it will fail
    controller.approveStrategy(WANT, strategy, {"from": governance})
    controller.setStrategy(WANT, strategy, {"from": deployer})

    return DotMap(
        deployer=deployer,
        controller=controller,
        vault=sett,
        sett=sett,
        strategy=strategy,
        # guestList=guestList,
        want=want,
        lpComponent=lpComponent,
        rewardToken=rewardToken,
        
    )




## Contracts ##


@pytest.fixture
def vault(deployed):
    return deployed.vault


@pytest.fixture
def sett(deployed):
    return deployed.sett


@pytest.fixture
def controller(deployed):
    return deployed.controller


@pytest.fixture
def strategy(deployed):
    return deployed.strategy


## Tokens ##


@pytest.fixture
def want(deployed):
    return deployed.want


@pytest.fixture
def tokens():
    return [WANT, LP_COMPONENT, REWARD_TOKEN]


## Accounts ##


@pytest.fixture
def deployer(deployed):
    return deployed.deployer


@pytest.fixture
def strategist(strategy):
    return accounts.at(strategy.strategist(), force=True)


@pytest.fixture
def settKeeper(vault):
    return accounts.at(vault.keeper(), force=True)


@pytest.fixture
def strategyKeeper(strategy):
    return accounts.at(strategy.keeper(), force=True)

## Forces reset before each test
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass
