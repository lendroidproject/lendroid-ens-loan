
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
      network_id: "155" // Match any network id
    },
  }
};
