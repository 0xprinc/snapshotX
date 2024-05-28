pragma solidity 0.8.20;

import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";

import "fhevm/lib/TFHE.sol";

import {Proposal} from "./types.sol";
import { IExecutionStrategy } from "./interfaces/IExecutionStrategy.sol";

contract IncoContract {
    address public mailbox = 0xb2EF9249C4fDB9Eb4c105cE0C3AA47b33126A224;
    address public lastSender;
    bytes public lastData;
    uint public received;
    uint32 public domainId = 84532;

    address public destinationContract;
    event ReceivedMessage(uint32, bytes32, uint256, string);

    mapping(uint256 proposalId => mapping(uint8 choice => euint32 votePower)) private votePower;


    // IPostDispatchHook public hook;
    IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0x49D0975615D947BFEBC661200F758b4ECd0Ecb2D);


    
    function setHook(address _hook) public {
        // hook = IPostDispatchHook(_hook);
    }

    function initialize(address _destinationContract) public {
        destinationContract = _destinationContract;
    }

     function setInterchainSecurityModule(address _module) public {
         interchainSecurityModule = IInterchainSecurityModule(_module);
     }

    function aggregatedVotes(uint256 proposalId) public view returns (uint256 votesFor, uint256 votesAgainst, uint256 votesAbstain) {
        return (TFHE.decrypt(votePower[proposalId][1]), TFHE.decrypt(votePower[proposalId][0]), TFHE.decrypt(votePower[proposalId][2]));
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
        // lastSender = bytes32ToAddress(_sender);
        // lastData = _data;
        // received++;
        // (,uint8 selector) = abi.decode(_data, (bytes32, uint8));

        // if (selector == 1) {
        //     (uint256 proposalId, uint32 votingPower, bytes memory choice) = abi.decode(_data, (bytes32, uint8, uint256, uint32));
        //     vote(proposalId, votingPower, choice);
        // } else if (selector == 2) {
        //     (uint256 proposalId, Proposal memory proposal, address executor, bytes memory executionPayload) = abi.decode(_data, (uint256, Proposal  , address , bytes));
        //     execute(proposalId, proposal, executor, executionPayload);
        // }
    }

    // alignment preserving cast
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }

    function sendMessage(bytes calldata data) payable public {
        // uint256 quote = IMailbox(mailbox).quoteDispatch(domainId, addressToBytes32(destinationContract), abi.encode(body));
        IMailbox(mailbox).dispatch(domainId, addressToBytes32(destinationContract), data);
    }

    // converts address to bytes32
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function getVotePower(uint256 proposalId, uint8 choice, bytes32 publicKey) public view returns (bytes memory) {             // @inco
        return TFHE.reencrypt(votePower[proposalId][choice], publicKey, 0);
    }

    function vote(uint256 proposalId, uint32 votingPower, bytes memory choice) public {
        ebool isAgainst = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(0));
        ebool isFor = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(1));
        ebool isAbstain = TFHE.eq(TFHE.asEuint8(choice), TFHE.asEuint8(2));

        votePower[proposalId][0] = TFHE.add(votePower[proposalId][0], TFHE.cmux(isAgainst, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));
        votePower[proposalId][1] = TFHE.add(votePower[proposalId][1], TFHE.cmux(isFor, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));
        votePower[proposalId][2] = TFHE.add(votePower[proposalId][2], TFHE.cmux(isAbstain, TFHE.asEuint32(votingPower), TFHE.asEuint32(0)));
    }

    function execute(uint256 proposalId, Proposal memory proposal, address executor, bytes memory executionPayload) public {
        IExecutionStrategy(executor).execute(
            proposalId,
            proposal,
            votePower[proposalId][1],
            votePower[proposalId][0],
            votePower[proposalId][2],
            executionPayload
        );
    }

    function handleWithCiphertext( uint32 _origin,
        bytes32 _sender,
        bytes memory _message) external{
            (bytes memory message, bytes memory choice) = abi.decode(_message,(bytes , bytes));

            // (,uint8 selector) = abi.decode(_data, (bytes32, uint8));
            // if (selector == 1) {
                (, uint256 proposalId, uint32 votingPower) = abi.decode(message, (bytes32, uint256, uint32));
                vote(proposalId, votingPower, choice);
            // } else if (selector == 2) {
            //     (uint256 proposalId, Proposal memory proposal, address executor, bytes memory executionPayload) = abi.decode(_data, (uint256, Proposal  , address , bytes));
            //     execute(proposalId, proposal, executor, executionPayload);
            // }
        }
        
}
