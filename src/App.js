// Front-end components
import React, { Component } from 'react'
import Appbar from 'muicss/lib/react/appbar';
import Button from 'muicss/lib/react/button';
import Container from 'muicss/lib/react/container';
import Tabs from 'muicss/lib/react/tabs';
import Tab from 'muicss/lib/react/tab';
// Smart contracts
import MarketContract from '../build/contracts/Market.json'
import getWeb3 from './utils/getWeb3'
// Old CSS
import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'


class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      userAccount: null,
      web3: null,
      ens: null,
      marketInstance: null,
      dailyInterestRate: null,
      etherLocked: null,
      loanOffered: null,
      loanPeriod: null,
      isOwner: false
    }

    this.handleEnsNameSubmit = this.handleEnsNameSubmit.bind(this);
    this.handleRequestLoanSubmit = this.handleRequestLoanSubmit.bind(this);
    this.namehash = this.namehash.bind(this);
    this.onChange = this.onChange.bind(this);
    this.onActive = this.onActive.bind(this);
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

  onChange(i, value, tab, ev) {
    console.log(arguments);
  }

  onActive(tab) {
    console.log(arguments);
  }

  instantiateContract() {
    /*
     * SMART CONTRACT EXAMPLE
     *
     * Normally these functions would be called in the context of a
     * state management library, but for convenience I've placed them here.
     */

    this.state.web3.eth.getAccounts((error, accounts) => {

      var ensContract = this.state.web3.eth.contract([{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"resolver",outputs:[{name:"",type:"address"}],payable:!1,type:"function"},{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"owner",outputs:[{name:"",type:"address"}],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"label",type:"bytes32"},{name:"owner",type:"address"}],name:"setSubnodeOwner",outputs:[],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"ttl",type:"uint64"}],name:"setTTL",outputs:[],payable:!1,type:"function"},{constant:!0,inputs:[{name:"node",type:"bytes32"}],name:"ttl",outputs:[{name:"",type:"uint64"}],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"resolver",type:"address"}],name:"setResolver",outputs:[],payable:!1,type:"function"},{constant:!1,inputs:[{name:"node",type:"bytes32"},{name:"owner",type:"address"}],name:"setOwner",outputs:[],payable:!1,type:"function"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"owner",type:"address"}],name:"Transfer",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!0,name:"label",type:"bytes32"},{indexed:!1,name:"owner",type:"address"}],name:"NewOwner",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"resolver",type:"address"}],name:"NewResolver",type:"event"},{anonymous:!1,inputs:[{indexed:!0,name:"node",type:"bytes32"},{indexed:!1,name:"ttl",type:"uint64"}],name:"NewTTL",type:"event"}]),
          auctionContract = this.state.web3.eth.contract([{ "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "releaseDeed", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "getAllowedTime", "outputs": [ { "name": "timestamp", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "unhashedName", "type": "string" } ], "name": "invalidateName", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "hash", "type": "bytes32" }, { "name": "owner", "type": "address" }, { "name": "value", "type": "uint256" }, { "name": "salt", "type": "bytes32" } ], "name": "shaBid", "outputs": [ { "name": "sealedBid", "type": "bytes32" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "bidder", "type": "address" }, { "name": "seal", "type": "bytes32" } ], "name": "cancelBid", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "entries", "outputs": [ { "name": "", "type": "uint8" }, { "name": "", "type": "address" }, { "name": "", "type": "uint256" }, { "name": "", "type": "uint256" }, { "name": "", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "ens", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" }, { "name": "_value", "type": "uint256" }, { "name": "_salt", "type": "bytes32" } ], "name": "unsealBid", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "transferRegistrars", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" }, { "name": "", "type": "bytes32" } ], "name": "sealedBids", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "state", "outputs": [ { "name": "", "type": "uint8" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" }, { "name": "newOwner", "type": "address" } ], "name": "transfer", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_hash", "type": "bytes32" }, { "name": "_timestamp", "type": "uint256" } ], "name": "isAllowed", "outputs": [ { "name": "allowed", "type": "bool" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "finalizeAuction", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "registryStarted", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "sealedBid", "type": "bytes32" } ], "name": "newBid", "outputs": [], "payable": true, "type": "function" }, { "constant": false, "inputs": [ { "name": "labels", "type": "bytes32[]" } ], "name": "eraseNode", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hashes", "type": "bytes32[]" } ], "name": "startAuctions", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "hash", "type": "bytes32" }, { "name": "deed", "type": "address" }, { "name": "registrationDate", "type": "uint256" } ], "name": "acceptRegistrarTransfer", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "_hash", "type": "bytes32" } ], "name": "startAuction", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "rootNode", "outputs": [ { "name": "", "type": "bytes32" } ], "payable": false, "type": "function" }, { "constant": false, "inputs": [ { "name": "hashes", "type": "bytes32[]" }, { "name": "sealedBid", "type": "bytes32" } ], "name": "startAuctionsAndBid", "outputs": [], "payable": true, "type": "function" }, { "inputs": [ { "name": "_ens", "type": "address" }, { "name": "_rootNode", "type": "bytes32" }, { "name": "_startDate", "type": "uint256" } ], "payable": false, "type": "constructor" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": false, "name": "registrationDate", "type": "uint256" } ], "name": "AuctionStarted", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": true, "name": "bidder", "type": "address" }, { "indexed": false, "name": "deposit", "type": "uint256" } ], "name": "NewBid", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": true, "name": "owner", "type": "address" }, { "indexed": false, "name": "value", "type": "uint256" }, { "indexed": false, "name": "status", "type": "uint8" } ], "name": "BidRevealed", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": true, "name": "owner", "type": "address" }, { "indexed": false, "name": "value", "type": "uint256" }, { "indexed": false, "name": "registrationDate", "type": "uint256" } ], "name": "HashRegistered", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": false, "name": "value", "type": "uint256" } ], "name": "HashReleased", "type": "event" }, { "anonymous": false, "inputs": [ { "indexed": true, "name": "hash", "type": "bytes32" }, { "indexed": true, "name": "name", "type": "string" }, { "indexed": false, "name": "value", "type": "uint256" }, { "indexed": false, "name": "registrationDate", "type": "uint256" } ], "name": "HashInvalidated", "type": "event" } ]);

      this.setState({
          userAccount: accounts[0],
          marketInstance: this.state.web3.eth.contract(MarketContract['abi']).at('0x18Bb3E9fFa18F233564613e4Ed600966D0A122B3'),
          ens: ensContract.at('0xb766772c58b098d8412143a473aed6bc41c95bde'),
          ethRegistrar: auctionContract.at('0xa5c650649b2a8e3f160035cee17b3c7e94b0805f')
      });
      
      var _that = this;
      // Populate state from Market deployment
      this.state.marketInstance.getDailyInterestRate.call(function(err, result){
        if (err) {
          alert(err);
        }
        else {
          // Update state with the result.
          _that.setState({dailyInterestRate: result.c[0]})
        }
      });
      
    })
  }

  namehash(name) { var node = '0x0000000000000000000000000000000000000000000000000000000000000000'; if (name != '') { var labels = name.split("."); for(var i = labels.length - 1; i >= 0; i--) { node = this.state.web3.sha3(node + this.state.web3.sha3(labels[i]).slice(2), {encoding: 'hex'}); } } return node.toString(); }

  handleEnsNameSubmit(event) {
    var _that = this,
        ensDomain = _that.namehash(_that.ensNameInput.value);
    _that.state.ens.owner.call(ensDomain, function(err, result){
      if (err) {
        alert(err);
      }
      else {
        var value;
        // Populate state with Auction parameters
        _that.state.ethRegistrar.entries.call(_that.state.web3.sha3(ensDomain), function(err, result){
          console.log('result');
          console.log(result);
          value = _that.state.web3.fromWei(result[4], 'ether');
        });
        var loanAmount = (1 - (_that.state.dailyInterestRate * 0.01) ) * value,
            days = 30;
        _that.setState({
          isOwner: result === _that.state.userAccount,
          etherLocked: value,
          loanOffered: loanAmount,
          loanPeriod: days,
        })
        if (!_that.state.isOwner) {
          alert('It appears this domain does not belong to you. Please specify a domain that you own.')
          _that.ensNameInput.value = '';
          _that.setState({
            etherLocked: null,
            loanOffered: null,
            loanPeriod: null,
          })
        }
      }
    });
    event.preventDefault();
  }

  handleRequestLoanSubmit(event) {
    event.preventDefault();
  }

  render() {
    
    return (
      <div className="App">
        <Appbar></Appbar>
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Lendroid ENS Loans</a>
        </nav>
        <Tabs onChange={this.onChange} defaultSelectedIndex={1}>
          <Tab value="pane-1" label="Create Loan" onActive={this.onActive}>
            <Container>
              <div className="pure-g">
                <div className="pure-u-1-1">
                  <h2>{this.state.userAccount}</h2>
                  <form onSubmit={this.handleEnsNameSubmit}>
                    <label>
                      Your ENS domain name
                      <br />
                      <input type="text" placeholder="domainname.lendroid"ref={(input) => this.ensNameInput = input} />
                    </label>
                    <input type="submit" value="Confirm Domain name" />
                  </form>
                </div>
                <div className="pure-u-1-1 ensLoanContainer">
                  {this.state.isOwner === true &&
                    <form onSubmit={this.handleRequestLoanSubmit}>
                      <label>Ether Locked : {this.state.etherLocked}</label>
                      <label>Interest Rate : {this.state.dailyInterestRate}</label>
                      <label>Loan Amount Offered : {this.state.loanOffered}</label>
                      <label>Loan Period : {this.state.loanPeriod}</label>
                      <input type="submit" value="Request Loan" />
                    </form>
                  }
                </div>
              </div>
            </Container>
          </Tab>
          <Tab value="pane-2" label="Loan List">
            <Container>
              <div className="pure-g">
                <div className="pure-u-1-1">
                </div>
                <div className="pure-u-1-1 ensLoanContainer">
                  
                </div>
              </div>
            </Container>
          </Tab>
        </Tabs>
      </div>
    );
  }
}

export default App
