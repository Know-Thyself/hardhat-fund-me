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

	address[] public storeFunders;
	// mapping(address => uint256) public addressToAmountFunded;
	mapping(address => uint256) private storeAddressToAmountFunded;

	// immutable variables are also gas savers
	address public immutable immutableOwner;

	AggregatorV3Interface private storePriceFeed;

	modifier onlyOwner() {
		// require(msg.sender == immutableOwner, "Sender is not immutableOwner!");
		if (msg.sender != immutableOwner) revert FundMe__NotOwner();
		_; // running the rest of the code
	}

	constructor(address priceFeedAddress) {
		storePriceFeed = AggregatorV3Interface(priceFeedAddress);
		immutableOwner = msg.sender;
	}

	/**
	 *@notice This function funds contract
	 *@dev This contract implements price feeds as our library
	 */

	function fund() public payable {
		// Set minimum funding value in USD
		// How do we send ETH to this contract?
		require(
			msg.value.getConversionRate(storePriceFeed) >= MINIMUM_USD,
			"Insufficient amount. Please send more ether!"
		); // 1e18 == 1 * 10 ** 18 == 1000000000000000000
		storeAddressToAmountFunded[msg.sender] += msg.value;
		storeFunders.push(msg.sender);
	}

	// Withdraw funds
	function withdraw() public onlyOwner {
		for (
			uint256 funderIndex = 0;
			funderIndex < storeFunders.length;
			funderIndex++
		) {
			address funder = storeFunders[funderIndex];
			storeAddressToAmountFunded[funder] = 0;
		}
		storeFunders = new address[](0);

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

	function cheaperWithdraw() public onlyOwner {
		// address[] memory storeFunders = storeFunders;
		// mappings can't be in memory, sorry!
		for (
			uint256 funderIndex = 0;
			funderIndex < storeFunders.length;
			funderIndex++
		) {
			address funder = storeFunders[funderIndex];
			storeAddressToAmountFunded[funder] = 0;
		}
		storeFunders = new address[](0);
		// payable(msg.sender).transfer(address(this).balance);
		(bool success, ) = immutableOwner.call{value: address(this).balance}("");
		require(success);
	}

	function getAddressToAmountFunded(
		address fundingAddress
	) public view returns (uint256) {
		return storeAddressToAmountFunded[fundingAddress];
	}

	function getFunder(uint256 index) public view returns (address) {
		return storeFunders[index];
	}

	function getVersion() public view returns (uint256) {
		return storePriceFeed.version();
	}

	function getOwner() public view returns (address) {
		return immutableOwner;
	}

	function getPriceFeed() public view returns (AggregatorV3Interface) {
		return storePriceFeed;
	}

	receive() external payable {
		fund();
	}

	fallback() external payable {
		fund();
	}
}
