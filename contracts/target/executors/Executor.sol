// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { MetaTransaction, Proposal, ProposalStatus } from "../types.sol";
import { IAvatar } from "./IAvatar.sol";

contract Executor {
    function AvatarExecutor(address target, bytes memory payload) public {
        MetaTransaction[] memory transactions = abi.decode(payload, (MetaTransaction[]));
        for (uint256 i = 0; i < transactions.length; i++) {
            bool success = IAvatar(target).execTransactionFromModule(
                transactions[i].to,
                transactions[i].value,
                transactions[i].data,
                transactions[i].operation
            );
            // If any transaction fails, the entire execution will revert.
            if (!success) revert();
        }
    }
}