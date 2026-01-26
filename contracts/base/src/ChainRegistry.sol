// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RewardPool
 * @notice Staking rewards with time-locked claims
 */
contract RewardPool {
    error InsufficientStake();
    error ClaimTooEarly();
    error NoRewards();
    error NotOwner();

    event Staked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 reward);
    event Unstaked(address indexed user, uint256 amount);
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 lastClaim;
    }

    mapping(address => Stake) public stakes;
    uint256 public rewardRate = 100; // 1% per day
    uint256 public lockPeriod = 1 days;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function stake() external payable {
        stakes[msg.sender].amount += msg.value;
        stakes[msg.sender].timestamp = block.timestamp;
        if (stakes[msg.sender].lastClaim == 0) {
            stakes[msg.sender].lastClaim = block.timestamp;
        }
        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 amount) external {
        Stake storage s = stakes[msg.sender];
        if (s.amount < amount) revert InsufficientStake();
        if (block.timestamp < s.timestamp + lockPeriod) revert ClaimTooEarly();
        
        s.amount -= amount;
        payable(msg.sender).transfer(amount);
        
        emit Unstaked(msg.sender, amount);
    }

    function claim() external {
        Stake storage s = stakes[msg.sender];
        if (s.amount == 0) revert InsufficientStake();
        if (block.timestamp < s.lastClaim + lockPeriod) revert ClaimTooEarly();
        
        uint256 reward = calculateReward(msg.sender);
        if (reward == 0) revert NoRewards();
        
        s.lastClaim = block.timestamp;
        payable(msg.sender).transfer(reward);
        emit Claimed(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake memory s = stakes[user];
        uint256 duration = block.timestamp - s.lastClaim;
        return (s.amount * rewardRate * duration) / (10000 * 1 days);
    }

    function setRewardRate(uint256 newRate) external onlyOwner {
        uint256 oldRate = rewardRate;
        rewardRate = newRate;
        emit RewardRateUpdated(oldRate, newRate);
    }

    function getStake(address user) external view returns (uint256, uint256, uint256) {
        Stake memory s = stakes[user];
        return (s.amount, s.timestamp, s.lastClaim);
    }

    receive() external payable {}
}
