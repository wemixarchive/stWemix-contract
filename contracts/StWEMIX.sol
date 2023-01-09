// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./interfaces/IStWEMIX.sol";
import "./interfaces/IStaking.sol";

/**
 * @title Wemix Liquid Stacking protocol.
 */
contract StWEMIX is
    IStWEMIX,
    ERC20Upgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    //=============== Params ===============//

    address public treasury; // immutable
    IStaking public staking; // immutable
    uint256 public pid; // immutable

    uint256 public feePhaseOne; // immutable
    uint256 public feePhaseTwo; // dynamic
    uint256 private constant _DENOMINATOR = 10000;

    bool public phaseTwo; // true: phase2, false: phase1

    //=============== Initialize ===============//

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address staking_,
        address treasury_,
        uint256 pid_,
        uint256 feePhaseOne_,
        uint256 feePhaseTwo_
    ) external initializer {
        __ERC20_init("Staked WEMIX", "stWEMIX");
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        require(
            staking_ != address(0),
            "StWEMIX::initialize: INVALID_ADDRESS."
        );
        require(
            treasury_ != address(0),
            "StWEMIX::initialize: INVALID_ADDRESS."
        );

        treasury = treasury_;
        staking = IStaking(staking_);
        pid = pid_;
        emit SetStaking(staking_, pid_);

        feePhaseOne = feePhaseOne_;
        feePhaseTwo = feePhaseTwo_;

        _pause(); // lock withdraw
    }

    function phaseShift() external onlyOwner whenPaused {
        require(!phaseTwo, "StWEMIX::phase: Must be in phase 1.");

        uint256 _fee = fee();
        uint256 _restake = _getRewardWEMIXWithFee();

        // claim
        staking.claim(pid, payable(address(this)));

        // fee
        (bool success, ) = treasury.call{value: _fee}("");
        require(success, "StWEMIX::_deposit: Fail to send fee.");

        // compound
        staking.deposit{value: _restake}(
            pid,
            _restake,
            payable(address(this)),
            false
        );

        // unlock withdraw
        _unpause();

        // set Phase 2
        phaseTwo = true;

        emit PhaseShift(2);
    }

    function feeUpdate(uint256 newFeePhaseTwo) external onlyOwner {
        require(
            newFeePhaseTwo <= _DENOMINATOR,
            "StWEMIX::feeUpdate: INVALID_FEE."
        );
        uint256 prevFee = feePhaseTwo;
        feePhaseTwo = newFeePhaseTwo;
        emit SetFee(prevFee, feePhaseTwo);
    }

    //=============== View Functions ===============//

    function getTotalPooledWEMIXWithFee() external view returns (uint256) {
        return _getTotalPooledWEMIXWithFee();
    }

    function rewardOf(
        address account_
    ) external view returns (uint256 rewardOf_) {
        uint256 reward = _getRewardWEMIXWithFee();
        if (totalSupply() == 0) {
            return 0;
        } else {
            rewardOf_ = (balanceOf(account_) * reward) / totalSupply();
        }
    }

    function fee() public view returns (uint256 fee_) {
        uint256 reward_ = _getRewardWEMIX();
        if (phaseTwo) {
            fee_ = (reward_ * feePhaseTwo) / _DENOMINATOR;
        } else {
            fee_ = (reward_ * feePhaseOne) / _DENOMINATOR;
        }
    }

    function getSharesByPooledWEMIXWithFee(
        uint256 wemixAmount_
    ) public view returns (uint256 shareAmount_) {
        uint256 totalPooledEther = _getTotalPooledWEMIXWithFee();
        if (totalPooledEther == 0) {
            shareAmount_ = wemixAmount_;
        } else {
            shareAmount_ = (wemixAmount_ * totalSupply()) / totalPooledEther;
        }
    }

    function getPooledWEMIXBySharesWithFee(
        uint256 shareAmount_
    ) public view returns (uint256 wemixAmount_) {
        if (totalSupply() == 0) {
            revert("StWEMIX::getPooledWEMIXBySharesWithFee: Never happened.");
        } else {
            uint256 totalPooledEther = _getTotalPooledWEMIXWithFee();
            wemixAmount_ = (shareAmount_ * totalPooledEther) / totalSupply();
        }
    }

    //=============== Internal View Functions ===============//

    // function _getTotalPooledWEMIX() internal view returns (uint256) {
    //     return _getStakedWEMIX() + _getRewardWEMIX();
    // }

    function _getTotalPooledWEMIXWithFee() internal view returns (uint256) {
        return _getStakedWEMIX() + _getRewardWEMIXWithFee();
    }

    function _getStakedWEMIX() internal view returns (uint256 staked_) {
        staked_ = staking.getUserInfo(pid, address(this)).amount;
    }

    function _getRewardWEMIX() internal view returns (uint256 reward_) {
        reward_ = staking.pendingReward(pid, address(this));
    }

    function _getRewardWEMIXWithFee() internal view returns (uint256 reward_) {
        reward_ = _getRewardWEMIX();
        if (phaseTwo) {
            reward_ = (reward_ * (_DENOMINATOR - feePhaseTwo)) / _DENOMINATOR;
        } else {
            reward_ = (reward_ * (_DENOMINATOR - feePhaseOne)) / _DENOMINATOR;
        }
    }

    //=============== Functions ===============//

    /**
     * @notice DEPRECATED
     * @dev Users are NOT able to submit their funds by transacting to the fallback function.
     */
    receive() external payable {}

    /**
     * @notice Send funds to the pool
     * @dev This function is alternative way to submit funds.
     * @return Amount of StWEMIX shares generated
     */
    function deposit() external payable nonReentrant returns (uint256) {
        return _deposit();
    }

    /**
     * @notice Withdraw funds from the pool
     * @param amount_ of StWEMIX to withdraw
     * @return Amount of StWEMIX shares burned
     */
    function withdraw(
        uint256 amount_
    ) external payable whenNotPaused nonReentrant returns (uint256) {
        return _withdraw(amount_);
    }

    function compound() external {
        _compound();
    }

    //=============== Internal Functions ===============//

    /**
     * @dev Process user deposit, mints liquid tokens
     * @return sharesAmount_ amount of StWEMIX shares generated
     */
    function _deposit() internal returns (uint256 sharesAmount_) {
        address msgSender = _msgSender();

        require(msg.value != 0, "StWEMIX::_deposit:ZERO_DEPOSIT");

        // fee
        uint256 _feeWemix = fee();
        uint256 _feeStWemix = getSharesByPooledWEMIXWithFee(_feeWemix);

        // mint
        sharesAmount_ = getSharesByPooledWEMIXWithFee(msg.value);
        _mint(msgSender, sharesAmount_);

        // staking
        staking.deposit{value: msg.value}(
            pid,
            msg.value,
            payable(address(this)),
            false
        );

        // compound
        _compound();

        // fee
        _mint(treasury, _feeStWemix);

        emit Deposited(msgSender, msg.value, sharesAmount_);
        emit Fee(treasury, _feeWemix, _feeStWemix);
    }

    /**
     * @dev Process user withdraw, burns liquid tokens
     * @param amount_ of StWEMIX to withdraw
     * @return wemixAmount_ amount of StWEMIX shares burned
     */
    function _withdraw(
        uint256 amount_
    ) internal returns (uint256 wemixAmount_) {
        address msgSender = _msgSender();

        require(amount_ != 0, "StWEMIX::_withdraw:CANNOT_WITHDRAW");
        require(
            amount_ <= balanceOf(msgSender),
            "StWEMIX::_withdraw:NOT_ENOUGH_BALANCE"
        );

        // fee
        uint256 _feeWemix = fee();
        uint256 _feeStWemix = getSharesByPooledWEMIXWithFee(_feeWemix);

        // burn
        wemixAmount_ = getPooledWEMIXBySharesWithFee(amount_);
        _burn(msgSender, amount_);

        // compound
        _compound();

        // unstaking
        staking.withdraw(pid, wemixAmount_, payable(msgSender), false);

        // fee
        _mint(treasury, _feeStWemix);

        emit Withdrew(msgSender, wemixAmount_, amount_);
        emit Fee(treasury, _feeWemix, _feeStWemix);
    }

    function _compound() internal {
        staking.compound(pid, address(this));
    }
}
