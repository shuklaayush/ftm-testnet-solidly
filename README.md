## Setup
Add ftm-test-fork network
```
brownie networks import network-config.yaml
```

## Chart
https://miro.com/app/board/uXjVOSancDY=/

## Addresses
Name
wFTM	0x27Ce41c3cb9AdB5Edb2d8bE253A1c6A64Db8c96d
USDT	0x8ad96050318043166114884b59E2fc82210273b3
MIM	0x976e33B07565b0c05B08b2e13AfFD3113e3D178d
BaseV1	0x0673e1CF8EE91095232CFC98Ee1EbCeF42A1977E
Name
BaseV1Factory	0xd231865CE0eDB0079F0D0d7BB2E647458aa60d11
BaseV1GaugesFactory	0x1649BE15FeA4F94075CC69c3502B1Ba4C341bBEa
BaseV1Voter	0xd2F7fF8e5b362bafE2b57a82c5865B4355F884Ae
BaseV1Router01	0x22460Cd07159EC690166860f15966C1446ED762B
ve3	0xBE6bb6d9F4B1Bc2Ea1C0d69a17471b98bd164ab6
ve3-dist	0x4Dc46A325B141751E09871279F9c7Fe214DA422C
BaseV1Minter	0x3230F944a26288f49F5010b11BA96b0b9dC84e79


## Copy paste setup
```
wftm = interface.underlying("0x27Ce41c3cb9AdB5Edb2d8bE253A1c6A64Db8c96d")
ftm = interface.WETH("0x27Ce41c3cb9AdB5Edb2d8bE253A1c6A64Db8c96d")
usdt = interface.underlying("0x8ad96050318043166114884b59E2fc82210273b3")
pair = interface.underlying("0xa3502f18766b17a07B487C6F395A23d3ef67D4DE")
router = interface.IBaseV1Router01("0x22460Cd07159EC690166860f15966C1446ED762B")
minter = interface.IBaseV1Minter("0x3230F944a26288f49F5010b11BA96b0b9dC84e79")
ve = interface.ve("0xBE6bb6d9F4B1Bc2Ea1C0d69a17471b98bd164ab6")
voter = interface.IBaseV1Voter("0xd2F7fF8e5b362bafE2b57a82c5865B4355F884Ae")
gauge = interface.IBaseV1Gauge("0xdeb44B8d020952942734b370768F44b4F3226afd")
baseToken = interface.underlying("0x0673e1CF8EE91095232CFC98Ee1EbCeF42A1977E")

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

## Stake in the gauge
gauge.deposit(pair.balanceOf(dev), LOCK_ID, {"from": dev})
gauge.balanceOf(dev, {"from": dev})

## Sleep 2 weeks
chain.sleep(604800 * 2)
chain.mine()

## Bring emissions forward
minter.update_period({"from": dev})


baseToken.balanceOf(gauge)
## Distribute to gauges
voter.distribute({"from": dev})

baseToken.balanceOf(gauge) ## Should have increased

voter.claimable(gauge) ## Can't make it increase for some reason

## Get the rewards
voter.claimRewards([gauge.address], [[baseToken.address]], {"from": dev})

## See increase in balance!!!
baseToken.balanceOf(dev)
```

# Badger Strategy V1 Brownie Mix

- Video Introduction: https://youtu.be/FVbhgPYW_D0 (note follow installation and setup below before starting the video)

- Example Project: https://github.com/Badger-Finance/wBTC-AAVE-Rewards-Farm-Badger-V1-Strategy
- Full Project Walkthrough: https://www.youtube.com/watch?v=lTb0RFJJx2k
- 1-1 Mentoring (Valid throughout HackMoney and Gitcoin Round 10): https://calendly.com/alex-entreprenerd/badger-hackmoney-1-1

## What you'll find here

- Basic Solidity Smart Contract for creating your own Badger Strategy ([`contracts/MyStrategy.sol`](contracts/MyStrategy.sol))

- Interfaces for some of the most used DeFi protocols on ethereum mainnet. ([`interfaces`](interfaces))
- Dependencies for OpenZeppelin and other libraries. ([`deps`](deps))

- Sample test suite that runs on mainnet fork. ([`tests`](tests))

This mix is configured for use with [Ganache](https://github.com/trufflesuite/ganache-cli) on a [forked mainnet](https://eth-brownie.readthedocs.io/en/stable/network-management.html#using-a-forked-development-network).

## Installation and Setup

1. Use this code by clicking on Use This Template

2. Download the code with `git clone URL_FROM_GITHUB`

3. [Install Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html) & [Ganache-CLI](https://github.com/trufflesuite/ganache-cli), if you haven't already.

4. Copy the `.env.example` file, and rename it to `.env`

5. Sign up for [Infura](https://infura.io/) and generate an API key. Store it in the `WEB3_INFURA_PROJECT_ID` environment variable.

6. Sign up for [Etherscan](www.etherscan.io) and generate an API key. This is required for fetching source codes of the mainnet contracts we will be interacting with. Store the API key in the `ETHERSCAN_TOKEN` environment variable.

7. Install the dependencies in the package

```
## Javascript dependencies
npm i

## Python Dependencies
pip install virtualenv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Basic Use

To deploy the demo Badger Strategy in a development environment:

1. Open the Brownie console. This automatically launches Ganache on a forked mainnet.

```bash
  brownie console
```

2. Run Scripts for Deployment

```
  brownie run 1_production_deploy.py
```

Deployment will set up a Vault, Controller and deploy your strategy

3. Run the test deployment in the console and interact with it

```python
  brownie console
  deployed = run("mock_deploy")

  ## Takes a minute or so
  Transaction sent: 0xa0009814d5bcd05130ad0a07a894a1add8aa3967658296303ea1f8eceac374a9
  Gas price: 0.0 gwei   Gas limit: 12000000   Nonce: 9
  UniswapV2Router02.swapExactETHForTokens confirmed - Block: 12614073   Gas used: 88626 (0.74%)

  ## Now you can interact with the contracts via the console
  >>> deployed
  {
      'controller': 0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6,
      'deployer': 0x66aB6D9362d4F35596279692F0251Db635165871,
      'lpComponent': 0x028171bCA77440897B824Ca71D1c56caC55b68A3,
      'rewardToken': 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9,
      'sett': 0x6951b5Bd815043E3F842c1b026b0Fa888Cc2DD85,
      'strategy': 0x9E4c14403d7d9A8A782044E86a93CAE09D7B2ac9,
      'vault': 0x6951b5Bd815043E3F842c1b026b0Fa888Cc2DD85,
      'want': 0x6B175474E89094C44Da98b954EedeAC495271d0F
  }
  >>>

  ## Deploy also uniswaps want to the deployer (accounts[0]), so you have funds to play with!
  >>> deployed.want.balanceOf(a[0])
  240545908911436022026

```

## Adding Configuration

To ship a valid strategy, that will be evaluated to deploy on mainnet, with potentially $100M + in TVL, you need to:

1. Add custom config in `/config/__init__.py`
2. Write the Strategy Code in MyStrategy.sol
3. Customize the StrategyResolver in `/config/StrategyResolver.py` so that snapshot testing can verify that operations happened correctly
4. Write any extra test to confirm that the strategy is working properly

## Add a custom want configuration

Most strategies have a:

- **want** the token you want to increase the balance of
- **lpComponent** the token representing how much you deposited in the yield source
- **reward** the token you are farming, that you'll swap into **want**

Set these up in `/config/__init__.py` this mix will automatically be set up for testing and deploying after you do so

## Implementing Strategy Logic

[`contracts/MyStrategy.sol`](contracts/MyStrategy.sol) is where you implement your own logic for your strategy. In particular:

- Customize the `initialize` Method
- Set a name in `MyStrategy.getName()`
- Set a version in `MyStrategy.version()`
- Write a way to calculate the want invested in `MyStrategy.balanceOfPool()`
- Write a method that returns true if the Strategy should be tended in `MyStrategy.isTendable()`
- Set a version in `MyStrategy.version()`
- Invest your want tokens via `Strategy._deposit()`.
- Take profits and repay debt via `Strategy.harvest()`.
- Unwind enough of your position to payback withdrawals via `Strategy._withdrawSome()`.
- Unwind all of your positions via `Strategy._withdrawAll()`.
- Rebalance the Strategy positions via `Strategy.tend()`.
- Make a list of all position tokens that should be protected against movements via `Strategy.protectedTokens()`.

## Specifying checks for ordinary operations in config/StrategyResolver

In order to snapshot certain balances, we use the Snapshot manager.
This class helps with verifying that ordinary procedures (deposit, withdraw, harvest), happened correctly.

See `/helpers/StrategyCoreResolver.py` for the base resolver that all strategies use
Edit `/config/StrategyResolver.py` to specify and verify how an ordinary harvest should behave

### StrategyResolver

- Add Contract to check balances for in `get_strategy_destinations` (e.g. deposit pool, gauge, lpTokens)
- Write `confirm_harvest` to verify that the harvest was profitable
- Write `confirm_tend` to verify that tending will properly rebalance the strategy
- Specify custom checks for ordinary deposits, withdrawals and calls to `earn` by setting up `hook_after_confirm_withdraw`, `hook_after_confirm_deposit`, `hook_after_earn`

## Add your custom testing

Check the various tests under `/tests`
The file `/tests/test_custom` is already set up for you to write custom tests there
See example tests in `/tests/examples`
All of the tests need to pass!
If a test doesn't pass, you better have a great reason for it!

## Testing

To run the tests:

```
brownie test
```

## Debugging Failed Transactions

Use the `--interactive` flag to open a console immediatly after each failing test:

```
brownie test --interactive
```

Within the console, transaction data is available in the [`history`](https://eth-brownie.readthedocs.io/en/stable/api-network.html#txhistory) container:

```python
>>> history
[<Transaction '0x50f41e2a3c3f44e5d57ae294a8f872f7b97de0cb79b2a4f43cf9f2b6bac61fb4'>,
 <Transaction '0xb05a87885790b579982983e7079d811c1e269b2c678d99ecb0a3a5104a666138'>]
```

Examine the [`TransactionReceipt`](https://eth-brownie.readthedocs.io/en/stable/api-network.html#transactionreceipt) for the failed test to determine what went wrong. For example, to view a traceback:

```python
>>> tx = history[-1]
>>> tx.traceback()
```

To view a tree map of how the transaction executed:

```python
>>> tx.call_trace()
```

See the [Brownie documentation](https://eth-brownie.readthedocs.io/en/stable/core-transactions.html) for more detailed information on debugging failed transactions.

## Deployment

When you are finished testing and ready to deploy to the mainnet:

1. [Import a keystore](https://eth-brownie.readthedocs.io/en/stable/account-management.html#importing-from-a-private-key) into Brownie for the account you wish to deploy from.
2. Run [`scripts/production_deploy.py`](scripts/production_deploy.py) with the following command:

```bash
$ brownie run scripts/production_deploy.py --network mainnet
```

You will be prompted to enter your desired deployer account and keystore password, and then the contracts will be deployed.

3. This script will deploy a Controller, a SettV4 and your strategy under upgradable proxies. It will also set your deployer account as the governance for the three of them so that you can configure them and control them during testing stage. The script will also set the rest of the permissioned actors based on the latest entries from the Badger Registry.

## Production Parameters Verification

When you are done testing your contracts in production and they are ready for incorporation to the Badger ecosystem, the `production_setup` script can be ran to ensure that all parameters are set in compliance to Badger's production entities and contracts. You can run this script by doing the following:

1. Open the [`scripts/production_setup.py`](scripts/production_setup.py) file and change the addresses for your strategy and vault mainnet addresses on lines 29 and 30.
2. [Import a keystore](https://eth-brownie.readthedocs.io/en/stable/account-management.html#importing-from-a-private-key) into Brownie for the account currently set as `governance` for your contracts.
3. Run [`scripts/production_setup.py`](scripts/production_setup.py) with the following command:

```bash
$ brownie run scripts/production_setup.py --network mainnet
```

You will be prompted to enter your governance account and keystore password, and then the the parameter verification and setup process will be executed.

4. This script will compare all existing parameters against the latest production parameters stored on the Badger Registry. In case of a mismatch, the script will execute a transaction to change the parameter to the proper one. Notice that, as a final step, the script will change the governance address to Badger's Governance Multisig; this will effectively relinquish the contract control from your account to the Badger Governance. Additionally, the script performs a final check of all parameters against the registry parameters.

## Known issues

### No access to archive state errors

If you are using Ganache to fork a network, then you may have issues with the blockchain archive state every 30 minutes. This is due to your node provider (i.e. Infura) only allowing free users access to 30 minutes of archive state. To solve this, upgrade to a paid plan, or simply restart your ganache instance and redploy your contracts.

# Resources

- Example Strategy https://github.com/Badger-Finance/wBTC-AAVE-Rewards-Farm-Badger-V1-Strategy
- Badger Builders Discord https://discord.gg/Tf2PucrXcE
- Badger [Discord channel](https://discord.gg/phbqWTCjXU)
- Yearn [Discord channel](https://discord.com/invite/6PNv2nF/)
- Brownie [Gitter channel](https://gitter.im/eth-brownie/community)
- Alex The Entreprenerd on [Twitter](https://twitter.com/GalloDaSballo)
