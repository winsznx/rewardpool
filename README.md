# RewardPool

Staking rewards distribution with time-locked claims on Base and Stacks blockchains.

## Features

- Stake tokens to earn rewards
- Time-locked reward claims
- Automatic reward calculation based on duration
- Configurable reward rate
- Multi-chain staking

## Smart Contract Functions

### Base (Solidity)
- `stake()` - Stake ETH/tokens
- `claim()` - Claim accumulated rewards
- `calculateReward(address user)` - View pending rewards
- `getStake(address user)` - Get stake details

### Stacks (Clarity)
- `(stake (amount uint))` - Stake STX
- `(claim)` - Claim rewards
- `(get-stake (user principal))` - Get stake info

## Tech Stack

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Base**: Solidity 0.8.20, Foundry, Reown wallet
- **Stacks**: Clarity v4, Clarinet, @stacks/connect

## Getting Started

```bash
pnpm install
pnpm dev
```

## License

MIT License
