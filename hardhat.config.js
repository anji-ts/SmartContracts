require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.6",

  gasReporter:{
    enabled:true,
    currency:"INR",
    noColors:true,
    outputFile:"gasReport.txt",
    coinmarketcap:"39d7e2e4-7574-4986-8f8b-1525653e01a4",
    token:"matic",
  }
};
