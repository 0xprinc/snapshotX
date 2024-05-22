pragma solidity 0.8.20;

// import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
// import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";

import "fhevm/lib/TFHE.sol";

import {Proposal} from "./types.sol";
import { IExecutionStrategy } from "./interfaces/IExecutionStrategy.sol";


contract IncoContract {

    mapping(uint256 proposalId => mapping(uint8 choice => euint32 votePower)) public votePower;     // should be made private
    mapping(uint256 proposalId => bool) public isExecuted;

    function getIsExecuted(uint256 proposalId) public view returns(bool){
        return isExecuted[proposalId];
    }

    function getVotePower(uint256 proposalId, uint8 choice, bytes32 publicKey) public view returns (bytes memory) {             // @inco
        return TFHE.reencrypt(votePower[proposalId][choice], publicKey, 0);
    }

    function verify_sign(address voter, bytes memory signature, bytes memory data) public pure returns (address) {
        require(signature.length == 65, "Invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Extract r, s and v from the signature
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Compute the prefixed message hash
        bytes32 messageHash = prefixed(keccak256(data));

        // Use ecrecover to recover the address of the signer
        address signer = ecrecover(messageHash, v, r, s);
        return signer;
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }


    function vote(address voter, uint256 proposalId, uint32 votingPower, bytes memory choice, bytes memory signature) public {
        // require(verify_sign(voter, signature, choice),"not signed by voter");
        votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))] = TFHE.add(votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))], votingPower);
    }

    function execute(uint256 proposalId, bytes memory proposal, bytes memory executionPayload, uint32 blocknumber) public {
        Proposal memory _proposal = abi.decode(proposal, (Proposal));

        IExecutionStrategy(_proposal.executionStrategy).execute(
            proposalId,
            _proposal,
            votePower[proposalId][1],
            votePower[proposalId][0],
            votePower[proposalId][2],
            executionPayload,
            blocknumber
        );
        isExecuted[proposalId] = true;
    }
}
