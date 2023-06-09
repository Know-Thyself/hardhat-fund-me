const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
require("dotenv").config()

module.exports = async (hre) => {
	console.log("Deploying contract please wait...")
	const { getNamedAccounts, deployments } = hre
	const { deploy, log, get } = deployments
	const { deployer } = await getNamedAccounts()
	const chainId = network.config.chainId

	let ethUsdPriceFeedAddress
	if (developmentChains.includes(network.name)) {
		const ethUsdAggregator = await get("MockV3Aggregator")
		ethUsdPriceFeedAddress = ethUsdAggregator.address
	} else {
		ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
	}

	log("Deploying FundMe and waiting for confirmations...")

	const args = [ethUsdPriceFeedAddress]

	const fundMe = await deploy("FundMe", {
		from: deployer,
		args: args, // price feed address
		log: true,
		waitConfirmations: network.config.blockConfirmations || 1,
	})

	log(`FundMe deployed at ${fundMe.address}`)
	log("-------------------------------------------------------")

	if (
		!developmentChains.includes(network.name) &&
		process.env.ETHERSCAN_API_KEY
	) {
		await verify(fundMe.address, args)
	}
}

module.exports.tags = ["all", "fundme"]
