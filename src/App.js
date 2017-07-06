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
      console.log('getWeb3 results')
      console.log(results)
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

    this.state.web3.eth.getAccounts((error, accounts) => {

      console.log('accounts');
      console.log(accounts);
      console.log('this.state.web3.version.network')
      console.log(this.state.web3.version.network)

      var ensContract=this.state.web3.eth.contract([{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"resolver",outputs:[{name:"",type:"address"}],payable:!1,type:"function"},{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"owner",outputs:[{name:"",type:"address"}],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"label",type:"bytes32"},{name:"owner",type:"address"}],name:"setSubnodeOwner",outputs:[],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"ttl",type:"uint64"}],name:"setTTL",outputs:[],payable:!1,type:"function"},{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"ttl",outputs:[{name:"",type:"uint64"}],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"resolver",type:"address"}],name:"setResolver",outputs:[],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"owner",type:"address"}],name:"setOwner",outputs:[],payable:!1,type:"function"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"owner",type:"address"}],name:"Transfer",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!0,name:"label",type:"bytes32"},{indexed:!1,name:"owner",type:"address"}],name:"NewOwner",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"resolver",type:"address"}],name:"NewResolver",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"ttl",type:"uint64"}],name:"NewTTL",type:"event"}]);

      this.setState({
          userAccount: accounts[0],
          marketInstance: this.state.web3.eth.contract(MarketContract['abi']).at('0x18Bb3E9fFa18F233564613e4Ed600966D0A122B3'),
          ens: ensContract.at('0x112234455c3a32fd11230c42e7bccd4a84e02010')
      });
      
      var _that = this;
      console.log(_that.state.marketInstance);
      // Populate state from Market deployment
      this.state.marketInstance.getDailyInterestRate.call(function(err, result){
        if (err) {
          alert(err);
        }
        else {
          console.log(result);
          console.log(err);
          // Update state with the result.
          _that.setState({ dailyInterestRate: result.c[0] })
        }
      });
      
    })
  }

  namehash(name) { var node = '0x0000000000000000000000000000000000000000000000000000000000000000'; if (name != '') { var labels = name.split("."); for(var i = labels.length - 1; i >= 0; i--) { node = this.state.web3.sha3(node + this.state.web3.sha3(labels[i]).slice(2), {encoding: 'hex'}); } } return node.toString(); }

  handleEnsNameSubmit(event) {
    var _that = this;
    console.log('this.ensNameInput: ' + _that.ensNameInput.value+'.test');
    var ensDomain = _that.namehash(_that.ensNameInput.value+'.test');
    console.log('ensDomain: ' + ensDomain);
    _that.state.ens.owner.call(ensDomain, function(err, result){
      if (err) {
        alert(err);
      }
      else {
        if (result !== _that.state.userAccount) {
          alert('It appears this domain does not belong to you. Please specify a domain that you own.')
          _that.ensNameInput.value = '';
        }
      }
    });
    event.preventDefault();
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
