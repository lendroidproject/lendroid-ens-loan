pragma solidity ^0.4.11;

import './Ownable.sol';
import './HashRegistrarSimplified.sol';


/**
    @title ENSCollateralManager
    @notice The ENSCollateralManager contract inherits the Ownable contract, and 
        manages ENS name deeds to be used as collateral for Lendroid's ENS-based loans.
    @dev The contract has references to the following external contracts:
        1. Registrar Contract from ENS - To verify and transfer domain ownership
        2. LoanManager Contract - To interact with this contract while (un) / encumbering
           a deed
        The contract works as follows:
        1. Depositing the Collateral - The deed of the ENS name is required to be 
           transferred to this contract's address.
        2. Once the ENS name is transferred to this contract, the user can use the 
           ens-loan contract to request a loan.
        3. If the ENS name is locked up for a loan, the deed is not transfarable.
        4. If the user fails to repay the loan before the agreed expiry time, 
           they forfeit the right to reclaim the deed.
        5. Only the ENSLoanManager contract can request the contract to encumber/unencumber a deed.
        6. The user is free to 'manage/use' the name while the name stays with this 
           contract even while encumbered but not when they have failed to close a loan on time.
*/
contract ENSCollateralManager is Ownable {

    AbstractENS public ens;
    Registrar public registrar;
    address public ENSLoanManager;
    mapping(address=>bool) public encumbered;

    /**
        @dev Throws if called by any account other than the LoanManager. 
    */
    modifier onlyENSLoanManager() {
        assert(msg.sender == ENSLoanManager);
        _;
    }

    /** 
        @notice The ENSCollateralManager constructor sets the ENS Registrar address.
    */
    function ENSCollateralManager() {
        address _ensAddress = 0xb766772c58b098d8412143a473aed6bc41c95bde;
        address _registrarAddress = 0xa5c650649b2a8e3f160035cee17b3c7e94b0805f;
        ens = AbstractENS(_ensAddress);
        registrar = Registrar(_registrarAddress);
    }

    /**
        @notice Encumbers the deed address of a given ENS domain (collateral). This locks collateral 
            until the loan amount is paid out.
        @dev The function works on the following algorithm:
            1. The current and previous owners of the domain are obtained from ENS Registrar and Deed
               contracts.
            2. The _requester is verified as the previous owner, while the contract is verified
               as the current owner of the domain.
            3. The contract encumbers the deed and sends the following values back to the LoanManager 
               contract:
        @param _ensDomainHash sha of the ENS domain name
        @param _requester address that borrowed the loan
        @return true the deed was successfully encumbered
        @return _deedAddress obtained from the ENS contract, which is the reference for the Loan
        @return _timestamp obtained from the ENS contract, to determine the Loan expiry date
        @return _value obtained from the ENS contract, to determine the value of the domain
    */
    function encumberCollateral(bytes32 _ensDomainHash, address _requester) onlyENSLoanManager returns (
        bool,
        address,
        uint,
        uint
    ) {
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(_ensDomainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = true;
        return (true, _deedAddress, _timestamp, _value);
    }

    /**
        @notice Unencumbers the deed address for the given ENS domain.
        @dev The function works on the following algorithm:
            1. The deed address is obtained from ENS Registrar and verified to be encumbered.
            2. The current and previous owners of the domain are obtained from ENS Registrar and Deed
               contracts.
            3. The _requester is verified as the previous owner, while the contract is verified
               as the current owner of the domain.
            4. The contract encumbers the deed address.
        @param _ensDomainHash sha of the ENS domain name
        @param _requester address that borrowed the loan
        @return true an acknowledgement that the collateral was unencumbered
    */
    function unencumberCollateral(bytes32 _ensDomainHash, address _requester) onlyENSLoanManager returns(bool) {
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(_ensDomainHash);
        require(encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = false;
        return true;
    }

    /**
        @notice Allows the message sender to withdraw their ENS domain (collateral) from the contract.
        @dev The function works on the following algorithm:
            1. The current and previous owners of the domain are obtained from ENS Registrar and Deed
               contracts.
            2. The message sender is verified as the previous owner, while the contract is verified
               as the current owner of the domain.
            3. The contract requests the ENS Registrar to transfer the domain to the message sender.
        @param _ensDomainHash sha of the ENS domain name
        @return true an acknowledgement that the collateral was withdrawn
    */
    function withdrawCollateral(bytes32 _ensDomainHash) returns (bool) {
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(_ensDomainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        var _previousDeedOwner = _deedContract.previousOwner();
        var _currentDeedOwner = _deedContract.owner();
        require(_currentDeedOwner == address(this));
        require(_previousDeedOwner == msg.sender);
        registrar.transfer(_ensDomainHash, msg.sender);
        return true;
    }

    /**
        @notice Allows the current owner to unencumber a deed address.
        @param _deedAddress The address to be unencumbered
        @return true an acknowledgement that the deed address was unencumbered by the owner
    */
    function forceUnencumberCollateral(address _deedAddress) onlyOwner returns (bool status) {
        encumbered[_deedAddress] = false;
        return true;
    }

    /**
        @notice allows the current owner to change the address of the LoanManager Contract.
        @dev This function is for migration purposes so that the function calls encumberCollateral() 
            and unencumberCollateral() are restricted to just the LoanManager contract.
        @param _ENSLoanManager the address of the LoanManager contract
        @return true an acknowledgement that the _ENSLoanManager was changed by the owner
    */
    function changeENSLoanManager(address _ENSLoanManager) onlyOwner returns (bool) {
        ENSLoanManager = _ENSLoanManager;
        return true;
    }

    /**
        @notice Escape hatch function that allows the current owner to transfer a domain to their name.
        @dev This is a failsafe mechanism to handle use-cases when domains are locked under unexpected
            circumstances.
        @param _ensDomainHash sha of the ENS domain
        @return true an acknowledgement that the ENS domain was transferred to the owner's address
    */
    function escapeHatchClaimDeed(bytes32 _ensDomainHash) onlyOwner returns (bool) {
        registrar.transfer(_ensDomainHash, owner);
        return true;
    }

    //TODO: function to transfer capability to manage the ENS name while the deed contract stays with this contract.
}
