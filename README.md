## Description :
This version of cross-chain voting uses hyperlane for bridging all the data cross-chain.
This version solves the limitation of high gas comsumption while bridging the ciphertext while voting.

### Contracts architecture and bridging
This divides the snapshot contracts into two parts : 
1. inco : incoEndpoint.sol, execution module
2. target chain : targetEndpoint.sol, all other contracts
<img width="1251" alt="Screenshot 2024-06-04 at 17 57 48" src="https://github.com/0xprinc/snapshotX/assets/82727098/6ad15e62-7711-4118-af9a-e3cd619f6ac9">

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
