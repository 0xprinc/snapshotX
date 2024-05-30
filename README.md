## Setup: 

**Compile**

```sh
pnpm install 
cp .env.example .env 
open .env (Add your private key to the .env file.)
npx hardhat compile 
```

**Setup the server** 

Clone the server github repo: 
https://github.com/0xprinc/bridge-server 

```sh 
npm install
```

**Deploy the contracts**: 

```sh
npx hardhat crossdeploy --network baseSepolia
```
