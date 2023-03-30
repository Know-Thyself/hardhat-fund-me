const { assert, expect } = require("chai")
// const { deployments, ethers, getNamedAccounts } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")
const { network, deployments, ethers } = require("hardhat")

!developmentChains.includes(network.name)
	? describe.skip
	: describe("FundMe", function () {
			let fundMe, deployer, mockV3Aggregator
			beforeEach(async function () {
				// const { deployer } = await getNamedAccounts()
				deployer = (await getNamedAccounts()).deployer
				// const accounts = await ethers.getSigners()
				// const firstAccount = accounts[0]
				await deployments.fixture(["all"])
				fundMe = await ethers.getContract("FundMe", deployer)
				mockV3Aggregator = await ethers.getContract(
					"MockV3Aggregator",
					deployer
				)
			})

			describe("constructor", async function () {
				it("Should set the aggregator addresses correctly", async () => {
					const response = await fundMe.priceFeed()
					assert.equal(response, mockV3Aggregator.address)
				})
			})

			describe("fund", async function () {
				it("Fails if you do not send enough ETH", async function () {
					await expect(fundMe.fund()).to.be.revertedWith(
						"Insufficient amount. Please send more ether!"
					)
				})
			})
	  })
