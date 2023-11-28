import { HardhatRuntimeEnvironment } from "hardhat/types";

module.exports = async ({
  getNamedAccounts,
  deployments,
}: HardhatRuntimeEnvironment) => {
  const { deployer } = await getNamedAccounts();

  if (!deployer) {
    throw Error("There is no deployer account!");
  }

  const lottery = await deployments.deploy("Lottery", {
    from: deployer,
    args: [
      // address priceFeedAddress,
      // uint256 entryValue,
      // address _vrfCoordinator,
      // uint256 subscriptionId,
      // bytes32 gasLaneAddress,
      // uint256 updateInterval
    ],
    waitConfirmations: 1,
    log: true,
  });

  console.log("Lottery", lottery);
};
