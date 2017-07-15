
function bid_for_names(list_of_names){

  for (var i=0; i<list_of_names.length; i++) {
    bid_for_name(list_of_names[i]);
  }

}

function reveal_bids(list_of_names){

  for (var i=0; i<list_of_names.length; i++) {
    reveal_bid(list_of_names[i]);
  }

}


function finalize_auctions(list_of_names){

  for (var i=0; i<list_of_names.length; i++) {
    finalize_auction(list_of_names[i]);
  }

}



function transfer_names(list_of_names,toAddress){

  for (var i=0; i<list_of_names.length; i++) {
    transfer_name(list_of_names[i],toAddress);
  }

}


function bid_for_name(name) {

  if (ethRegistrar.entries(web3.sha3(name))[0] == 0){
      console.log(ethRegistrar.startAuction(web3.sha3(name), {from: eth.accounts[0], gas: 100000}));
    var bid = ethRegistrar.shaBid(web3.sha3(name), eth.accounts[0], web3.toWei(0.01, 'ether'), web3.sha3('secret'));
    console.log(ethRegistrar.newBid(bid, {from: eth.accounts[0], value: web3.toWei(0.01, 'ether'), gas: 500000}));
  }
  else{
    console.log('Not available to buy');
  }
}


function reveal_bid(name){

  var auctionStatus = ethRegistrar.entries(web3.sha3(name))[0];

  if (auctionStatus == 4){
      console.log(ethRegistrar.unsealBid(web3.sha3(name), web3.toWei(0.01, 'ether'), web3.sha3('secret'), {from: eth.accounts[0], gas: 500000}));
  }

  else{
    console.log('not in reveal stage');

  }

}

function finalize_auction(name){

  if (ethRegistrar.entries(web3.sha3(name))[0] == 2){
      console.log(ethRegistrar.finalizeAuction(web3.sha3(name), {from: eth.accounts[0], gas: 500000}));

  }
  else{
    console.log('not ready to be finalized');
  }

}



function transfer_name(name,toAddress){

  if (ethRegistrar.entries(web3.sha3(name))[0] == 2){
    console.log(ethRegistrar.transfer(web3.sha3(name), toAddress, {from: eth.accounts[0]}));

  }
  else{
    console.log('not ready to be transfered');
  }

}
