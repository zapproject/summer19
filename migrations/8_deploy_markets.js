var MainMarket = artifacts.require('./MainMarket.sol');
var AuxiliaryMarket = artifacts.require('./AuxiliaryMarket.sol');
var ZapCoordinator = artifacts.require('./ZapCoordinator.sol');
const MainMarketToken = artifacts.require('./MainMarketToken.sol');
var coordInstance;

module.exports = async function(deployer) {
<<<<<<< HEAD
	coordInstance = await ZapCoordinator.deployed();
	await deployer.deploy(MainMarketToken);
	await deployer.deploy(AuxiliaryMarket);
	await deployer.deploy(MainMarket, ZapCoordinator.address);
	await coordInstance.addImmutableContract('MAINMARKET', MainMarket.address);
	await coordInstance.addImmutableContract('AUXMARKET', AuxiliaryMarket.address);
=======
  coordInstance = await ZapCoordinator.deployed();
  await deployer.deploy(MainMarketToken);
  await deployer.deploy(AuxiliaryMarket);
  await deployer.deploy(MainMarket, ZapCoordinator.address);
  await coordInstance.addImmutableContract('MAINMARKET', MainMarket.address);
  await coordInstance.addImmutableContract(
    'AUXMARKET',
    AuxiliaryMarket.address
  );
>>>>>>> cb95405b31c9cb1259912998faaff988328745b3
};
