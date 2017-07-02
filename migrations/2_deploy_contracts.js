var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var Market = artifacts.require("./Market.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(Market);
};
