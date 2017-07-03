pragma solidity ^0.4.2;

contract Market {

    uint defaultMaxLoanDuration;
    uint gracePeriodDuration;
    uint gracePeriodFine;
    uint dailyInterestRate;
    uint dailyLGTOffered;
    bool acceptingNewLoans;

    enum State {
        ACTIVE,
        CLOSED,
        GRACE_PERIOD,
        DEFAULTED
    }

    struct Loan {
        // Fields that would never change throughout the Agreement's longevity
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

    function create(
            string _cNode, uint _lAmount, uint _period
        )
        synchronized
        returns (uint id)
    {
        Loan memory loan;
        // First check if collatreal owner has enough collateral amount to deposit
        // Transfer ETH
        // var has_collateral_owner_paid = _cAsset.transferFrom(msg.sender, this, _cAmount);
        // assert(has_collateral_owner_paid);

        // Set loan fields

        loan.collateralOwner;
        loan.loanAmount;
        
        loan.state = State.ACTIVE;
        loan.maxDurationDays = _period;
        loan.startedOn = now;
        loan.collateralNode = _cNode;
        loan.collateralOwner = msg.sender;
        loan.loanAmount = _lAmount;
        id = nextId();
        loans[id] = loan;
    }

    // PUBLIC FUNCTIONS

    function newLoan(string _cNode, uint _lAmount, uint _period) returns (bytes32 id) {
        return bytes32(create(_cNode, _lAmount, _period));
    }

    function getDailyInterestRate(address addr) returns(uint) {
        return dailyInterestRate;
    }

    function getDefaultMaxLoanDuration(address addr) returns(uint) {
        return defaultMaxLoanDuration;
    }

    function getGracePeriodFine(address addr) returns(uint) {
        return gracePeriodFine;
    }

    function getDailyLGTRate(address addr) returns(uint) {
        return dailyLGTOffered;
    }

    function getAcceptingNewLoans(address addr) returns(bool) {
        return acceptingNewLoans;
    }

}