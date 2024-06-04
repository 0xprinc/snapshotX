## Description :
This version of cross-chain voting uses hyperlane for bridging all the data cross-chain.
This version solves the limitation of high gas comsumption while bridging the ciphertext while voting.

### Contracts architecture and bridging
This divides the snapshot contracts into two parts : 
1. inco : incoEndpoint.sol, execution module
2. target chain : targetEndpoint.sol, all other contracts


**Compile**

```sh
pnpm install 
cp .env.example .env 
open .env (Add your private key to the .env file.)
npx hardhat compile 
```

**Testing**: 

```sh
npx hardhat crossdeploy --network baseSepolia
```
