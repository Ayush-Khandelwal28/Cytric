// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public totalStaked;
    uint256 public rewardInterval;
    uint256 public rewardRate;

    int256 public rewardPool;
    bool public isSameToken;

    struct StakerInfo {
        uint256 stakedAmount;
        uint256 rewardDue;
        uint256 lastStakedTime;
    }

    mapping(address => StakerInfo) public stakers;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 rewards);
    event RewardClaimed(address indexed user, uint256 amount);
    event RewardRateAdjusted(uint256 newRate);
    event RewardIntervalChanged(uint256 newInterval);

    constructor(
        IERC20 _stakingToken,
        IERC20 _rewardToken,
        uint256 _rewardInterval
    ) Ownable(msg.sender) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        rewardInterval = _rewardInterval;
        rewardRate = 1e18;
        isSameToken = (address(stakingToken) == address(rewardToken));
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Stake Amount Must be greater than 0");
        require(
            stakingToken.balanceOf(msg.sender) >= amount,
            "Account balance must be greater or equal than the Amount of Tokens to be Staked"
        );

        updateRewards(msg.sender);

        stakingToken.transferFrom(msg.sender, address(this), amount);

        StakerInfo storage staker = stakers[msg.sender];
        staker.stakedAmount += amount;
        staker.lastStakedTime = block.timestamp;

        totalStaked += amount;

        adjustRewardRate();

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        StakerInfo storage staker = stakers[msg.sender];

        updateRewards(msg.sender);

        uint256 rewards = staker.rewardDue;

        if (isSameToken) {
            uint256 totalWithdrawal = amount + rewards;
            require(
                stakingToken.balanceOf(address(this)) >= totalWithdrawal,
                "Insufficient contract balance for withdrawal"
            );
            stakingToken.transfer(msg.sender, totalWithdrawal);
        } else {
            require(
                stakingToken.balanceOf(address(this)) >= amount,
                "Insufficient contract balance for staked tokens withdrawal"
            );
            require(
                rewardToken.balanceOf(address(this)) >= rewards,
                "Insufficient reward balance for rewards withdrawal"
            );
            stakingToken.transfer(msg.sender, amount);
            rewardToken.transfer(msg.sender, rewards);
        }

        staker.stakedAmount -= amount;
        staker.rewardDue = 0;
        totalStaked -= amount;

        rewardPool -= int256(rewards);

        adjustRewardRate();

        emit Withdrawn(msg.sender, amount, rewards);
    }

    function claimRewards() external {
        updateRewards(msg.sender);

        StakerInfo storage staker = stakers[msg.sender];
        uint256 pendingReward = staker.rewardDue;
        require(pendingReward > 0, "No rewards to claim");

        require(
            rewardToken.balanceOf(address(this)) >= pendingReward,
            "Insufficient reward balance for rewards withdrawal"
        );

        rewardToken.transfer(msg.sender, pendingReward);

        staker.rewardDue = 0;

        emit RewardClaimed(msg.sender, pendingReward);
    }

    function depositRewards(uint256 amount) external onlyOwner {
        require(amount > 0, "Cannot deposit zero tokens");

        rewardToken.transferFrom(msg.sender, address(this), amount);
        rewardPool += int256(amount);
        adjustRewardRate();
    }

    function setRewardInterval(uint256 _newInterval) external onlyOwner {
        rewardInterval = _newInterval;
        emit RewardIntervalChanged(_newInterval);
    }

    function adjustRewardRate() internal {
        if (totalStaked == 0 || rewardPool <= 0) {
            rewardRate = 0;
        } else {
            uint256 calculatedRate = 1e18 / totalStaked;
            uint256 maxRate = 1e18; 
            rewardRate = calculatedRate > maxRate ? maxRate : calculatedRate;
        }

        emit RewardRateAdjusted(rewardRate);
    }

    function updateRewards(address _user) internal {
        StakerInfo storage staker = stakers[_user];

        if (staker.stakedAmount > 0) {
            uint256 stakingDuration = block.timestamp - staker.lastStakedTime;
            uint256 reward = (stakingDuration * rewardRate * staker.stakedAmount) / (rewardInterval * 1e18);

            staker.rewardDue += reward;
            staker.lastStakedTime = block.timestamp;
        }
    }

    function getStakerInfo(
        address _staker
    )
        external
        returns (
            uint256 stakedAmount,
            uint256 rewardDue,
            uint256 lastStakedTime
        )
    {
        updateRewards(_staker);
        StakerInfo storage staker = stakers[_staker];
        return (staker.stakedAmount, staker.rewardDue, staker.lastStakedTime);
    }
}
