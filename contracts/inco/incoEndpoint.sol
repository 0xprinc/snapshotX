// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.20;
import "fhevm/lib/TFHE.sol";
interface IInterchainExecuteRouter {
    function callRemote(
        uint32 _destination,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes memory _callback
    ) external returns (bytes32);

    function getRemoteInterchainAccount(uint32 _destination, address _owner) external view returns (address);
}

abstract contract BridgeContract {
    uint32 DestinationDomain;
    // HiddenCard contract in Inco Network
    address hiddencard;
    // InterchainExcuteRouter contract address in current chain
    address iexRouter;
    address caller_contract;
    bool public isInitialized;

    function initialize(uint32 _DestinationDomain, address _hiddencard, address _iexRouter) public {
        require(isInitialized == false, "Bridge contract already initialized");
        DestinationDomain = _DestinationDomain;
        hiddencard = _hiddencard;
        iexRouter = _iexRouter;
        caller_contract = msg.sender;
        isInitialized = true;
    }

    function setCallerContract(address _caller_contract) public {
        caller_contract = _caller_contract;
    }

    function getICA() public view returns(address) {
        return IInterchainExecuteRouter(iexRouter).getRemoteInterchainAccount(DestinationDomain, address(this));
    }

    modifier onlyCallerContract() {
        require(caller_contract == msg.sender, "not right caller contract");
        _;
    }
}

contract incoEndpoint is BridgeContract {
    mapping(uint256 proposalId => mapping(uint8 choice => euint32 votePower)) private votePower;
    mapping (address => uint8) public encryptedCards;
    uint8 counter;

    constructor() {}

    function getVotePower(uint256 proposalId, uint8 choice, bytes32 publicKey) public view returns (bytes memory) {             // @inco
        return TFHE.reencrypt(votePower[proposalId][choice], publicKey, 0);
    }
    
    function returnCard() external onlyCallerContract returns(uint8) {
        counter++;
        return counter;
    }

    function viewCard() external view returns (uint8) {
        return counter;
    }

    function vote(uint256 proposalId, bytes calldata choice, uint32 votingPower) public {
        votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))] = TFHE.add(votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))], votingPower);
    }

    function execute(uint256 proposalId, bytes calldata executionPayload, address executor) public {
        
    }

    function receive(bytes memory data) {
        abi.decode(data);
    }
}