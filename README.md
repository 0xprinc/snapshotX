## Cross Chain Voting using ECRecover 

What does ECRecover do? 

If there is a message, you can sign them using a private key. This will generate a signature and now you can send this signature. ECRecover(signature) = fetches you the public key of the private key. So you can verify that the sender has actually signed the message. We send a signature to the server and server will generate a public key.  


## Setup: 

```sh
pnpm install 
```

```sh 
cp .env.example .env 
open .env (Add your private key to the .env file. )
npx hardhat compile 
```

**Setup the server** 

Clone the server github repo and switch to ECrecover branch: 
https://github.com/0xprinc/bridge-server 

```sh
npm install  
```

**Deploy contracts**: 

```sh
npx hardhat crossdeploy --network baseSepolia
```
**Deploy the Server** 

```sh
node index.js <contract address inco> <contract address targetchain>
``` 


<img width="1256" alt="Screenshot 2024-05-28 at 6 26 11 PM" src="https://github.com/0xprinc/snapshotX/assets/32016969/9a6bf33d-190d-4fd7-a3c2-f926c12decfa">

 
 
