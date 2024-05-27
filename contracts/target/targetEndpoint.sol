pragma solidity 0.8.20;

// import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
// import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {Proposal} from "./types.sol";
import {avatarExecutor} from "./execution/avatarExecutor.sol";

interface IExecutor {
    function execute(address target, bytes memory payload) external; 
}

contract TargetContract {
    event vote_init(address, uint256, uint32, bytes, bytes);
    event execute_init(uint256, bytes, bytes);

    function vote(address voter, uint256 proposalId, uint32 votingPower, bytes memory choice, bytes memory signature) public {
        emit vote_init(voter, proposalId, votingPower, choice, signature);
    }

    // hash of the executionPayload is also to be taken care of since it can also be of very large size in bytes length
    function execute(uint256 proposalId, Proposal memory proposal, bytes memory executionPayload) public {
        bytes memory bProposal = abi.encode(proposal);
        emit execute_init(proposalId, bProposal, executionPayload);
    }

    function executePayload(address executor, bytes memory payload) public {
        avatarExecutor(executor).execute(payload);
    }
}