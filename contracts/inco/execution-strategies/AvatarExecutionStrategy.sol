// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { IAvatar } from "../interfaces/IAvatar.sol";
import { SimpleQuorumExecutionStrategy } from "./SimpleQuorumExecutionStrategy.sol";
import { MetaTransaction, Proposal, ProposalStatus } from "../types.sol";
import {IncoContract} from "../incoEndpoint.sol";
import "fhevm/lib/TFHE.sol";

/// @title Avatar Execution Strategy
/// @notice Used to execute proposal transactions from an Avatar contract.
/// @dev An Avatar contract is any contract that implements the IAvatar interface, eg a Gnosis Safe.
contract AvatarExecutionStrategy is SimpleQuorumExecutionStrategy {
    /// @notice Emitted when a new Avatar Execution Strategy is initialized.
    /// @param _owner Address of the owner of the strategy.
    /// @param _target Address of the avatar that this module will pass transactions to.
    /// @param _spaces Array of whitelisted space contracts.
    event AvatarExecutionStrategySetUp(address _owner, address _target, address[] _spaces, uint256 _quorum);

    /// @notice Emitted each time the Target is set.
    /// @param newTarget The new target address.
    event TargetSet(address indexed newTarget);

    /// @notice Address of the avatar that this module will pass transactions to.
    address public target;
    address public executor;
    IncoContract public incoInstance;


    /// @notice Constructor
    /// @param _owner Address of the owner of this contract.
    /// @param _target Address of the avatar that this module will pass transactions to.
    /// @param _spaces Array of whitelisted space contracts.
    /// @param _quorum The quorum required to execute a proposal.
    constructor(address _owner, address _target, address[] memory _spaces, uint256 _quorum, address _executor, address _incoInstance) {
        bytes memory initParams = abi.encode(_owner, _target, _spaces, _quorum);
        setUp(initParams);
        executor = _executor;
        incoInstance = IncoContract(_incoInstance);
    }

    /// @notice Initialization function, should be called immediately after deploying a new proxy to this contract.
    /// @param initParams ABI encoded parameters, in the same order as the constructor.
    function setUp(bytes memory initParams) public initializer {
        (address _owner, address _target, address[] memory _spaces, uint256 _quorum) = abi.decode(
            initParams,
            (address, address, address[], uint256)
        );
        __Ownable_init();
        transferOwnership(_owner);
        __SpaceManager_init(_spaces);
        __SimpleQuorumExecutionStrategy_init(_quorum);
        target = _target;
        emit AvatarExecutionStrategySetUp(_owner, _target, _spaces, _quorum);
    }

    /// @notice Sets the target address.
    /// @param _target The new target address.
    function setTarget(address _target) external onlyOwner {
        target = _target;
        emit TargetSet(_target);
    }

    /// @notice Executes a proposal from the avatar contract if the proposal outcome is accepted.
    ///         Must be called by a whitelisted space contract.
    /// @param proposal The proposal to execute.
    /// @param votesFor The number of votes in favor of the proposal.
    /// @param votesAgainst The number of votes against the proposal.
    /// @param votesAbstain The number of abstaining votes.
    /// @param payload The encoded transactions to execute.
    function execute(   //@votePower
        uint256 /* proposalId */,
        Proposal memory proposal,
        euint32 votesFor,
        euint32 votesAgainst,
        euint32 votesAbstain,
        bytes memory payload,
        uint32 blocknumber
    ) external override {
        ProposalStatus proposalStatus = getProposalStatus(proposal, votesFor, votesAgainst, votesAbstain, blocknumber);
        // if ((proposalStatus != ProposalStatus.Accepted) && (proposalStatus != ProposalStatus.VotingPeriodAccepted)) {
        //     revert InvalidProposalStatus(proposalStatus);
        // }
        _execute(payload);
    }

    /// @notice Decodes and executes a batch of transactions from the avatar contract.
    /// @param payload The encoded transactions to execute.
    function _execute(bytes memory payload) internal {
        incoInstance.executePayload(executor, payload);
    }

    /// @notice Returns the trategy type string.
    function getStrategyType() external pure override returns (string memory) {
        return "SimpleQuorumAvatar";
    }
}
