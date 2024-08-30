import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
require("dotenv").config();

const StakingContract = buildModule("StakingContract", (m) => {

    const stakingToken: string = process.env.STAKING_TOKEN!;
    const rewardToken: string = process.env.REWARD_TOKEN!;
    const rewardInterval: string = '60'; // 1 min in seconds

    const contract = m.contract("StakingContract", [stakingToken, rewardToken, rewardInterval], {});

    return { contract };
});

export default StakingContract;