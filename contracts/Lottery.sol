// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import "contracts/PriceConverter.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

error Lottery__EntryValueNotMet(address sender);
error Lottery__FundsNotTranfered(address winner, uint256 balance);
error Lottery__EntryFailed(address sender, uint256 value);

contract Lottery is VRFConsumerBaseV2, PriceConverter, AutomationCompatibleInterface {
  event EntrySuccessful(address sender);
  event RequestSent(uint256 requestId, uint256 numWords);
  event RequestFulfilled(uint256 requestId, uint256[] words);
  event WinnerFound(address winner);

  address[] s_listOfEntries;
  uint256 s_subscriptionId;
  VRFCoordinatorV2Interface I_COORDINATOR;
  bytes32 i_gasLane;
  address s_lastRoundWinner;
  uint256 public immutable i_interval;
  uint256 public s_lastTimeStamp;

  uint256 constant REQUEST_CONFIRMATIONS = 3;
  uint256 constant CALLBACK_GAS_LIMIT = 100000;
  uint256 constant NUM_WORDS = 2;

  constructor(
    address priceFeedAddress,
    uint256 entryValue,
    address _vrfCoordinator,
    uint256 subscriptionId,
    bytes32 gasLaneAddress,
    uint256 updateInterval
  ) VRFConsumerBaseV2(_vrfCoordinator) PriceConverter(priceFeedAddress, entryValue) {
    s_subscriptionId = subscriptionId;
    I_COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
    i_gasLane = gasLaneAddress;
    i_interval = updateInterval;
  }

  function performUpkeep(bytes calldata /* performData */) external override {
    if ((block.timestamp - s_lastTimeStamp) >= i_interval) {
      s_lastTimeStamp = block.timestamp;
      startWinnerPick();
    }
  }

  function checkUpkeep(
    bytes calldata /* checkData */
  ) external view override returns (bool upkeepNeeded, bytes memory) {
    upkeepNeeded = (block.timestamp - s_lastTimeStamp) > i_interval;
  }

  function enterLottery() public payable {
    bool isEntryValueMet = checkMinimumRequirement(msg.value);

    if (!isEntryValueMet) {
      revert Lottery__EntryValueNotMet(msg.sender);
    }

    (bool success, ) = payable(address(this)).call{value: msg.value}("");

    if (!success) {
      revert Lottery__EntryFailed(msg.sender, msg.value);
    }

    s_listOfEntries.push(msg.sender);
    emit EntrySuccessful(msg.sender);
  }

  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
    emit RequestFulfilled(_requestId, _randomWords);
    uint256 winnerIndex = (_randomWords[0] % s_listOfEntries.length) + 1;

    s_lastRoundWinner = s_listOfEntries[winnerIndex];
    emit WinnerFound(s_lastRoundWinner);

    transferFunds();
  }

  function startWinnerPick() internal {
    uint256 requestId = I_COORDINATOR.requestRandomWords(
      i_gasLane,
      uint64(s_subscriptionId),
      uint16(REQUEST_CONFIRMATIONS),
      uint32(CALLBACK_GAS_LIMIT),
      uint32(NUM_WORDS)
    );
    emit RequestSent(requestId, NUM_WORDS);
  }

  function transferFunds() private {
    (bool success, ) = payable(s_lastRoundWinner).call{value: address(this).balance}("");
    if (!success) {
      revert Lottery__FundsNotTranfered(s_lastRoundWinner, address(this).balance);
    }
  }
}
