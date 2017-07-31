pragma solidity ^0.4.11;

import './Ownable.sol';
import './HashRegistrarSimplified.sol';


/**
    @title ENSKovanFaucet
    @notice The ENSKovanFaucet contract inherits the Ownable contract, and
        manages ENS domains for the Demo version.
    @dev The contract has references to the following external contracts:
        1. Registrar Contract from ENS - To verify and transfer domain ownership
        2. LoanManager Contract - To interact with this contract while (un) / encumbering
           a deed
        The contract works as follows:
        1. Managing the domains.
*/
contract ENSKovanFaucet is Ownable {

    AbstractENS public ens;
    Registrar public registrar;
    
    enum Status {
        NOTTRANSFERRED,
        TRANSFERRED
    }

    struct Domain {
        bytes32 ensDomainHash;
        bytes32 ensDomainName;
        uint256 timestamp;
        address transferredTo;
        Status status;
    }
    
    bytes32[] unTransferredDomains;
    
    mapping (bytes32 => Domain) public domains;
    mapping(address=>bytes32) public domainOwners;
    
    event DomainTransferred(bytes32 ensDomainHash, bytes32 ensDomainName, address toAddress);

    /**
        @notice The ENSKovanFaucet constructor sets the ENS Registrar address.
    */
    function ENSKovanFaucet() {
        address _ensAddress = 0xdE52AE305894282Ca2FF776eF7f2a926650ff35A;
        address _registrarAddress = 0x2D3bad1448b1d1e761F0AD5aC7B516fF861Af944;
        ens = AbstractENS(_ensAddress);
        registrar = Registrar(_registrarAddress);
    }

    /**
        @notice Transfers the domain to message sender.
    */
    function transferDomain() returns (bool) {
        Domain storage domain = domains[_unTransferredDomain()];
        // Call ENS to transfer the ownership of the domain
        registrar.transfer(domain.ensDomainHash, msg.sender);
        // Update the domain data
        domain.transferredTo = msg.sender;
        domain.status = Status.TRANSFERRED;
        domain.timestamp = now;
        // Set message sender as a domain owner
        domainOwners[msg.sender] = domain.ensDomainName;
        DomainTransferred(domain.ensDomainHash, domain.ensDomainName, msg.sender);
        return true;
    }

    /**
        @notice Private function that returns a domain name that has not been 
        transferred yet.
    */
    function _unTransferredDomain() internal returns (bytes32 _domainName) {
        assert(unTransferredDomains.length > 0);
        _domainName = unTransferredDomains[unTransferredDomains.length - 1];
        unTransferredDomains.length --;
    }
    
    /**
        @notice Save a new Domain. Add the domain name to the array of untransferred
        domains.
    */
    function saveDomains(bytes32[] ensDomainNames, bytes32[] ensDomainHashes) onlyOwner returns (bool) {
        assert(ensDomainNames.length == ensDomainHashes.length);
        for (uint256 i = 0; i < ensDomainNames.length; i++) {
            // Save a new domain struct based on the domain name
            Domain memory domain;
            domain.ensDomainName = ensDomainNames[i];
            domain.ensDomainHash = ensDomainHashes[i];
            domain.status = Status.NOTTRANSFERRED;
            domain.timestamp = now;
            domains[ensDomainNames[i]] = domain;
            // Push the domain name to the untransferred domains array
            unTransferredDomains.push(ensDomainNames[i]);
        }
        
        return true;
    }
    
    /**
        @notice Escape hatch function that allows the contract to transfer a domain to the given
            owner address.
        @dev This is a failsafe mechanism to handle use-cases when domains are locked under unexpected
            circumstances.
        @param _ensDomainHash sha of the ENS domain
        @return true an acknowledgement that the ENS domain was transferred to the owner's address
    */
    function escapeHatchClaimDeed(bytes32 _ensDomainHash) onlyOwner returns (bool) {
        registrar.transfer(_ensDomainHash, owner);
        return true;
    }

}
