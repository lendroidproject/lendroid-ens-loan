var ENSCollateralManager = artifacts.require("./ENSCollateralManager.sol");
var ENSKovanFaucet = artifacts.require("./ENSKovanFaucet.sol");
var ENSLoanManager = artifacts.require("./ENSLoanManager.sol");

module.exports = function(deployer) {
  deployer.deploy(ENSCollateralManager);
  deployer.deploy(ENSKovanFaucet);
  deployer.deploy(ENSLoanManager);
};
