import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers"
// import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers:[
      {
        version:"0.8.4",
      },
      {
        version:"0.7.0",
      },
    ],
  },
};

export default config;
