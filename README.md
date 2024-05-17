## Cross Chain Voting Server 

command:

```sh
pnpm install 
```

```sh 
cp .env.example .env 
``` 

Add your private key to the .env file. 

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
npx hardhat crosschain deploy base sepolia
```

##User Flow: 
1) You cast the encrypted vote on Base.
2) The vote function on Space.sol calls the vote function on target endpoint. 
3) Vote function on target endpoint does two things: 
  a) Emit an event (counter_choice_vote) containing the cipherhext (choice). 
  b) Calls the send message function and sends the hash of choice ciphertext through hyperlane to Inco
4) Inco endpoint when recieves the hash of the ciphertext through hyperlane, stores the hash of choice ciphertext, vote power, proposal ID.
5) The server watches for emitted events which contain the ciphertext and then intitates a vote transaction on Inco endpoint. The vote function on Inco endpoint verifies that the stored hash and the incoming ciphertext and then casts the vote on Inco.
6) Similarly, in the flow of execute function, instead of sending the choice ciphertext, we send the proposal in bytes form. 

Vote counter: We define vote counter such that we can tally the # of votes casted on the target endpoint have been processed on Inco endpoint. 

Why do we need to send hash of ciphertext? 
- So that we verify that the ciphertext sent by the server is matching the hash of ciphertext sent through hyperlane





##Alternate Approach: 

Send a signed message through the server using ECReover 

What does ECRecover do? 

If there is a message, you can sign them using a private key. This will generate a signature, 
now you can send this signature. ECRecover(signature) = fetches you the public key of the private key. 
So you can verify that the sender has actually signed the message. 
We send a signature to the server and server will generate a public key. We have a set of trusted/whitelisted addresses.  
 
 
