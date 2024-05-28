## Description
This repo demonstrates cross-chain private voting between Inco and Base. The logic of tallying and execution of the proposal remains on Inco. The rest of the logic (authenticating users, proposal validation strategies, voting strategies remains on the primary chain). We use Hyperlane and an offchain server to pass messages. We pass the hash of the ciphertext through hyperlane and we pass the actual ciphertext through the off-chain server which is verfied on Inco. We have defined Incoendpoint.sol and Targetendpoint.sol to pass messages. 

The modifications we made earlier remain the same but we spilt the codebase in the following manner:

Logic on Inco:
- votePower mapping : encrypted values of aggregated votes of (For, against, abstain)
- inco endpoint contract : used for receiving crosschain calls from target chain(Base)
- Execution Strategy Module : which accesses the votePower mapping and executes

Logic on Base: 
- target Endpoint contract : used for sending data to inco endpoint contract
- all other modules and Space.sol(main contract)

  
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

**Deploy the server**
```sh
node index.js [contract address_inco][contract address_targetchain]
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

<img width="1221" alt="Screenshot 2024-05-22 at 4 46 33 PM" src="https://github.com/0xprinc/snapshotX/assets/32016969/63ce344d-f033-4616-ac74-b6249a640482">


 
