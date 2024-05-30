pragma solidity 0.8.20;

import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {Proposal} from "./types.sol";

contract TargetContract {
    address public mailbox = 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766;
    address public lastSender;
    bytes public lastData;
    uint32 public domainId = 9090;
    address public destinationContract;
    event ReceivedMessage(uint32, bytes32, uint256, string);

    uint256 public counter;
    bytes public sentData;


    // IPostDispatchHook public hook;
    // IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0xcAe8bD09aE9Ac21da7d1e189b5F7376aeCc82497);


    
    function setHook(address _hook) public {
        // hook = IPostDispatchHook(_hook);
    }

    function initialize(address _destinationContract) public {
        destinationContract = _destinationContract;
    }

    // function setInterchainSecurityModule(address _module) public {
    //     interchainSecurityModule = IInterchainSecurityModule(_module);
    // }

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
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    // specifying the function with a uint8
    // 1 -> vote, 2-> execute
    function sendMessage(bytes memory data) payable public {
        counter++;
        sentData = data;
        uint256 quote = IMailbox(mailbox).quoteDispatch(domainId,addressToBytes32(destinationContract),data);
        IMailbox(mailbox).dispatch{value: quote}(domainId, addressToBytes32(destinationContract), data);
    }

    // converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    // function vote(uint256 proposalId, uint32 votingPower, bytes calldata choice) public {
    //     bytes memory data = abi.encode(uint8(1), proposalId, votingPower, choice);
    //     sendMessage(data);
    // }

    function vote(uint256 proposalId, uint32 votingPower, bytes calldata choice) public payable{        // ciphertext
        bytes32 choicehash = keccak256(choice);
        bytes memory data = abi.encode(choicehash,uint8(1), proposalId, votingPower);
        sendMessage(data);
    }

    // ~ciphertext
    function execute(uint256 proposalId, Proposal memory proposal, address executor, bytes calldata executionPayload) public {
        bytes memory bproposal = abi.encode(proposal);
        bytes32 proposalhash = keccak256(bproposal);
        bytes memory data = abi.encode(proposalhash, uint8(2), proposalId, executor, executionPayload);
        sendMessage(data);
    }
}