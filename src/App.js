import React, { Component } from 'react'
import MarketContract from '../build/contracts/Market.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'



class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      userAccount: null,
      ENSRootAddress: null,
      ENSRegistrarAddress: null,
      storageValue: 0,
      web3: null,
      marketInstance: null,
      dailyInterestRate: null,
      ensName1: 'lendroid',
      ensName2: 'superstar'
    }
  }

  componentWillMount() {

    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {
    /*
     * SMART CONTRACT EXAMPLE
     *
     * Normally these functions would be called in the context of a
     * state management library, but for convenience I've placed them here.
     */

    const contract = require('truffle-contract');



    console.log('test');

    console.log('test2 ');


    const market = contract(MarketContract)
    market.setProvider(this.state.web3.currentProvider)

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {

      this.state.userAccount = accounts[0];
      var _that = this;

      // Deploy ENS
      var ensContract = this.state.web3.eth.contract([{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"resolver","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"label","type":"bytes32"},{"name":"owner","type":"address"}],"name":"setSubnodeOwner","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"ttl","type":"uint64"}],"name":"setTTL","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"node","type":"bytes32"}],"name":"ttl","outputs":[{"name":"","type":"uint64"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"resolver","type":"address"}],"name":"setResolver","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"node","type":"bytes32"},{"name":"owner","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"owner","type":"address"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":true,"name":"label","type":"bytes32"},{"indexed":false,"name":"owner","type":"address"}],"name":"NewOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"resolver","type":"address"}],"name":"NewResolver","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"node","type":"bytes32"},{"indexed":false,"name":"ttl","type":"uint64"}],"name":"NewTTL","type":"event"}]);
      var ens = ensContract.new({
          from: this.state.userAccount,
          data:"0x33600060000155610220806100146000396000f3630178b8bf60e060020a600035041415610023576020600435015460405260206040f35b6302571be360e060020a600035041415610047576000600435015460405260206040f35b6316a25cbd60e060020a60003504141561006b576040600435015460405260206040f35b635b0fc9c360e060020a6000350414156100b8576000600435015433141515610092576002565b6024356000600435015560243560405260043560198061020760003960002060206040a2005b6306ab592360e060020a6000350414156101165760006004350154331415156100df576002565b6044356000600435600052602435602052604060002001556044356040526024356004356021806101e660003960002060206040a3005b631896f70a60e060020a60003504141561016357600060043501543314151561013d576002565b60243560206004350155602435604052600435601c806101ca60003960002060206040a2005b6314ab903860e060020a6000350414156101b057600060043501543314151561018a576002565b602435604060043501556024356040526004356016806101b460003960002060206040a2005b6002564e657754544c28627974657333322c75696e743634294e65775265736f6c76657228627974657333322c61646472657373294e65774f776e657228627974657333322c627974657333322c61646472657373295472616e7366657228627974657333322c6164647265737329",
          gas: 4700000
      }, function (e, contract){
          console.log(e, contract);
          if (typeof contract.address !== 'undefined') {
              console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
              _that.state.ENSRootAddress = contract.address;
              // Regitrar contract

              var fifsRegistrarContract = _that.state.web3.eth.contract([ { "constant": true, "inputs": [], "name": "ens", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "bytes32" } ], "name": "expiryTimes", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "subnode", "type": "bytes32" }, { "name": "owner", "type": "address" } ], "name": "register", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "rootNode", "outputs": [ { "name": "", "type": "bytes32" } ], "payable": false, "type": "function" }, { "inputs": [ { "name": "ensAddr", "type": "address" }, { "name": "node", "type": "bytes32" } ], "type": "constructor" } ]);

              //var registrarContract = _that.state.web3.eth.contract([{"constant":false,"inputs":[{"name":"subnode","type":"bytes32"},{"name":"owner","type":"address"}],"name":"register","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"ensAddr","type":"address"},{"name":"node","type":"bytes32"}, {"name": "_startDate", "type": "uint256"}],"type":"constructor"}]);

              var registrarContract = _that.state.web3.eth.contract([{"constant":false,"inputs":[{"name":"subnode","type":"bytes32"},{"name":"owner","type":"address"}],"name":"register","outputs":[],"payable":false,"type":"function"},{"inputs":[{"name":"ensAddr","type":"address"},{"name":"node","type":"bytes32"}, {"name": "_startDate", "type": "uint256"}],"type":"constructor"}]);
              var registrar = registrarContract.new(
                  ens.address,
                  0,
                  0,
                  {from: _that.state.web3.eth.accounts[0],
                  data: "0x60606040818152806101c4833960a0905251608051600080546c0100000000000000000000000080850204600160a060020a0319909116179055600181905550506101768061004e6000396000f3606060405260e060020a6000350463d22057a9811461001e575b610002565b34610002576100f4600435602435600154604080519182526020808301859052815192839003820183206000805494830181905283517f02571be3000000000000000000000000000000000000000000000000000000008152600481018390529351879592949193600160a060020a03909316926302571be3926024808201939182900301818787803b156100025760325a03f11561000257505060405151915050600160a060020a038116158015906100ea575033600160a060020a031681600160a060020a031614155b156100f657610002565b005b60008054600154604080517f06ab5923000000000000000000000000000000000000000000000000000000008152600481019290925260248201899052600160a060020a03888116604484015290519216926306ab59239260648084019382900301818387803b156100025760325a03f11561000257505050505050505056",
                  gas: 4700000
              }, function (e, contract){
                  console.log(e, contract);
                  if (typeof contract.address !== 'undefined') {
                      console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
                      _that.state.ENSRegistrarAddress = contract.address;
                      // Transfer ownership of root ENS node to Registrar
                      ens.setOwner(0, registrar.address, {from: _that.state.userAccount});
                      // Instantiate FIFS Registrar

                      console.log(ensContract);
                      console.log(fifsRegistrarContract);
                      console.log(registrar.address);
                      var testRegistrar = fifsRegistrarContract.at(registrar.address);
                      console.log(testRegistrar);
                      console.log(_that.state.web3.sha3(_that.state.ensName1));
                      console.log(testRegistrar.expiryTimes(_that.state.web3.sha3(_that.state.ensName1)));
                      console.log();
                      console.log('Check that name is not owned by anybody');
                      // // Check that name is not owned by anybody

                      var registeredDate = new Date(testRegistrar.expiryTimes(_that.state.web3.sha3(_that.state.ensName1)).toNumber() * 1000)
                      console.log('registeredDate: ' + registeredDate);
                  }
              });
          }
      });

      // Populate state from Market deployment
      market.deployed().then((instance) => {
        this.setState({marketInstance: instance});
        // Get the Daily Interest Rate
        return this.state.marketInstance.getDailyInterestRate.call(this.state.userAccount)
      }).then((result) => {
        // Update state with the result.
        this.setState({ dailyInterestRate: result.c[0] })
        return this.state.marketInstance.getDefaultMaxLoanDuration.call(this.state.userAccount)
      });
    })
  }

  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Lendroid ENS Loans</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>Good to Go!</h1>
              <p>Your Truffle Box is installed and ready.</p>
              <h2>Smart Contract Example</h2>
              <p>If your contracts compiled and migrated successfully, below will show a stored value of 5 (by default).</p>
              <p>Try changing the value stored on <strong>line 59</strong> of App.js.</p>
              <p>The current interest rate is: {this.state.dailyInterestRate}</p>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
