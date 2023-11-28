import { HardhatRuntimeEnvironment } from "hardhat/types";
import { MockV3AggregatorSettings } from "../utils";

module.exports = async ({
  getNamedAccounts,
  deployments,
}: HardhatRuntimeEnvironment) => {
  const { deployer } = await getNamedAccounts();

  if (!deployer) {
    throw Error("There is no deployer account!");
  }

  await deployments.deploy("MockV3Aggregator", {
    from: deployer,
    args: [
      MockV3AggregatorSettings._decimals,
      MockV3AggregatorSettings._initialAnswer,
    ],
    log: true,
  });

  
};
