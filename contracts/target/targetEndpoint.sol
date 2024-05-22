pragma solidity 0.8.20;

import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {Proposal} from "./types.sol";

@title Endpoint contract in Target chain during bridging of data
contract TargetContract {
    // address public mailbox = 0x46e7416C63E71E8EA0f99A7F5033E6263c6e5138;
    address public mailbox = 0xE082D048F4B96e313D682255cE9aCA4BF8A527b1;        // base
    address public lastSender;
    bytes public lastData;
    uint32 public domainId = 9090;
    address public destinationContract;
    event ReceivedMessage(uint32, bytes32, uint256, string);

    uint256 public votecounter;
    // @dev event emitted during vote function is called and will be used to pass message to offchain server
    event counter_choice_vote(uint256, bytes);

    uint256 public executecounter;
    // @dev event emitted during execute function is called and will be used to pass message to offchain server
    event counter_execute(uint256, bytes, bytes32);


    // IPostDispatchHook public hook;
    // IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0x71b6fdF09C772F2ED28B15059Bd104f4c282290f);
    IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0xA7c9326c582Fe968563B1Afe5038827A0936caa9);          // base


    
    function setHook(address _hook) public {
        // hook = IPostDispatchHook(_hook);
    }

    /// @notice initialize the contract with the destination contract to send data to using hyperlane
    function initialize(address _destinationContract) public {
        destinationContract = _destinationContract;
    }

    function setInterchainSecurityModule(address _module) public {
        interchainSecurityModule = IInterchainSecurityModule(_module);
    }

    // Modifier so that only mailbox can call particular functions
    modifier onlyMailbox() {
        require(
            msg.sender == mailbox,
            "Only mailbox can call this function !!!"
        );
        _;
    }

    /// @notice handle function which is called by the mailbox to bridge votes from other chains
    /// @param _origin The domain of the origin chain
    /// @param _sender The address of the sender on the origin chain
    /// @param _data The data sent by the _sender
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _data
    ) external payable {
        emit ReceivedMessage(_origin, _sender, msg.value, string(_data));
        lastSender = bytes32ToAddress(_sender);
        lastData = _data;
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    /// @notice Function to send the data through hyperlane to destination chain and address
    /// @param data data to send also containing a uint8(1 -> vote, 2-> execute) function selector to know for a voting and an executing transaction
    function sendMessage(bytes memory data) payable public {
        IMailbox(mailbox).dispatch(domainId, addressToBytes32(destinationContract), data);
    }

    // converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    /// @notice initiating the vote cast on target chain and sending the relevant data to hyperlane and offchain server
    /// @param proposalId id of the proposal to be voted on
    /// @param votingPower number of votes the voter has to vote on
    /// @param choice type of vote (For, Abstain, Against)
    function vote(uint256 proposalId, uint32 votingPower, bytes memory choice) public {
        bytes32 choiceHash = keccak256(choice);
        bytes memory data = abi.encode(uint8(1), proposalId, votingPower, abi.encode(choiceHash));
        sendMessage(data);
        emit counter_choice_vote(votecounter, choice);
        votecounter++;
    }

    /// @notice initiate the execution on target chain
    /// @param proposalId id of the proposal to be voted on
    /// @param proposal proposal related to the proposalId
    /// @param executionPayload data to be used while execution
    function execute(uint256 proposalId, Proposal memory proposal, bytes memory executionPayload) public {
        bytes32 proposalhash = keccak256(abi.encode(proposal));
        bytes memory data = abi.encode(uint8(2), proposalId, proposalhash, executionPayload);
        sendMessage(data);
        emit counter_execute(executecounter, abi.encode(proposal), proposalhash);
        executecounter++;
    }
}
