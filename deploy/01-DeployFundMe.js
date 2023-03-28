const { network } = require("hardhat")
const { networkConfig } = require("../helper-hardhat-config")

module.exports = async (hre) => {
	console.log("Hi! Deploying...")
	const { getNamedAccounts, deployments } = hre
	const { deploy, log } = deployments
	const { deployer } = await getNamedAccounts()
	const chainId = network.config.chainId

	const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]

	const fundMe = await deploy("FundMe", {
		from: deployer,
		args: [], // price feed address
		log: true,
	})
}

