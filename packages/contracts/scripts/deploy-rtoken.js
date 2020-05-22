/**
 * @dev Interactive script to deploy a fullset of rtoken contracts
 */
module.exports = async function (callback) {
    try {
        const { promisify } = require("util");
        const rl = require("./common/rl");
        const { web3tx } = require("@decentral.ee/web3-test-helpers");

        global.web3 = web3;

        const CompoundAllocationStrategy = artifacts.require("CompoundAllocationStrategy");
        const RToken = artifacts.require("RToken");
        const Proxy = artifacts.require("Proxy");

        let newRtokenName = await promisify(rl.question)("Provide RToken Name/Description: ");
        let newRtokenSymbol = await promisify(rl.question)("Provide RToken Symbol: ");
        let newRtokenDecimals = await promisify(rl.question)("Provide RToken Decimals (Should be equal to underlying Erc20 decimals): ");
        let cTokenAddress = await promisify(rl.question)("Provide cToken Address: ");

        if (!newRtokenName || !newRtokenSymbol || !cTokenAddress || !newRtokenDecimals) {
            console.log("Invalid Input!!! Returning");
            callback();
        }

        // Deploy compound's allocation strategy
        let compoundAS = await web3tx(
            CompoundAllocationStrategy.new,
            `CompoundAllocationStrategy.new cToken ${cTokenAddress}`)(
            cTokenAddress
        );
        console.log("compoundAllocationStrategy deployed at: ", compoundAS.address);

        // Deploy RToken logic/implementation
        let rToken = await web3tx(RToken.new, "rToken.new")();
        console.log(`rToken (${newRtokenSymbol}) deployed at: `, rToken.address);

        // Deploy RToken itself as proxy
        const rTokenConstructCode = rToken.contract.methods.initialize(compoundAS.address, newRtokenName, newRtokenSymbol, newRtokenDecimals)
            .encodeABI();
        console.log(`rTokenConstructCode rToken.initialize(${rTokenConstructCode})`);
        const proxy = await web3tx(Proxy.new, "Proxy.new")(
            rTokenConstructCode, rToken.address
        );
        console.log(`${newRtokenSymbol} proxy deployed at: ${proxy.address} at Block Number: ${proxy.receipt.blockNumber}`);

        // transfer ownership of compoundAS from admin to new rToken proxy
        console.log(`transfer ownership of compoundAS to new rToken(${newRtokenSymbol} proxy)`, proxy.address);
        await web3tx(compoundAS.transferOwnership, "compoundAS.transferOwnership")(proxy.address);

        console.log("\n\n\n");
        console.log(`${newRtokenSymbol} proxy deployed at: ${proxy.address} at Block Number: ${proxy.receipt.blockNumber}\n`);
        callback();
    } catch (err) {
        callback(err);
    }
};
