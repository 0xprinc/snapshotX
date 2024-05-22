## Cross Chain Voting using ECRecover 

What does ECRecover do? 

If there is a message, you can sign them using a private key. This will generate a signature and now you can send this signature. ECRecover(signature) = fetches you the public key of the private key. So you can verify that the sender has actually signed the message. We send a signature to the server and server will generate a public key.  


## Setup: 

```sh
pnpm install 
```

```sh 
cp .env.example .env 
``` 

Add your private key to the .env file. 

open .env


```sh 
npx hardhat compile 
```

**Setup the server** 

Clone the server github repo: 
https://github.com/0xprinc/bridge-server 

```sh 
npm install  
node index.js 
``` 

Deploy: 

```sh
npx hardhat crossdeploy --network baseSepolia
```






 
 
