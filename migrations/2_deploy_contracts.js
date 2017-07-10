var ENSCollateralManager = artifacts.require("./ENSCollateralManager.sol");

module.exports = function(deployer) {
  deployer.deploy(ENSCollateralManager);
};
