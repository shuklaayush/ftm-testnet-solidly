## Ideally, they have one file with the settings for the strat and deployment
## This file would allow them to configure so they can test, deploy and interact with the strategy

BADGER_DEV_MULTISIG = "0xb65cef03b9b89f99517643226d76e286ee999e77"

## NOTE: Because this is a bodged testnet mix, conftest.py is the "real" code and these are just values to feed to the strat
WANT = "0xa3502f18766b17a07B487C6F395A23d3ef67D4DE"  ## pair from conftest.py
LP_COMPONENT = "0xdeb44B8d020952942734b370768F44b4F3226afd"  ## gauge from conftest.py
REWARD_TOKEN = "0x0673e1CF8EE91095232CFC98Ee1EbCeF42A1977E"  ## baseToken from conftest.py

PROTECTED_TOKENS = [WANT, LP_COMPONENT, REWARD_TOKEN]
## Fees in Basis Points
DEFAULT_GOV_PERFORMANCE_FEE = 1000
DEFAULT_PERFORMANCE_FEE = 1000
DEFAULT_WITHDRAWAL_FEE = 10

FEES = [DEFAULT_GOV_PERFORMANCE_FEE, DEFAULT_PERFORMANCE_FEE, DEFAULT_WITHDRAWAL_FEE]

REGISTRY = "0xFda7eB6f8b7a9e9fCFd348042ae675d1d652454f"  # Multichain BadgerRegistry
