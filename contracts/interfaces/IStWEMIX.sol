// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IStWEMIX {
    event PhaseShift(uint256 indexed phase);

    event SetStaking(address staking, uint256 pid);

    event SetFee(uint256 prevFee, uint256 currFee);

    // Records a deposit made by a user
    event Deposited(
        address indexed sender,
        uint256 wemixAmount,
        uint256 stWemixAmount
    );

    // Records a withdraw made by a user
    event Withdrew(
        address indexed sender,
        uint256 wemixAmount,
        uint256 stWemixAmount
    );

    event Fee(
        address indexed feeTo,
        uint256 wemixAmount,
        uint256 stWemixAmount
    );

    function initialize(
        address staking_,
        address treasury_,
        uint256 pid_,
        uint256 feePhaseOne_,
        uint256 feePhaseTwo_
    ) external;

    function phaseShift() external;

    function feeUpdate(uint256 newFeePhaseTwo) external;

    //=============== View Functions ===============//

    function getTotalPooledWEMIXWithFee() external returns (uint256);

    function rewardOf(
        address account_
    ) external view returns (uint256 rewardOf_);

    function fee() external view returns (uint256 fee_);

    function getSharesByPooledWEMIXWithFee(
        uint256 wemixAmount_
    ) external view returns (uint256 shareAmount_);

    function getPooledWEMIXBySharesWithFee(
        uint256 shareAmount_
    ) external view returns (uint256 wemixAmount_);

    //=============== Deposit & Withdraw ===============//

    function deposit() external payable returns (uint256);

    function withdraw(uint256 amount_) external payable returns (uint256);

    function compound() external;
}
