pragma solidity ^0.4.2;

import './ENSCollateralManager.sol';
import './dependencies/SafeMath.sol';
import './dependencies/Ownable.sol';


/**
    @title ENSLoanManager
    @notice The ENSLoanManager contract inherits the Ownable contract, and manages Lendroid's ENS-based
        loans.
    @dev The contract has the following parameters:
            - Reference to ENSCollateralManager contract: To deposit the ENS domain as a collateral when
              creating a loan, to withdraw the collateral after closing a loan.
            - active: Specifies whether the contract accepts further loans.
            - interestRatePerDay: Sets daily interest rates on existing loans.
            - maxLoanPeriodDays: Sets the expiry date of a loan.
            - gracePeriodDays: Extends a loan that has not been paid on time.
            - lendableLevel: Specifies the loan amount offered based on the value of the ENS domain
        A loan is mapped to it's deed address in the 'loans' mapping data structure, and includes:
            - ensDomainName: The name of the domain against which the loan is borrowed.
            - ensDomainHash: Sha of the domain name.
            - timestamp: Start date of the loan
            - borrower: Borrower who is the owner of the collateral.
            - deedAddress: Deed address of the loan. This is also the key against which the loan is mapped.
            - amount: The loan amount.
            - amountPaid: The amount the borrower has paid so far.
            - lastUpdated: Indicates the time when the loan was closed or defaulted.
            - expiresOn: Indicates the time when the loan expires.
            - interestRate: The interest rate for the specific loan.
            - status: The status of the loan. Can be:
                - Active: The loan has not yet expired
                - Closed: The loan amount has been paid
                - Defaulted: The loan period has expired, but the loan amount has not been paid.
        The contract works as follows:
            1. Opening a Loan - After depositing the ENS domain as a collateral, the specifications of the loan
               are set based on the contract's parameters. The loan is then created and mapped with it's deed
               address.
            2. Managing a Loan - An existing loan can be managed by providing it's deed address. Currently,
               a borrower can perform the following actions:
                    - Check the amount required to close an existing loan.
                    - Close an existing loan.
            3. Closing a Loan - After the borrower pays the due amount, the loan is closed and the ENS domain
               (collateral) is transfered back to the borrower.
 */
contract ENSLoanManager is Ownable {

    using SafeMath for uint256;
    ENSCollateralManager public collateralManager;
    bool public active;
    uint256 public constant decimals = 4;
    uint256 public interestRatePerDay;
    uint256 public maxLoanPeriodDays;
    uint256 public gracePeriodDays;
    uint256 public lendableLevel;
    address collateralManagerAddress;

    enum Status {
        UNISSUED,
        ACTIVE,
        CLOSED,
        DEFAULTED
    }

    struct Loan {
        bytes32 ensDomainHash;
        bytes32 ensDomainName;
        uint256 timestamp;
        address borrower;
        address deedAddress;
        uint256 amount;
        uint256 amountPaid;
        uint256 lastUpdated;
        uint256 expiresOn;
        uint256 interestRate;
        Status status;
    }

    mapping (address => Loan) public loans;

    event loanCreated(bytes32 ensDomainHash, address toAddress, uint256 loanAmount);
    event loanClosed(bytes32 ensDomainHash, address by, uint256 repaymentAmount);

    function percentOf(uint256 _quantity, uint256 _percentage) internal returns (uint256){
        return _quantity.mul(_percentage).div(10 ** decimals);
    }

    /**
        @notice The ENSLoanManager constructor sets the following values:
            - The address of the deployed ENSCollateralManager contract
            - The 'active value'
            - The daily interest rate
            - The maximum loan period in days
            - The grace period in days
            - The lendable level
    */
    function ENSLoanManager() {
        collateralManagerAddress = 0xB6BFE80Bc8E835C078F8e9fC8cb5212E70108E75;
        collateralManager = ENSCollateralManager(collateralManagerAddress);
        active = true;
        interestRatePerDay = 100;
        maxLoanPeriodDays = 30 days;
        gracePeriodDays = 100 days;
        lendableLevel = 8000;
    }

    /**
        @dev Throws if called by any account.
    */
    function() {
        revert();
    }

    /**
        @notice Creates a loan for the ENS collateral that has not yet been encumbered.
        @dev The function works based on the following algorithm:
            1. Verify that the deed address of the ENS domain has been encumbered.
            2. Create a new loan with the deed address as its mapping reference.
            3. Transfer the loan amount to the message sender.
        @param _ensDomainName the name of the ENS domain as a plaintext
        @return true the loan was successfully created
    */
    function createLoan(bytes32 _ensDomainName, bytes32 _ensDomainHash) returns (bool) {
        // bytes32 _ensDomainHash = sha3(_ensDomainName);

        var (_encumbered, _deedAddress, _registeredDate, _lockedAmount) = collateralManager.encumberCollateral(_ensDomainHash, msg.sender);
        assert(_encumbered);
        _registeredDate;
        // Set loan fields and save loan
        Loan memory loan;

        loan.timestamp = now;
        loan.borrower = msg.sender;
        loan.deedAddress = _deedAddress;
        loan.ensDomainName = _ensDomainName;
        loan.ensDomainHash = _ensDomainHash;
        loan.amount = percentOf(_lockedAmount, lendableLevel);
        // assert(this.value >= loan.amount);
        loan.expiresOn = now + maxLoanPeriodDays;
        loan.status = Status.ACTIVE;
        loan.interestRate = interestRatePerDay;
        loans[_deedAddress] = loan;
        msg.sender.transfer(loan.amount);
        loanCreated(_ensDomainHash, loan.borrower, loan.amount);
        return true;
    }

    /**
        @notice Closes the loan mapped to the given deed address.
        @dev The function works based on the following algorithm:
            1. The active loan for the given deed address is retrieved.
            2. Validation is performed on the active loan.
            3. The loan is closed.
            4. The collateral is unencumbered.
        @param _deedAddress the address of the deed whose loan should be closed
        @return true the loan was successfully closed
    */
    function closeLoan(address _deedAddress) payable returns (bool) {
        // Get Active loan based on domain name
        Loan activeLoan = loans[_deedAddress];
        // Validations
        // Verify borrower
        assert(activeLoan.borrower == msg.sender);
        // Verify expiry date
        assert(activeLoan.expiresOn.add(gracePeriodDays) >= now);
        // Verify interest
        uint256 daysSinceLoan = (now - activeLoan.timestamp).div(86400);
        uint256 interestAccrued = percentOf(activeLoan.amount , interestRatePerDay).mul(daysSinceLoan);
        assert(interestAccrued.add(activeLoan.amount) == msg.value);
        // Archive the active loan
        activeLoan.status = Status.CLOSED;
        activeLoan.amountPaid = msg.value;
        activeLoan.lastUpdated = now;
        assert(collateralManager.unencumberCollateral(activeLoan.ensDomainHash, msg.sender));
        loanClosed(activeLoan.ensDomainHash,msg.sender,activeLoan.amountPaid);
        return true;
    }

    /**
        @notice Returns the amount owed for a loan mapped to the given deed address.
        @dev The function works based on the following algorithm:
            1. The active loan for the given deed address is retrieved.
            2. The amount owed is calculated for the active loan.
        @param _deedAddress the address of the deed whose loan amount is owed
        @return uint256 the owed amount
    */
    function amountOwed(address _deedAddress) constant returns (uint256) {
        Loan activeLoan = loans[_deedAddress];
        uint256 daysSinceLoan = (now - activeLoan.timestamp).div(86400);
        uint256 interestAccrued = percentOf(activeLoan.amount , interestRatePerDay).mul(daysSinceLoan);
        if (activeLoan.expiresOn < now) {
            return 0;
        }
        return interestAccrued.add(activeLoan.amount);
    }

    /**
        @dev Payable which can be called only by the contract owner.
        @return true the contract's balance was successfully refilled
    */
    function refillBalance() onlyOwner payable returns (bool) {
        return true;
    }

    /**
        @dev Payable function which can be called only by the contract owner.
        @return true the contract's balance was successfully withdrawn
    */
    function withdrawBalance(uint256 _amount) onlyOwner  returns (bool) {
        msg.sender.transfer(_amount);
        return true;
    }

    /**
        @notice allows the current owner to change the address of the ENSCollateralManager Contract.
        @param _a the address of the ENSCollateralManager contract
        @return true an acknowledgement that the collateralManagerAddress was set by the owner
    */
    function setCollateralManagerAddress(address _a) onlyOwner returns (bool) {
        collateralManagerAddress = _a;
        collateralManager = ENSCollateralManager(collateralManagerAddress);
        return true;
    }

    /**
        @notice allows the current owner to change the loan acceptance boolean value of the contract.
        @param _a the 'active' value as a boolean (true or false)
        @return true an acknowledgement that the 'active' value was set by the owner
    */
    function setIssuingNewLoans(bool _a) onlyOwner returns (bool) {
        active = _a;
        return true;
    }

    /**
        @notice allows the current owner to change the daily interest rate of the contract.
        @param _i integer value as the daily interest rate
        @return true an acknowledgement that the daily interest rate was set by the owner
    */
    function setInterestRatePerDay(uint256 _i) onlyOwner returns (bool) {
        interestRatePerDay = _i;
        return true;
    }

    /**
        @notice allows the current owner to change the daily interest rate.
        @param _d integer value as the daily interest rate
        @return true an acknowledgement that the daily interest rate was set by the owner
    */
    function setMaxLoanPeriodDays(uint256 _d) onlyOwner returns (bool) {
        maxLoanPeriodDays = _d;
        return true;
    }

    /**
        @notice allows the current owner to change the grace period.
        @param _d integer value as the grace period
        @return true an acknowledgement that the grace period was set by the owner
    */
    function setGracePeriodDays(uint256 _d) onlyOwner returns (bool) {
        gracePeriodDays = _d;
        return true;
    }

    /**
        @notice allows the current owner to change the lendableLevel.
        @param _l integer value as the lendableLevel
        @return true an acknowledgement that the lendableLevel was set by the owner
    */
    function setLendableLevel(uint256 _l) onlyOwner returns (bool) {
        require(_l <= (10 ** decimals));
        lendableLevel = _l;
        return true;
    }

}
