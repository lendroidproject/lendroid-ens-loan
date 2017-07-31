



function generate_ens_names(ens_name){
  var list_of_generated_names = [];
  for  (i = 1; i <= 10; i++)  {
    list_of_generated_names.push(ens_name + i);
  }
  return list_of_generated_names;
}

function generate_ens_sha3(list_of_names){
  var list_of_hashed_names = [];
  for (var i=0; i<list_of_names.length; i++) {
    list_of_hashed_names.push(web3.sha3(list_of_names[i]));
  }
  return list_of_hashed_names;
}


function start_auction_for_names(list_of_names){

  for (var i=0; i<list_of_names.length; i++) {
    start_auction(list_of_names[i]);
  }

}


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

function get_status(list_of_names){

  for (var i=0; i<list_of_names.length; i++) {
    console.log(ethRegistrar.entries(web3.sha3(list_of_names[i])));
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

function save_names_in_faucet(list_of_names){
  console.log(ens_faucet.saveDomains(list_of_names, generate_ens_sha3(list_of_names), {from: eth.accounts[1]}));
}




function start_auction(name) {

  if (ethRegistrar.entries(web3.sha3(name))[0] == 0){
      console.log(ethRegistrar.startAuction(web3.sha3(name), {from: eth.accounts[1], gas: 100000}));
  }
  else{
    console.log('Not available to buy');
  }
}


function bid_for_name(name) {

  if (ethRegistrar.entries(web3.sha3(name))[0] == 1){
    var bid = ethRegistrar.shaBid(web3.sha3(name), eth.accounts[1], web3.toWei(0.01, 'ether'), web3.sha3('secret'));
    console.log(ethRegistrar.newBid(bid, {from: eth.accounts[1], value: web3.toWei(0.01, 'ether'), gas: 1000000}));
  }
  else{
    console.log('Not available to buy');
  }
}


function reveal_bid(name){

  var auctionStatus = ethRegistrar.entries(web3.sha3(name))[0];

  if (auctionStatus == 4){
      console.log(ethRegistrar.unsealBid(web3.sha3(name), web3.toWei(0.01, 'ether'), web3.sha3('secret'), {from: eth.accounts[1], gas: 500000}));
  }

  else{
    console.log('not in reveal stage');

  }

}

function finalize_auction(name){

  if (ethRegistrar.entries(web3.sha3(name))[0] == 2){
      console.log(ethRegistrar.finalizeAuction(web3.sha3(name), {from: eth.accounts[1], gas: 500000}));

  }
  else{
    console.log('not ready to be finalized');
  }

}



function transfer_name(name,toAddress){

  if (ethRegistrar.entries(web3.sha3(name))[0] == 2){
    console.log(ethRegistrar.transfer(web3.sha3(name), toAddress, {from: eth.accounts[1]}));

  }
  else{
    console.log('not ready to be transfered');
  }

}
