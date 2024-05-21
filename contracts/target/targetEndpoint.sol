pragma solidity 0.8.20;

// import {IMailbox} from "@hyperlane-xyz/core/contracts/interfaces/IMailbox.sol";
// import {IPostDispatchHook} from ".deps/npm/@hyperlane-xyz/core/contracts/interfaces/hooks/IPostDispatchHook.sol";
// import {IInterchainSecurityModule} from "@hyperlane-xyz/core/contracts/interfaces/IInterchainSecurityModule.sol";
import {Proposal} from "./types.sol";

contract TargetContract {
    // address public mailbox = 0x46e7416C63E71E8EA0f99A7F5033E6263c6e5138;
    // address public mailbox = 0xE082D048F4B96e313D682255cE9aCA4BF8A527b1;        // base
    // address public lastSender;
    // bytes public lastData;
    // uint32 public domainId = 9090;
    // address public destinationContract;
    // event ReceivedMessage(uint32, bytes32, uint256, string);


    // IPostDispatchHook public hook;
    // IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0x71b6fdF09C772F2ED28B15059Bd104f4c282290f);
    // IInterchainSecurityModule public interchainSecurityModule = IInterchainSecurityModule(0xA7c9326c582Fe968563B1Afe5038827A0936caa9);          // base


    
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
    // }

    // alignment preserving cast
    // function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
    //     return address(uint160(uint256(_buf)));
    // }

    // specifying the function with a uint8
    // 1 -> vote, 2-> execute
    // function sendMessage(bytes memory data) payable public {
    //     IMailbox(mailbox).dispatch(domainId, addressToBytes32(destinationContract), data);
    // }

    // converts address to bytes32
    // function addressToBytes32(address _addr) internal pure returns (bytes32) {
    //     return bytes32(uint256(uint160(_addr)));
    // }

    // uint256 public votecounter;
    event vote_init(address, uint256, uint32, bytes, bytes);

    // uint256 public executecounter;
    event execute_init(uint256, bytes, bytes);

    function vote(address voter, uint256 proposalId, uint32 votingPower, bytes memory choice, bytes memory signature) public {
        // bytes32 choiceHash = keccak256(choice);
        // bytes memory data = abi.encode(signature, proposalId, votingPower, choice);
        // sendMessage(data);
        emit vote_init(voter, proposalId, votingPower, choice, signature);
        // votecounter++;
    }

    // hash of the executionPayload is also to be taken care of since it can also be of very large size in bytes length
    function execute(uint256 proposalId, Proposal memory proposal, bytes memory executionPayload) public {
        bytes memory bProposal = abi.encode(proposal);
        // bytes memory data = abi.encode(signature, proposalId, executionPayload, bProposal);
        // sendMessage(data);
        emit execute_init(proposalId, bProposal, executionPayload);
        // executecounter++;
    }
}