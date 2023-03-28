// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
// Importing directly from github what is known as npm package
import '@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol';

library PriceConverter {
	function getPrice(
		AggregatorV3Interface priceFeed
	) internal view returns (uint256) {
		// ABI
		// Address --> 0x694AA1769357215DE4FAC081bf1f309aDC325306
		// AggregatorV3Interface priceFeed = AggregatorV3Interface(
		// 	0x694AA1769357215DE4FAC081bf1f309aDC325306
		// );
		(, int price, , , ) = priceFeed.latestRoundData();
		return uint256(price * 1e10); // 1**10 == 10000000000
	}

	// function getVersion() internal view returns (uint256) {
	// 	AggregatorV3Interface priceFeed = AggregatorV3Interface(
	// 		0x694AA1769357215DE4FAC081bf1f309aDC325306
	// 	);
	// 	return priceFeed.version();
	// }

	function getConversionRate(
		uint256 ethAmount,
		AggregatorV3Interface priceFeed
	) internal view returns (uint256) {
		uint256 ethPrice = getPrice(priceFeed);
		uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
		return ethAmountInUsd;
	}
}
