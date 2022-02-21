const DebondPair = artifacts.require("DebondPair");

contract("Debond Pair Contract", async (accounts) => {
	let contract;
	let account0 = accounts[0];
	let account1 = accounts[1];

	beforeEach(async () => {
		contract = await DebondPair.deployed();
	});

	it("should deploy the contract", async () => {
		expect(contract.address).not.to.equal(undefined);
	});

	it("Should update the ratio factor and price", async () => {
		let reservesBefore = await contract.getReserves();

		await contract.test(10, 10, {from: account0} );

		let reservesAfter = await contract.getReserves();
	});
})