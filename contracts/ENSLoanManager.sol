pragma solidity ^0.4.2;

import './ENSCollateralManager.sol';
import './SafeMath.sol';
import './Ownable.sol';


contract ENSLoanManager is Ownable {
    
    using SafeMath for uint;

    ENSCollateralManager public collateralManager;
    bool public active;
    uint public interestRatePerDay;
    uint public maxLoanPeriodDays;
    uint public lendableLevel;
    uint balance;
    address collateralManagerAddress;

    enum Status {
        ACTIVE,
        CLOSED,
        GRACE_PERIOD,
        DEFAULTED
    }

    struct Loan {
        bytes32  ensDomain;
        uint    timestamp;
        address borrower;
        address deedAddress;
        uint  amount;
        uint  amountPaid;
        uint    expiresOn;
        uint  interestRate;
        Status  status;
    }

    mapping (address => Loan[]) public userActiveLoans;
    mapping (address => Loan[]) public userArchivedLoans;

    // MODIFIERS

    // CONSTANT METHODS
    
    // CONSTRUCTOR
    function Market() {
        collateralManagerAddress = 0x8a580e47c638e0c42d79ab86e90ed78279fe5d1a;
        collateralManager = ENSCollateralManager(collateralManagerAddress);
        active = true;
        interestRatePerDay = 10;
        maxLoanPeriodDays = 30;
        lendableLevel = 2;
    }

    // ADMIN FUNCTIONS

    function setBalance(uint _b) onlyOwner returns (bool) {
        balance = _b;
        return true;
    }

    function setCollateralManagerAddress(address _a) onlyOwner returns (bool) {
        collateralManagerAddress = _a;
        return true;
    }

    function setActivity(bool _a) onlyOwner returns (bool) {
        active = _a;
        return true;
    }

    function setInterestRatePerDay(uint _i) onlyOwner returns (bool) {
        interestRatePerDay = _i;
        return true;
    }

    function setMaxLoanPeriodDays(uint _d) onlyOwner returns (bool) {
        maxLoanPeriodDays = _d;
        return true;
    }

    function setLendableLevel(uint _l) onlyOwner returns (bool) {
        lendableLevel = _l;
        return true;
    }

    // PUBLIC FUNCTIONS

    function createLoan(bytes32 _ensDomain) payable returns (uint id) {
        // First check if deed is encumbered
        var (_encumberable, _deedAddress, _registeredDate, _lockedAmount) = collateralManager.encumberCollateral(_ensDomain, msg.sender);
        // Set loan fields and save loan
        Loan memory loan;
        
        loan.timestamp = now;
        loan.borrower = msg.sender;
        loan.deedAddress = _deedAddress;
        loan.amount = SafeMath.mul(_lockedAmount, lendableLevel);
        loan.expiresOn = now + maxLoanPeriodDays;
        loan.status = Status.ACTIVE;
        loan.interestRate = interestRatePerDay;
        loan.ensDomain = _ensDomain;

        userActiveLoans[msg.sender].push(loan);
        // Update balance
        balance -= loan.amount;
        
    }

    function getActiveLoanIndex(bytes32 _ensDomainHash) internal returns (uint) {
        for (uint loanIndex = 0; loanIndex < userActiveLoans[msg.sender].length; loanIndex++) {
            if (userActiveLoans[msg.sender][loanIndex].ensDomain == _ensDomainHash) {
                return loanIndex;
            }
        }
        revert();
    }

    function archive(bytes32 _ensDomainHash, uint _amount) payable returns (uint id) {
        // First check if deed is encumbered
        Loan[] storage activeLoans = userActiveLoans[msg.sender];
        
        uint loanIndexToDelete = getActiveLoanIndex(_ensDomainHash);
        Loan activeLoan = activeLoans[loanIndexToDelete];
        assert(activeLoan.borrower == msg.sender);
        assert(activeLoan.expiresOn >= now);
        assert(activeLoan.amount == _amount);
        // Update balance
        balance += _amount;
        // Add loan to 'arhived' list
        userArchivedLoans[msg.sender].push(userActiveLoans[msg.sender][loanIndexToDelete]);
        // Remove loan from 'active' list
        
        activeLoans[loanIndexToDelete] = activeLoans[activeLoans.length-1];
        activeLoans.length--;
        bool unencumbered = collateralManager.unencumberCollateral(_ensDomainHash, msg.sender);
        
    }

    function newLoan(bytes32 _ensDomainHash) returns (bytes32 id) {
        return bytes32(createLoan(_ensDomainHash));
    }

    function closeLoan(bytes32 _ensDomainHash, uint _amount) returns (bytes32 id) {
        return bytes32(archive(_ensDomainHash, _amount));
    }
}
