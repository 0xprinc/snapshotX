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

    function getMessageHash(
        bytes memory data
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address _signer,
        bytes memory data,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(data);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }


    function vote(address voter, uint256 proposalId, uint32 votingPower, bytes memory choice, bytes memory signature) public {
        require(verify(voter, choice, signature),"not signed by voter");
        ebool isAgainst = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(0));
        ebool isFor = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(1));
        ebool isAbstain = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(2));

        votePower[proposalId][0] = TFHE.add(votePower[proposalId][0], TFHE.cmux(isAgainst, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));
        votePower[proposalId][1] = TFHE.add(votePower[proposalId][1], TFHE.cmux(isFor, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));
        votePower[proposalId][2] = TFHE.add(votePower[proposalId][2], TFHE.cmux(isAbstain, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));

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

    function executePayload(address executor, bytes memory payload) public {
        (bytes memory result, bool success) = executor.call(payload);
        require(success, "Call to executor failed");
    }
}
