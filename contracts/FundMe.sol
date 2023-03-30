// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./PriceConverter.sol";

error FundMe__NotOwner();

/**
 *@title A contract for crowd funding
 *@author Biruk Kebede
 *@notice This contract is a demo of sample contract
 *@dev This contract implements price feeds as our library
 */
contract FundMe {
	// Type declarations first
	using PriceConverter for uint256;
	// Get funds from users
	// constant variable naming convention --> cheeper gas price to read from
	uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18

	address[] public funders;
	mapping(address => uint256) public addressToAmountFunded;

	// immutable variables are also gas savers
	address public immutable owner;

	AggregatorV3Interface public priceFeed;

	modifier onlyOwner() {
		// require(msg.sender == owner, "Sender is not owner!");
		if (msg.sender != owner) {
			revert FundMe__NotOwner();
		}
		_; // running the rest of the code
	}

	constructor(address priceFeedAddress) {
		priceFeed = AggregatorV3Interface(priceFeedAddress);
		owner = msg.sender;
	}

	/**
	 *@notice This function funds contract
	 *@dev This contract implements price feeds as our library
	 */

	function fund() public payable {
		// Set minimum funding value in USD
		// How do we send ETH to this contract?
		require(
			msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
			"Insufficient amount. Please send more ether!"
		); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
		funders.push(msg.sender);
		addressToAmountFunded[msg.sender] = msg.value;
	}

	// Withdraw funds
	function withdraw() public onlyOwner {
		for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
			address funder = funders[funderIndex];
			addressToAmountFunded[funder] = 0;
		}
		funders = new address[](0);

		// payable (msg.sender) --> payable address
		// transfer
		payable(msg.sender).transfer(address(this).balance);
		// send
		// bool sendSuccess = payable(msg.sender).send(address(this).balance);
		// require(sendSuccess, "Failed to send");
		// call
		(bool callSuccess, ) = payable(msg.sender).call{
			value: address(this).balance
		}("");
		require(callSuccess, "Call failed");
	}

	receive() external payable {
		fund();
	}

	fallback() external payable {
		fund();
	}
}
