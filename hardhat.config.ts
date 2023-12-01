import { HardhatUserConfig } from "hardhat/types";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
import "tsconfig-paths/register";
import "@nomicfoundation/hardhat-ethers";
import "hardhat-deploy";
import '@typechain/hardhat'
import '@nomicfoundation/hardhat-ethers'
import '@nomicfoundation/hardhat-chai-matchers'

import { env } from "env";

if (!env.SEPOLIA_PRIVATE_KEY) {
  throw new Error("There is no private key for sepolia!");
}

if (!env.SEPOLIA_RPC_URL) {
  throw new Error("There is no rpc url for sepolia!");
}

if (!env.ETHERSCAN_API_KEY) {
  throw new Error("There is no etherscan key!");
}

if (!env.COINMARKETCAP_API_KEY) {
  console.log("There is no coinmarketcap key!");
}

const config: HardhatUserConfig = {
  solidity: { compilers: [{ version: "0.8.22" }, {version:"0.8.0" }]},
  // paths: {
  //   sources: "./contracts",
  //   tests: "./contracts/test",
  // },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
    },
    sepolia: {
      url: env.SEPOLIA_RPC_URL,
      accounts: [env.SEPOLIA_PRIVATE_KEY],
      saveDeployments: true,
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: env.ETHERSCAN_API_KEY,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    player: {
      default: 1
    },
  },
  gasReporter: {
    coinmarketcap: env.COINMARKETCAP_API_KEY,
    enabled: true,
    noColors: true,
    currency: "EUR",
    outputFile: "gas-report.txt",
    token: "ETH",
  },
};

export default config;
