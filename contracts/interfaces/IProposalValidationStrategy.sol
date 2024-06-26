// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IProposalValidationStrategy {
    function validate(address author, bytes calldata params, bytes calldata userParams) external returns (bool);
}
