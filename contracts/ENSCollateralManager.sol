pragma solidity ^0.4.11;

import './dependencies/Ownable.sol';
import './dependencies/ens/HashRegistrarSimplified.sol';

// Manages ENS name deeds to be used as collateral for Lendroid ENS based loans.
// Requires the deed of the ENS name to be transferred to this contract's address
// The user is free to 'manage/use' the name while the name stays with this contract even while encumbered but not when they have failed to close a loan in time.
// Once the ENS name is transferred to this contract, the user can use the ens-loan contract to request a loan.
// If the ENS name is locked up for a loan, the deed is not transfarable.
// If the user fails to repay the loan before the agreed expiry time, they forfeit the right to reclaim the deed.
// The ENSLoanManager contract requests the collateral manager to encumber/unencumber a deed.
contract ENSCollateralManager is Ownable  {

    AbstractENS public ens;
    Registrar public registrar;
    address public ENSLoanManager;
    mapping(address=>bool) public encumbered;

    //MODIFIERS
    modifier onlyENSLoanManager() {
      //if (msg.sender != ENSLoanManager) {
      //  throw;
      //  _;
      //}
    }

    // CONSTRUCTOR
    function ENSCollateralManager(address _ensAddress,address _registrarAddress) {
        //address _ensAddress = '0xb766772c58b098d8412143a473aed6bc41c95bde';
        //address _registrarAddress = '0xa5c650649b2a8e3f160035cee17b3c7e94b0805f';
        ens = AbstractENS(_ensAddress);
        registrar = Registrar(_registrarAddress);
    }

    function withdrawCollateral(string _ensDomain) returns (bool) {
        bytes32 domainHash = sha3(_ensDomain);
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(domainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        var _previousDeedOwner = _deedContract.previousOwner();
        var _currentDeedOwner = _deedContract.owner();
        require(_currentDeedOwner == address(this));
        require(_previousDeedOwner == msg.sender);
        registrar.transfer(domainHash, msg.sender);
        return true;
    }

    function encumberCollateral(string _ensDomain, address _requester) onlyENSLoanManager returns(bool status, address deedAddress, uint collateralValue ){
        bytes32 domainHash = sha3(_ensDomain);
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(domainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = true;
        return (true, _deedAddress, _value);
    }


    function unencumberCollateral(string _ensDomain, address _requester) onlyENSLoanManager returns(bool status){
        bytes32 domainHash = sha3(_ensDomain);
        var (_mode, _deedAddress, _timestamp, _value, _highestBid) = registrar.entries(domainHash);
        require(!encumbered[_deedAddress]);
        var _deedContract = Deed(_deedAddress);
        require(_deedContract.owner() == address(this));
        require(_deedContract.previousOwner() == _requester);
        encumbered[_deedAddress] = false;
        return true;
    }


    //TODO: function to transfer capability to manage the ENS name while the deed contract stays with this contract.


    //Migration related functions
    function changeENSLoanManager(address _ENSLoanManager) onlyOwner returns (bool) {
        ENSLoanManager = _ENSLoanManager;
        return true;
    }


    //Escape hatch functions
    function escapeHatchClaimDeed(string ensDomain) onlyOwner returns (bool) {
        bytes32 domainHash = sha3(ensDomain);
        registrar.transfer(domainHash, owner);
        return true;
    }

}
