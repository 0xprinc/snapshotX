pragma solidity ^0.8.20;


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

interface IHiddenCard {
    function returnCard(address user) external returns(uint8);
}


contract Card is BridgeContract {
    bytes32 messageId;
    mapping (address => uint8) public Cards;

    function CardGet(address user) public {
        IHiddenCard _Hiddencard = IHiddenCard(hiddencard);

        bytes memory _callback = abi.encodePacked(this.cardReceive.selector, (uint256(uint160(user))));

        messageId = IInterchainExecuteRouter(iexRouter).callRemote(
            DestinationDomain,
            address(_Hiddencard),
            0,
            abi.encodeCall(_Hiddencard.returnCard, (user)),
            _callback
        );
    }

    function cardReceive(uint256 user, uint8 _card) external {
        require(caller_contract == msg.sender, "not right caller contract");
        Cards[address(uint160(user))] = _card;
    }

    function CardView(address user) public view returns(uint8) {
        return Cards[user];
    }
}