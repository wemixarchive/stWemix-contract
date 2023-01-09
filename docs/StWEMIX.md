## `StWEMIX`






### `constructor()` (public)

@custom:oz-upgrades-unsafe-allow constructor



### `initialize(address staking_, address treasury_, uint256 pid_, uint256 feePhaseOne_, uint256 feePhaseTwo_)` (external)





### `phaseShift()` (external)





### `feeUpdate(uint256 newFeePhaseTwo)` (external)





### `getTotalPooledWEMIXWithFee() → uint256` (external)





### `rewardOf(address account_) → uint256 rewardOf_` (external)





### `fee() → uint256 fee_` (public)





### `getSharesByPooledWEMIXWithFee(uint256 wemixAmount_) → uint256 shareAmount_` (public)





### `getPooledWEMIXBySharesWithFee(uint256 shareAmount_) → uint256 wemixAmount_` (public)





### `_getTotalPooledWEMIXWithFee() → uint256` (internal)





### `_getStakedWEMIX() → uint256 staked_` (internal)





### `_getRewardWEMIX() → uint256 reward_` (internal)





### `_getRewardWEMIXWithFee() → uint256 reward_` (internal)





### `receive()` (external)

DEPRECATED


Users are NOT able to submit their funds by transacting to the fallback function.

### `deposit() → uint256` (external)

Send funds to the pool


This function is alternative way to submit funds.


### `withdraw(uint256 amount_) → uint256` (external)

Withdraw funds from the pool




### `compound()` (external)





### `_deposit() → uint256 sharesAmount_` (internal)



Process user deposit, mints liquid tokens


### `_withdraw(uint256 amount_) → uint256 wemixAmount_` (internal)



Process user withdraw, burns liquid tokens


### `_compound()` (internal)






