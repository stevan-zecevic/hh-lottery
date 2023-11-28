// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConverter {
    AggregatorV3Interface internal priceFeed;
    uint256 minimumEntryValue;

    constructor(address priceFeedAddress, uint256 entryValue) {
        priceFeed = AggregatorV3Interface(priceFeedAddress);
        minimumEntryValue = entryValue;
    }

    function checkMinimumRequirement(
        uint256 value
    ) internal view returns (bool) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();

        uint256 priceOfUSD = (1e18 * 10 ** decimals) / uint256(answer);

        return value / priceOfUSD > minimumEntryValue;
    }
}
