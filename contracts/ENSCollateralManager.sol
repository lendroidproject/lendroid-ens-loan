pragma solidity ^0.4.11;

import './Ownable.sol';
import './HashRegistrarSimplified.sol';

/**
 * @title ENSCollateralManager
 * @dev The ENSCollateralManager contract inherits the Ownable contract, and 
 * manages ENS name deeds to be used as collateral for Lendroid ENS based loans.
 * The contract has references to the following external contracts:
 * 1. Registrar Contract from ENS - To verify and transfer domain ownership
 * 2. LoanManager Contract - To interact with this contract while (un) / encumbering
 *    a deed
 * The contract works as follows:
 * 1. Depositing the Collateral - The deed of the ENS name is required to be 
 *    transferred to this contract's address.
 * 2. Once the ENS name is transferred to this contract, the user can use the 
 *    ens-loan contract to request a loan.
 * 3. If the ENS name is locked up for a loan, the deed is not transfarable.
 * 4. If the user fails to repay the loan before the agreed expiry time, 
 *    they forfeit the right to reclaim the deed.
 * 5. The ENSLoanManager contract requests the collateral manager to 
 *    encumber/unencumber a deed.
 * 6: The user is free to 'manage/use' the name while the name stays with this 
 *    contract even while encumbered but not when they have failed to close a loan on time.
 */
contract ENSCollateralManager is Ownable  {

    AbstractENS public ens;
    Registrar public registrar;
    address public ENSLoanManager;
    mapping(address=>bool) public encumbered;

    /**
    * @dev Throws if called by any account other than the LoanManager. 
    */
    modifier onlyENSLoanManager() {
        assert(msg.sender == ENSLoanManager);
        _;
    }

    /** 
    * @dev The ENSCollateralManager constructor sets the ENS Registrar address.
    */
    function ENSCollateralManager() {
        address _ensAddress = 0xb766772c58b098d8412143a473aed6bc41c95bde;
        address _registrarAddress = 0xa5c650649b2a8e3f160035cee17b3c7e94b0805f;
        ens = AbstractENS(_ensAddress);
        registrar = Registrar(_registrarAddress);
    }

    /**
    * @dev Allows the message sender to withdraw their ENS domain (collateral) from the contract.
    * The function works on the following algorithm:
    * 1. The current and previous owners of the domain are obtained from ENS Registrar and Deed
    *    contracts.
    * 2. The message sender is verified as the previous owner, while the contract is verified
    *    as the current owner of the domain.
    * 3. The contract requests the ENS Registrar to transfer the domain to the message sender.
    * @param sha of the ENS domain name. 
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
    * @dev Called by the LoanManager contract before creating a loan so the ENS domain (collateral)
    * is encumbered until the loan is closed.
    * The function works on the following algorithm:
    * 1. The current and previous owners of the domain are obtained from ENS Registrar and Deed
    *    contracts.
    * 2. The _requester is verified as the previous owner, while the contract is verified
    *    as the current owner of the domain.
    * 3. The contract encumbers the deed and sends the following values back to the LoanManager 
    *    contract:
    *      true : The deed was successfully encumbered.
    *      _deedAddress : Obtained from the ENS contract, which is the reference for the Loan
    *      _timestamp : Obtained from the ENS contract, to determine the Loan expiry date
    *      _value : Obtained from the ENS contract, to determine the value of the domain
    * @param _ensDomainHash: sha of the ENS domain name, _requester: address that borrowed the loan.
    */
    function encumberCollateral(bytes32 _ensDomainHash, address _requester) onlyENSLoanManager returns(bool status, address deedAddress, uint timestamp,  uint collateralValue ){
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(_ensDomainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = true;
        return (true, _deedAddress, _timestamp, _value);
    }

    /**
    * @dev Called by the LoanManager contract after closing a loan so the ENS domain (collateral)
    * is unencumbered.
    * The function works on the following algorithm:
    * 1. The deed address is obtained from ENS Registrar and verified to be encumbered.
    * 1. The current and previous owners of the domain are obtained from ENS Registrar and Deed
    *    contracts.
    * 2. The _requester is verified as the previous owner, while the contract is verified
    *    as the current owner of the domain.
    * 3. The contract encumbers the deed and sends an acknowledgement back to the LoanManager 
    *    contract:
    * @param _ensDomainHash: sha of the ENS domain name, _requester: address that borrowed the loan.
    */
    function unencumberCollateral(bytes32 _ensDomainHash, address _requester) onlyENSLoanManager returns(bool status){
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(_ensDomainHash);
        require(encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = false;
        return true;
    }

    /**
    * @dev Allows the current owner to unencumber a deed address.
    * @param _deedAddress: The address to be unencumbered.
    */
    function forceUnencumberCollateral(address _deedAddress) onlyOwner returns (bool) {
        encumbered[_deedAddress] = false;
        return true;
    }

    //TODO: function to transfer capability to manage the ENS name while the deed contract stays with this contract.


    /**
    * @dev Migration function that allows the current owner to change the address of the 
    * LoanManager Contract. This is done so the function calls encumberCollateral() and 
    * unencumberCollateral() are restricted to just the LoanManager contract.
    * @param _ENSLoanManager: The address of the LoanManager contract.
    */
    function changeENSLoanManager(address _ENSLoanManager) onlyOwner returns (bool) {
        ENSLoanManager = _ENSLoanManager;
        return true;
    }

    /**
    * @dev Escape hatch function that allows the current owner to transfer a domain to their name.
    * This is a failsafe mechanism to handle use-cases when domains are locked under unexpected
    * circumstances.
    * @param _ensDomainHash: sha of the ENS domain.
    */
    function escapeHatchClaimDeed(bytes32 _ensDomainHash) onlyOwner returns (bool) {
        registrar.transfer(_ensDomainHash, owner);
        return true;
    }

}
