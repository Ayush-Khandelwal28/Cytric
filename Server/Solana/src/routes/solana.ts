import { Router, Request, Response } from 'express';
import { Connection, PublicKey } from '@solana/web3.js';

const router = Router();
const connection = new Connection(process.env.SOLANA_RPC_URL || 'https://api.mainnet-beta.solana.com');

const SPL_TOKEN_MINT_ADDRESS = new PublicKey(process.env.SPL_TOKEN_MINT_ADDRESS || 'EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm');

router.get('/token-supply', async (req: Request, res: Response) => {
  try {
    const supply = await connection.getTokenSupply(SPL_TOKEN_MINT_ADDRESS);
    res.json({ totalSupply: supply.value.amount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch token supply' });
  }
});

router.get('/token-balance/:address', async (req: Request, res: Response) => {
  try {
    const { address } = req.params;
    const publicKey = new PublicKey(address);

    const tokenAccounts = await connection.getTokenAccountsByOwner(publicKey, {
      mint: SPL_TOKEN_MINT_ADDRESS,
    });

    if (tokenAccounts.value.length === 0) {
      return res.status(404).json({ error: 'No token account found for this address' });
    }

    const balance = await connection.getTokenAccountBalance(tokenAccounts.value[0].pubkey);
    res.json({ balance: balance.value.amount });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch token balance' });
  }
});

export default router;
