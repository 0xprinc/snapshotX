// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity >=0.8.13 <0.9.0;

import "./Common.sol";

contract HiddenCard is BridgeContract {
    mapping (address => uint8) public encryptedCards;
    uint8 counter;

    constructor() {}
    
    function returnCard(address user) external onlyCallerContract returns(uint8) {
        counter++;
        return counter;
    }

    function viewCard(address user) external view returns (uint8) {
        return counter;
    }
}