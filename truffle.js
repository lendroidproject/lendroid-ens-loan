// var bip39 = require("bip39");
// var hdkey = require('ethereumjs-wallet/hdkey');
// var ProviderEngine = require("web3-provider-engine");
// var WalletSubprovider = require('web3-provider-engine/subproviders/wallet.js');
// var Web3Subprovider = require("web3-provider-engine/subproviders/web3.js");
// var Web3 = require("web3");

// // Get our mnemonic and create an hdwallet
// var mnemonic = "couch potato unique spirit wine fine occur rhythm foot feature glory away";
// var hdwallet = hdkey.fromMasterSeed(bip39.mnemonicToSeed(mnemonic));

// // Get the first account using the standard hd path.
// var wallet_hdpath = "m/44'/60'/0'/0/";
// var wallet = hdwallet.derivePath(wallet_hdpath + "0").getWallet();
// var address = "0x" + wallet.getAddress().toString("hex");
// console.log('address from truffle.js')
// console.log(address)

// var providerUrl = "https://ropsten.infura.io/Jf3Y5a2i3RMqIYN9MzSV";
// var engine = new ProviderEngine();
// engine.addProvider(new WalletSubprovider(wallet, {}));
// engine.addProvider(new Web3Subprovider(new Web3.providers.HttpProvider(providerUrl)));
// engine.start(); // Required by the provider engine.


module.exports = {
  migrations_directory: "./migrations",
  networks: {
    // 'ropsten': {
    //   provider: engine,
    //   from: address,
    //   network_id: 3
    // },
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    // 'infura': {
    //   host: "https://ropsten.infura.io/Jf3Y5a2i3RMqIYN9MzSV",
    //   provider: engine,
    //   from: address,
    //   network_id: 3,
    //   gas: 3000000
    // }
  }
};
