pragma solidity ^0.4.2;

import './HashRegistrarSimplified.sol';

contract Market {

    AbstractENS public ens;
    Registrar public registrar;
    uint defaultMaxLoanDuration;
    uint gracePeriodDuration;
    uint gracePeriodFine;
    uint dailyInterestRate;
    uint dailyLGTOffered;
    address ensContract; // We need this to point to the correct ENS contract address, whenever it changes
    bool acceptingNewLoans;

    enum State {
        ACTIVE,
        CLOSED,
        GRACE_PERIOD,
        DEFAULTED
    }

    struct Loan {
        // Fields that would never change throughout the Agreement's longevity
        string ensDomain;
        uint    maxDurationDays;
        uint    startedOn;
        string  collateralNode; // Hash of the IPFS
        address collateralOwner;
        uint    loanAmount;
        // Fields that could change through the Agreement's longevity
        State   state;
    }

    mapping (uint => Loan) public loans;

    uint public lastLoanId;

    bool locked;

    function nextId() internal returns (uint) {
        lastLoanId++; return lastLoanId;
    }

    // MODIFIERS

    modifier synchronized {
        assert(!locked);
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner {
        // assert('owner_address' == msg.sender);
        _;
    }

    modifier onlyCollateralOwner(uint id) {
        assert(getCollateralOwner(id) == msg.sender);
        _;
    }

    modifier inState(uint id, State _state) {
        assert(getState(id) == _state);
        _;
    }

    // CONSTANT METHODS
    function assert(bool x) internal {
        if (!x) throw;
    }

    function getCollateralOwner(uint id) constant returns (address collateralOwner) {
        return loans[id].collateralOwner;
    }

    function getState(uint id) constant returns (State state) {
        return loans[id].state;
    }

    // CONSTRUCTOR
    function Market() {
        address esnAddress = 0xb766772c58b098d8412143a473aed6bc41c95bde;
        address registrarAddress = 0xa5c650649b2a8e3f160035cee17b3c7e94b0805f;
        ens = AbstractENS(esnAddress);
        registrar = Registrar(registrarAddress);
        defaultMaxLoanDuration = 60;
        gracePeriodDuration = 30;
        gracePeriodFine = 50;
        dailyInterestRate = 10;
        dailyLGTOffered = 100;
        acceptingNewLoans = true;
    }

    // ADMIN FUNCTIONS

    // function setMaxLoanDurationDays(uint days) synchronized onlyOwner returns (bool) {
    //     defaultMaxLoanDuration = days;
    //     return true;
    // }

    // function setGracePeriodDuration(uint days) synchronized onlyOwner returns (bool) {
    //     gracePeriodDuration = days;
    //     return true;
    // }

    // function setGracePeriodFine(uint amount) synchronized onlyOwner returns (bool) {
    //     gracePeriodFine = amount;
    //     return true;
    // }

    // function setDailyInterestRate(uint rate) synchronized onlyOwner returns (bool) {
    //     dailyInterestRate = rate;
    //     return true;
    // }

    // function setDailyInterestRate(uint rate) synchronized onlyOwner returns (bool) {
    //     dailyLGTOffered = rate;
    //     return true;
    // }

    // function setAcceptingNewLoans(bool accept) synchronized onlyOwner returns (bool) {
    //     acceptingNewLoans = accept;
    //     return true;
    // }

    // PUBLIC FUNCTIONS

    function create(string _ensDomain) synchronized returns (uint id) {
        Loan memory loan;
        // First check if collatreal owner has enough collateral amount to deposit
        // Transfer ETH
        // var has_collateral_owner_paid = _cAsset.transferFrom(msg.sender, this, _cAmount);
        // assert(has_collateral_owner_paid);

        // Check status = 2
        // Deed Contract

        // Set loan fields
        loan.state = State.ACTIVE;
        loan.maxDurationDays = 30;
        loan.startedOn = now;
        loan.ensDomain = _ensDomain;
        loan.collateralNode = '0.9';
        loan.collateralOwner = msg.sender;
        loan.loanAmount = 9;
        id = nextId();
        loans[id] = loan;
    }

    // PUBLIC FUNCTIONS

    function newLoan(string _ensDomain) returns (bytes32 id) {
        return bytes32(create(_ensDomain));
    }

    function getDailyInterestRate() returns(uint) {
        return dailyInterestRate;
    }

    function getDefaultMaxLoanDuration() returns(uint) {
        return defaultMaxLoanDuration;
    }

    function getGracePeriodFine() returns(uint) {
        return gracePeriodFine;
    }

    function getDailyLGTRate() returns(uint) {
        return dailyLGTOffered;
    }

    function getAcceptingNewLoans() returns(bool) {
        return acceptingNewLoans;
    }

    function reclaimDeed(string ensDomainName) returns (bool) {
        domainSha = sha3(ensDomainName)
        registrar.transfer(domainSha, msg.sender)
    }

}