var ENSKovanFaucet = artifacts.require("./ENSKovanFaucet.sol");

contract('ENSKovanFaucet', function(accounts) {
  //console.log(accounts);
  
  it("should prevent double transfer of a domain", function(){
    var faucet;
    var user1 = accounts[0],
     user2 = accounts[1];
     // instance = ENSKovanF8aucet.deployed()
     // domain = instance.domainOwners.call(user1)
     // instance.transferDomain.sendTransaction({from: user1, gasPrice: 2000000000})
    return ENSKovanFaucet.deployed().then(function(instance) {
      faucet = instance;
      return faucet.domainOwners.call(user1);
    }).then(function(domain) {
      // user1 should not have been assigned a domain initially
      assert.equal(domain.valueOf(), "0x0000000000000000000000000000000000000000000000000000000000000000", "user already has a domain");
      // return faucet.transferDomain.sendTransaction({from: user1, gasPrice: 2000000000})
    }).then(function(result){
      //console.log(result);
    });
  });

  it("should check that domains are saved correctly", function(){
    var faucet;
    var owner = accounts[0],
     user1 = accounts[1], 
     user2 = accounts[2];
    var domain1 = "facebook", domain2 = "twitter";

    return ENSKovanFaucet.new({from: owner}).then(function(instance) {
      faucet = instance;
      return faucet.domains.call(domain1, {from: user1});
    }).then(function(domain) {
      assert.equal(domain[2].valueOf(), 0, "timestamp is not zero");
      return faucet.saveDomains.sendTransaction([domain1],["Hash1"],{from: owner})
    }).then(function(result){
       return faucet.domains.call(domain1, {from: user2});
    }).then(function(domain){
      assert.notEqual(domain[2].valueOf(), 0, "timestamp is zero");
    });
  });

  it("should check that saveDomains() returns error for unequal array lengths", function(){
    var faucet;
    var owner = accounts[0],
    user1 = accounts[1];
    
    var domain1 = "facebook", domain2 = "twitter";

    return ENSKovanFaucet.new({from: owner}).then(function(instance) {
      return instance.saveDomains.sendTransaction([domain1,domain2],["Hash1"],{from: owner})
    }).catch(function(error){
      assert.equal(error.message,"VM Exception while processing transaction: invalid opcode","saveDomains() ran successfully");
    });
  });

  it("should check that saveDomains() is atomic", function(){
    var faucet;
    var owner = accounts[0],
    user1 = accounts[1];
    
    var domain1 = "facebook", domain2 = 2;

    return ENSKovanFaucet.new({from: owner}).then(function(instance) {
      faucet = instance;
      return faucet.saveDomains.sendTransaction([domain1,domain2],["Hash1","Hash2"],{from: owner})
    }).catch(function(error){
      assert.equal(error.message,"VM Exception while processing transaction: invalid opcode","saveDomains() ran successfully");
    }).then(function(){
      return faucet.domains.call(domain1, {from: user1})
    }).then(function(domain){
      assert.equal(domain[2].valueOf(), 0, "timestamp is not zero");
    });
  });
});