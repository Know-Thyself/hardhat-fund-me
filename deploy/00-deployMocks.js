const { network } = require("hardhat")
const {
	developmentChains,
	DECIMALS,
	INITIAL_PRICE,
} = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
	const { deploy, log } = deployments
	const { deployer } = await getNamedAccounts()
	// const chainId = network.config.chainId

	if (developmentChains.includes(network.name)) {
		log("Deploying mocks to local networks ...")
		await deploy("MockV3Aggregator", {
			contract: "MockV3Aggregator",
			from: deployer,
			log: true,
			args: [DECIMALS.toString(), INITIAL_PRICE.toString()],
		})

		log("Mocks deployed!")
		log("=============================================")
	}
}

module.exports.tags = ["all", "mocks"]
