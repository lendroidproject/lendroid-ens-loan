import React, { Component } from 'react'
import MarketContract from '../build/contracts/Market.json'
import getWeb3 from './utils/getWeb3'
// import ens from './utils/ensutils-testnet'

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
      ens: null,
      namehash: null,
      marketInstance: null,
      dailyInterestRate: null,
      ensName1: 'lendroid',
      ensName2: 'superstar'
    }

    this.handleEnsNameSubmit = this.handleEnsNameSubmit.bind(this);
    this.namehash = this.namehash.bind(this);
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

    // const market = contract(MarketContract)
    // market.setProvider(this.state.web3.currentProvider)

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {

      console.log('accounts');
      console.log(accounts);
      console.log('this.state.web3.version.network')
      console.log(this.state.web3.version.network)

      var market = this.state.web3.eth.contract(MarketContract['abi']).at('0x18Bb3E9fFa18F233564613e4Ed600966D0A122B3');
      console.log(market);
      // market.setProvider(this.state.web3.currentProvider);

      this.setState({
          userAccount: accounts[0],
          marketInstance: market,
      });
      
      var _that = this;
      // Populate state from Market deployment
      // market.deployed().then((instance) => {
      //   this.setState({
      //     marketInstance: instance,
      //     // ens: ens
      //   });
      //   // Get the Daily Interest Rate
      //   return this.state.marketInstance.getDailyInterestRate.call()
      // }).then((result) => {
      //   // Update state with the result.
      //   return this.setState({ dailyInterestRate: result.c[0] })
      // });
      return this.state.marketInstance.getDailyInterestRate.call()
    }).then((result) => {
      console.log(result);
      // Update state with the result.
      this.setState({ dailyInterestRate: result.c[0] })
    });
  }

  namehash(name) { var node = '0x0000000000000000000000000000000000000000000000000000000000000000'; if (name != '') { var labels = name.split("."); for(var i = labels.length - 1; i >= 0; i--) { node = this.state.web3.sha3(node + this.state.web3.sha3(labels[i]).slice(2), {encoding: 'hex'}); } } return node.toString(); }

  handleEnsNameSubmit(event) {
    console.log('this.ensNameInput: ' + this.ensNameInput.value+'.eth');
    var ensDomain = this.namehash(this.ensNameInput.value+'.eth');
    console.log('ensDomain: ' + ensDomain);
    // alert()
    // var owner = this.state.ens.owner(ensDomain),
    //     resolver = this.state.ens.resolver(ensDomain);
    // console.log('owner');
    // console.log(owner);
    // console.log('resolver');
    // console.log(resolver);
    console.log('this.state.userAccount');
    console.log(this.state.userAccount);
    event.preventDefault();
    // return false;
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

              <form onSubmit={this.handleEnsNameSubmit}>
                <label>
                  Your ENS domain name:
                  <input type="text" ref={(input) => this.ensNameInput = input} />
                </label>
                <input type="submit" value="Submit" />
              </form>

            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
