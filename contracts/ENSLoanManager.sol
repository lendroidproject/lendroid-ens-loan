pragma solidity ^0.4.2;

import './ENSCollateralManager.sol';
import './SafeMath.sol';
import './Ownable.sol';


contract ENSLoanManager is Ownable {

    using SafeMath for uint256;
    ENSCollateralManager public collateralManager;
    bool public active;
    uint256 public constant decimals = 4;
    uint256 public interestRatePerDay;
    uint256 public maxLoanPeriodDays;
    uint256 public lendableLevel;
    address collateralManagerAddress;

    enum Status {
        ACTIVE,
        CLOSED,
        GRACE_PERIOD,
        DEFAULTED
    }

    struct Loan {
        bytes32  ensDomainHash;
        uint256    timestamp;
        address borrower;
        address deedAddress;
        uint256  amount;
        uint256  amountPaid;
        uint256    expiresOn;
        uint256  interestRate;
        Status  status;
    }

    mapping (address => Loan) public loans;

    // MODIFIERS

    // CONSTANT METHODS
    function percentOf(uint256 _quantity, uint256 _percentage) internal returns (uint256){
        return _quantity.mul(_percentage).div(10 ** decimals);
    }

    // CONSTRUCTOR
    function ENSLoanManager() {
        collateralManagerAddress = 0x8a580e47c638e0c42d79ab86e90ed78279fe5d1a;
        collateralManager = ENSCollateralManager(collateralManagerAddress);
        active = true;
        interestRatePerDay = 100;
        maxLoanPeriodDays = 30 days;
        lendableLevel = 8000;

    }

    // ADMIN FUNCTIONS

    function() {
        revert();
    }

    function refillBalance() onlyOwner payable returns (bool) {
        return true;
    }

    function withdrawBalance(uint256 _amount) onlyOwner  returns (bool) {
        msg.sender.transfer(_amount);
        return true;
    }

    function setCollateralManagerAddress(address _a) onlyOwner returns (bool) {
        collateralManagerAddress = _a;
        return true;
    }

    function setIssuingNewLoans(bool _a) onlyOwner returns (bool) {
        active = _a;
        return true;
    }

    function setInterestRatePerDay(uint256 _i) onlyOwner returns (bool) {
        interestRatePerDay = _i;
        return true;
    }

    function setMaxLoanPeriodDays(uint256 _d) onlyOwner returns (bool) {
        maxLoanPeriodDays = _d;
        return true;
    }

    function setLendableLevel(uint256 _l) onlyOwner returns (bool) {
        require(_l <= (10 ** decimals));
        lendableLevel = _l;
        return true;
    }



    // PUBLIC FUNCTIONS

    function createLoan(bytes32 _ensDomainHash) returns (bool) {
        // First check if deed is encumbered. If not en

        var (_encumbered, _deedAddress, _registeredDate, _lockedAmount) = collateralManager.encumberCollateral(_ensDomainHash, msg.sender);
        assert(_encumbered);
        // Set loan fields and save loan
        Loan memory loan;

        loan.timestamp = now;
        loan.borrower = msg.sender;
        loan.deedAddress = _deedAddress;
        loan.amount = percentOf(_lockedAmount,lendableLevel);
        // assert(this.value >= loan.amount);
        loan.expiresOn = now + maxLoanPeriodDays;
        loan.status = Status.ACTIVE;
        loan.interestRate = interestRatePerDay;
        loan.ensDomainHash = _ensDomainHash;

        loans[_deedAddress] = loan;
        assert(msg.sender.send(loan.amount));
        return true;
    }

    function newLoan(bytes32 _ensDomainHash) returns (bool) {
        return (createLoan(_ensDomainHash));
    }

    function amountOwed(address _deedAddress) constant returns (uint256) {
        Loan activeLoan = loans[_deedAddress];
        uint256 daysSinceLoan = (now - activeLoan.timestamp).div(86400);
        uint256 interestAccrued = percentOf(activeLoan.amount , interestRatePerDay).mul(daysSinceLoan);
        return interestAccrued.add(activeLoan.amount);
    }

    function closeLoan(address _deedAddress) payable returns (bool) {
        // Get Active loan based on domain name
        Loan activeLoan = loans[_deedAddress];
        // Validations
        // Verify borrower
        assert(activeLoan.borrower == msg.sender);
        // Verify expiry date
        assert(activeLoan.expiresOn >= now);
        // Verify interest
        uint256 daysSinceLoan = (now - activeLoan.timestamp).div(86400);
        uint256 interestAccrued = percentOf(activeLoan.amount , interestRatePerDay).mul(daysSinceLoan);
        assert(interestAccrued.add(activeLoan.amount) == msg.value);
        // Archive the active loan
        delete loans[_deedAddress];

        assert(collateralManager.unencumberCollateral(activeLoan.ensDomainHash, msg.sender));
        return true;
    }
}
