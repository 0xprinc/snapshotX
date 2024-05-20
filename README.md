## Cross Chain Voting Server 

Setup: 

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
npx hardhat crossdeploy --network baseSepolia
```


## User Flow:

1) You cast the encrypted vote on Base.
2) The vote function on Space.sol calls the vote function on the target endpoint.
3) The vote function on the target endpoint does two things:
  a) Emits an event (counter_choice_vote) containing the ciphertext (choice).
  b) Calls the send message function and sends the hash of the choice ciphertext through hyperlane to Inco.
4) When the Inco endpoint receives the hash of the ciphertext through hyperlane, it stores the hash of the choice ciphertext, vote power, and proposal ID.
5) The server watches for emitted events which contain the ciphertext and then initiates a vote transaction on the Inco endpoint. The vote function on the Inco endpoint verifies that the stored hash matches the incoming ciphertext and then casts the vote on Inco.
6) Similarly, to execute the proposal, instead of sending the choice ciphertext, we send the proposal in bytes format.

Vote counter: We define the vote counter such that we can tally the number of votes casted on the target endpoint that have been processed on the Inco endpoint.


<img width="1080" alt="Screenshot 2024-05-17 at 9 47 15 PM" src="https://github.com/0xprinc/snapshotX/assets/32016969/eb49d70d-3421-45ef-8180-d09faf6d7726">

<img width="1325" alt="Screenshot 2024-05-17 at 11 54 49 PM" src="https://github.com/0xprinc/snapshotX/assets/32016969/b3e4565e-6b2c-45fc-890f-9f92edc6a209">


## Alternate Approach: 

Send a signed message through the server using ECReover 

What does ECRecover do? 

If there is a message, you can sign them using a private key. This will generate a signature, 
now you can send this signature. ECRecover(signature) = fetches you the public key of the private key. 
So you can verify that the sender has actually signed the message. 
We send a signature to the server and server will generate a public key. We have a set of trusted/whitelisted addresses.  
 
 
