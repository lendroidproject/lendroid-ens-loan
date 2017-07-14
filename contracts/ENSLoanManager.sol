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
        bytes32  ensDomain;
        uint256    timestamp;
        address borrower;
        address deedAddress;
        uint256  amount;
        uint256  amountPaid;
        uint256    expiresOn;
        uint256  interestRate;
        Status  status;
    }

    mapping (address => Loan[]) public userActiveLoans;
    mapping (address => Loan[]) public userArchivedLoans;

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
        maxLoanPeriodDays = 30;
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

    function createLoan(bytes32 _ensDomain) returns (bool) {
        // First check if deed is encumbered. If not en

        var (_encumbered, _deedAddress, _registeredDate, _lockedAmount) = collateralManager.encumberCollateral(_ensDomain, msg.sender);
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
        loan.ensDomain = _ensDomain;

        userActiveLoans[msg.sender].push(loan);
        msg.sender.transfer(loan.amount);
        return true;
    }

    function getActiveLoanIndex(bytes32 _ensDomainHash) internal returns (uint256) {
        for (uint256 loanIndex = 0; loanIndex < userActiveLoans[msg.sender].length; loanIndex++) {
            if (userActiveLoans[msg.sender][loanIndex].ensDomain == _ensDomainHash) {
                return loanIndex;
            }
        }
        revert();
    }

    function archive(bytes32 _ensDomainHash, uint256 loanIndexToDelete) returns (uint256) {
        Loan[] storage activeLoans = userActiveLoans[msg.sender];
        // Add loan to 'arhived' list
        userArchivedLoans[msg.sender].push(userActiveLoans[msg.sender][loanIndexToDelete]);
        // Remove loan from 'active' list
        activeLoans[loanIndexToDelete] = activeLoans[activeLoans.length-1];
        activeLoans.length--;
        collateralManager.unencumberCollateral(_ensDomainHash, msg.sender);
    }

    function newLoan(bytes32 _ensDomainHash) returns (bool) {
        return (createLoan(_ensDomainHash));
    }

    function closeLoan(bytes32 _ensDomainHash) payable returns (bytes32 id) {
        // Get Active loan based on domain name
        Loan[] storage activeLoans = userActiveLoans[msg.sender];
        uint256 loanIndexToDelete = getActiveLoanIndex(_ensDomainHash);
        Loan storage activeLoan = activeLoans[loanIndexToDelete];
        // Validations
        // Verify borrower
        assert(activeLoan.borrower == msg.sender);
        // Verify expiry date
        assert(activeLoan.expiresOn >= now);
        // Verify interest
        uint256 daysSinceLoan = (now - activeLoan.timestamp).div(86400);
        uint256 interestAccrued = percentOf(activeLoan.amount , interestRatePerDay).mul(daysSinceLoan);
        assert(activeLoan.amount + interestAccrued == msg.value);
        // Archive the active loan
        uint256 archived = archive(_ensDomainHash, loanIndexToDelete);

        assert(collateralManager.unencumberCollateral(_ensDomainHash, msg.sender));
        return bytes32(archived);
    }
}
