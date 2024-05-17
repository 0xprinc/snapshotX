// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { SimpleQuorumExecutionStrategy } from "./SimpleQuorumExecutionStrategy.sol";
import { Proposal, ProposalStatus } from "../types.sol";

import "fhevm/lib/TFHE.sol";

/// @title Vanilla Execution Strategy
contract VanillaExecutionStrategy is SimpleQuorumExecutionStrategy {
    uint256 public numExecuted;

    function getNumExecuted() public view returns (uint256) {
        return numExecuted;
    }

    constructor(address _owner, uint256 _quorum) {
        setUp(abi.encode(_owner, _quorum));
    }

    function setUp(bytes memory initParams) public initializer {
        (address _owner, uint256 _quorum) = abi.decode(initParams, (address, uint256));
        __Ownable_init();
        transferOwnership(_owner);
        __SimpleQuorumExecutionStrategy_init(_quorum);
    }

    function execute(   //@votePower
        uint256 proposalId,
        Proposal memory proposal,
        euint32 votesFor,
        euint32 votesAgainst,
        euint32 votesAbstain,
        bytes memory payload
    ) external override {
        ProposalStatus proposalStatus = getProposalStatus(proposal, votesFor, votesAgainst, votesAbstain);
        if ((proposalStatus != ProposalStatus.Accepted) && (proposalStatus != ProposalStatus.VotingPeriodAccepted)) {
            revert InvalidProposalStatus(proposalStatus);
        }
        numExecuted++;
    }

    function getStrategyType() external pure override returns (string memory) {
        return "SimpleQuorumVanilla";
    }
}