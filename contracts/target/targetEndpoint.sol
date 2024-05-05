pragma solidity 0.8.20;

import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {Proposal} from "./types.sol";
import {Executor} from "./executors/Executor.sol";

contract TargetContract {
    address public mailbox = 0x46e7416C63E71E8EA0f99A7F5033E6263c6e5138;
    address public lastSender;
    bytes public lastData;
    uint32 public domainId = 9090;
    address public destinationContract;
    event ReceivedMessage(uint32, bytes32, uint256, string);
    bytes constant public body = bytes("Hello, world");

    Executor public executor;

    constructor(address _executor) {
        executor = Executor(_executor);
    }


    // IPostDispatchHook public hook;
    IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0x71b6fdF09C772F2ED28B15059Bd104f4c282290f);


    
    function setHook(address _hook) public {
        // hook = IPostDispatchHook(_hook);
    }

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

    // handle function which is called by the mailbox to bridge votes from other chains
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _data
    ) external payable {
        emit ReceivedMessage(_origin, _sender, msg.value, string(_data));
        lastSender = bytes32ToAddress(_sender);
        lastData = _data;
        uint8 selector = abi.decode(_data, (uint8));
        if (selector == 1) {
            (,address target, bytes memory payload) = abi.decode(_data, (uint8, address, bytes));
            callExecutor(target, payload);
        }
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    // specifying the function with a uint8
    // 1 -> vote, 2-> execute
    function sendMessage(bytes memory data) payable public {
        // uint256 quote = IMailbox(mailbox).quoteDispatch(domainId, addressToBytes32(destinationContract), abi.encode(body));
        IMailbox(mailbox).dispatch(domainId, addressToBytes32(destinationContract), data);
    }

    // converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function vote(uint256 proposalId, uint32 votingPower, bytes calldata choice) public {
        bytes memory data = abi.encode(uint8(1), proposalId, votingPower, choice);
        sendMessage(data);
    }

    function execute(uint256 proposalId, Proposal memory proposal, address executionStrategy, bytes calldata executionPayload) public {
        bytes memory data = abi.encode(uint8(2), proposalId, proposal, executionStrategy, executionPayload);
        sendMessage(data);
    }

    function callExecutor(address target, bytes memory payload) public {
        executor.AvatarExecutor(target, payload);
    }
}