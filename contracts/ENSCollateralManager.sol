pragma solidity ^0.4.2;

import './dependencies/Ownable.sol';
import './dependencies/ens/HashRegistrarSimplified.sol';

// Manages ENS name deeds as collateral for Lendroid ENS based loans.
// Requires the deed of the ENS name to be transferred to this contract's address
// The user is free to 'use' the name while the name stays with this contract even while encumbered and there are no loans that have expired.
// Once the ENS name is transferred to this contract, the user can use the ens-loan contract to request a loan.
// If the ENS name is not locked up for a loan, the
contract ENSCollateralManager is Ownable  {

    AbstractENS public ens;
    Registrar public registrar;

    //
    modifier onlyCollateralOwner(string _ensDomain) {
      bytes32 domainHash = sha3(_ensDomain);
      var (_mode, _deedOwner, _timestamp, _value, _highestBid) = registrar.entries(domainHash);
      var _deedContract = Deed(_deedOwner);
      require(_deedContract.owner() == this);
      require(_deedContract.previousOwner() == msg.sender);

    }

    function getCollateralOwner(string ensDomain) constant returns (address collateralOwner) {
        bytes32 domainHash = sha3(ensDomain);
        var (_mode, _deedOwner, _timestamp, _value, _highestBid) = registrar.entries(domainHash);
        var _deedContract = Deed(_deedOwner);
        require(_deedContract.owner() == this);
        return _deedContract.previousOwner();
    }


    // CONSTRUCTOR
    function ENSCollateralManager() {
        address esnAddress = '0xb766772c58b098d8412143a473aed6bc41c95bde';
        address registrarAddress = '0xa5c650649b2a8e3f160035cee17b3c7e94b0805f';
        ens = AbstractENS(esnAddress);
        registrar = Registrar(registrarAddress);
    }

    function claimDeed(string _ensDomain) onlyCollateralOwner(_ensDomain) returns (bool) {
        bytes32 domainHash = sha3(_ensDomain);
      //TODO: check if there are any active loans in the ENS-loan-manager contract, if so, throw.
        registrar.transfer(domainHash, msg.sender);
        return true;
    }

    function escapeHatchClaimDeed(string ensDomain) onlyOwner returns (bool) {
        bytes32 domainHash = sha3(ensDomain);
        registrar.transfer(domainHash, owner);
        return true;
    }



}
