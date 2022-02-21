const DebondPair = artifacts.require("DebondPair");

module.exports = function (deployer) {
  deployer.deploy(DebondPair);
};