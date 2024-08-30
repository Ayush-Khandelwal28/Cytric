import { Router } from 'express';
import { createPublicClient, http } from 'viem';
import { sepolia } from 'viem/chains';
import { stakingContractAddress, StakingContractabi } from '../constants';
require('dotenv').config();

function initializeClient() {
  let publicClient: ReturnType<typeof createPublicClient> | null = null;

  const rpcUrl = process.env.SEPOLIA_RPC_URL;

  if (!rpcUrl) {
    throw new Error('Missing environment variable: SEPOLIA_RPC_URL');
  }

  try {
    publicClient = createPublicClient({
      chain: sepolia,
      transport: http(rpcUrl),
    });

    if (!publicClient) {
      throw new Error('Failed to initialize clients');
    }

  } catch (error) {
    console.error('Error initializing clients:', error);
    throw new Error('Failed to initialize clients');
  }

  return { publicClient };
}


const router = Router();

type StakerInfo = [bigint, bigint, bigint];

const { publicClient } = initializeClient();

const contract = {
  address: stakingContractAddress as `0x${string}`,
  abi: StakingContractabi,
};


router.get('/:address', async (req, res) => {
  const userAddress = req.params.address;

  try {

    const result = await publicClient.readContract({
      address: contract.address,
      abi: contract.abi,
      functionName: 'getStakerInfo',
      args: [userAddress],
    }) as StakerInfo;

    const [stakedAmount, rewardDue, lastStakedTime] = result;

    res.json({
      stakedAmount: stakedAmount.toString(),
      rewardDue: rewardDue.toString(),
      lastStakedTime: lastStakedTime.toString(),
    });

  } catch (error) {
    console.error('Error fetching staking info:', error);
    res.status(500).json({ error: 'An error occurred while fetching staking info' });
  }
});

export default router;
