pragma solidity 0.8.20;

// import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
// import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";

import "fhevm/lib/TFHE.sol";

import {Proposal} from "./types.sol";
import { IExecutionStrategy } from "./interfaces/IExecutionStrategy.sol";

// also we have to take care that the votes in inco and target chain are synced
contract IncoContract {
    // address public mailbox = 0x18a2B6a086EE7d4070Cf675BDf27717d03258FcF;
    // address public lastSender;
    // bytes public lastData;
    // uint32 public domainId = 17001;
    // address public destinationContract;
    // event ReceivedMessage(uint32, bytes32, uint256, string);

    // struct choiceData {
    //     uint256 proposalId;
    //     uint32 votingPower;
    // }

    // struct executeData {
    //     uint256 proposalId;
    //     bytes executionPayload;
    // }

    mapping(uint256 proposalId => mapping(uint8 choice => euint32 votePower)) public votePower;     // should be made private
    // mapping(bytes => bool[2]) public collectChoiceHashStatus;   // [bool(exists or not), bool(used one time or not)]
    // mapping(bytes => choiceData) public collectChoiceData;

    // mapping(bytes32 => bool[2]) public collectExecuteHashStatus;   // [bool(exists or not), bool(used one time or not)]
    // mapping(bytes32 => executeData) public collectExecuteData;
    mapping(uint256 proposalId => bool) public isExecuted;
    
    // struct executionlol{
    //     bytes32 proposalhash;
    //     uint256 proposalId;
    //     bytes payload;
    // }

    // executionlol[] public loll;

    function getIsExecuted(uint256 proposalId) public view returns(bool){
        return isExecuted[proposalId];
    }


    // IPostDispatchHook public hook;
    // IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0x79411A19a8722Dd3D4DbcB0def6d10783237adad);

    // function getCollectChoiceHashStatus(bytes memory choiceHash) public view returns(bool[2] memory){
    //     return collectChoiceHashStatus[choiceHash];
    // }

    // function getCollectChoiceData(bytes memory choiceHash) public view returns(choiceData memory){
    //     return collectChoiceData[choiceHash];
    // }
    
    // function setHook(address _hook) public {
    //     // hook = IPostDispatchHook(_hook);
    // }

    // function initialize(address _destinationContract) public {
    //     destinationContract = _destinationContract;
    // }

    // function setInterchainSecurityModule(address _module) public {
    //     interchainSecurityModule = IInterchainSecurityModule(_module);
    // }

    // Modifier so that only mailbox can call particular functions
    // modifier onlyMailbox() {
    //     require(
    //         msg.sender == mailbox,
    //         "Only mailbox can call this function !!!"
    //     );
    //     _;
    // }

    // handle function which is called by the mailbox to bridge votes from other chains
    // function handle(
    //     uint32 _origin,
    //     bytes32 _sender,
    //     bytes calldata _data
    // ) external payable {
    //     emit ReceivedMessage(_origin, _sender, msg.value, string(_data));
    //     lastSender = bytes32ToAddress(_sender);
    //     lastData = _data;
    //     uint8 selector = abi.decode(_data, (uint8));
    //     if (selector == 1) {
    //         (,uint256 proposalId, uint32 votingPower, bytes memory choiceHash) = abi.decode(_data, (uint8, uint256, uint32, bytes));
    //         require(collectChoiceHashStatus[choiceHash][0]!= true);
    //         collectChoiceHashStatus[choiceHash] = [true, false];
    //         collectChoiceData[choiceHash] = choiceData(proposalId, votingPower);
    //     } else if (selector == 2) {
    //         (, uint256 proposalId, bytes32 proposalhash, bytes memory executionPayload) = abi.decode(_data, (uint8, uint256, bytes32, bytes));
    //         loll.push(executionlol(proposalhash, proposalId, executionPayload));
    //         require(collectExecuteHashStatus[proposalhash][0]!= true);
    //         collectExecuteHashStatus[proposalhash] = [true, false];
    //         collectExecuteData[proposalhash] = executeData(proposalId, executionPayload);
    //     }
    // }

    // alignment preserving cast
    // function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
    //     return address(uint160(uint256(_buf)));
    // }

    // function sendMessage(bytes calldata data) payable public {
    //     // uint256 quote = IMailbox(mailbox).quoteDispatch(domainId, addressToBytes32(destinationContract), abi.encode(body));
    //     IMailbox(mailbox).dispatch(domainId, addressToBytes32(destinationContract), data);
    // }

    // converts address to bytes32
    // function addressToBytes32(address _addr) internal pure returns (bytes32) {
    //     return bytes32(uint256(uint160(_addr)));
    // }

    function getVotePower(uint256 proposalId, uint8 choice, bytes32 publicKey) public view returns (bytes memory) {             // @inco
        return TFHE.reencrypt(votePower[proposalId][choice], publicKey, 0);
    }

    // function vote(bytes memory choiceHash, bytes memory choice) public {
    function vote(address voter, uint256 proposalId, uint32 votingPower, bytes memory choice, bytes memory signature) public {
        
        // Split the signature into r, s and v components
        require(signature.length == 65, "Invalid signature length");
        bytes32 r = bytes32(abi.decode(signature[:32], (bytes32)));
        bytes32 s = bytes32(abi.decode(signature[32:64], (bytes32)));
        uint8 v = uint8(abi.decode(signature[64:], (uint8)));

        // Use ecrecover to recover the address of the signer
        address signer = ecrecover(keccak256(choice), v, r, s);
        require(signer == voter,"invalid signature");
        
        // require(keccak256(choice) == bytes32(choiceHash));
        // bool[2] memory status = collectChoiceHashStatus[choiceHash];
        // require(status[0] == true && status[1] == false);
        // uint256 proposalId = collectChoiceData[choiceHash].proposalId;
        // uint32 votingPower = collectChoiceData[choiceHash].votingPower;
        votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))] = TFHE.add(votePower[proposalId][TFHE.decrypt(TFHE.asEuint8(choice))], votingPower);
        // collectChoiceHashStatus[choiceHash] = [true, true];
    }

    function execute(uint256 proposalId, bytes memory proposal, bytes memory executionPayload, uint32 blocknumber) public {
        // require(keccak256(proposal) == proposalhash, "hash not matched");
        // bool[2] memory status = collectExecuteHashStatus[proposalhash];
        // require(status[0] == true && status[1] == false, "status not matched");
        // uint256 proposalId = collectExecuteData[proposalhash].proposalId;
        // bytes memory executionPayload = collectExecuteData[proposalhash].executionPayload;
        Proposal memory _proposal = abi.decode(proposal, (Proposal));

        IExecutionStrategy(_proposal.executionStrategy).execute(
            proposalId,
            _proposal,
            votePower[proposalId][1],
            votePower[proposalId][0],
            votePower[proposalId][2],
            executionPayload,
            blocknumber
        );

        // collectExecuteHashStatus[proposalhash] = [true, true];
        
        isExecuted[proposalId] = true;
    }
}