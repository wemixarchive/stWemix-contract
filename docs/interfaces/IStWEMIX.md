## `IStWEMIX`






### `initialize(address staking_, address treasury_, uint256 pid_, uint256 feePhaseOne_, uint256 feePhaseTwo_)` (external)





### `phaseShift()` (external)





### `feeUpdate(uint256 newFeePhaseTwo)` (external)





### `getTotalPooledWEMIXWithFee() → uint256` (external)





### `rewardOf(address account_) → uint256 rewardOf_` (external)





### `fee() → uint256 fee_` (external)





### `getSharesByPooledWEMIXWithFee(uint256 wemixAmount_) → uint256 shareAmount_` (external)





### `getPooledWEMIXBySharesWithFee(uint256 shareAmount_) → uint256 wemixAmount_` (external)





### `deposit() → uint256` (external)





### `withdraw(uint256 amount_) → uint256` (external)





### `compound()` (external)






### `PhaseShift(uint256 phase)`





### `SetStaking(address staking, uint256 pid)`





### `SetFee(uint256 prevFee, uint256 currFee)`





### `Deposited(address sender, uint256 wemixAmount, uint256 stWemixAmount)`





### `Withdrew(address sender, uint256 wemixAmount, uint256 stWemixAmount)`





### `Fee(address feeTo, uint256 wemixAmount, uint256 stWemixAmount)`





