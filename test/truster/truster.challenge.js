const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, player;
    let token, pool;

<<<<<<< Updated upstream
    const TOKENS_IN_POOL = 1000000n * 10n ** 18n;

=======
    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');
 
>>>>>>> Stashed changes
    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        pool = await (await ethers.getContractFactory('TrusterLenderPool', deployer)).deploy(token.address);
        expect(await pool.token()).to.eq(token.address);

        await token.transfer(pool.address, TOKENS_IN_POOL);
        expect(await token.balanceOf(pool.address)).to.equal(TOKENS_IN_POOL);

        expect(await token.balanceOf(player.address)).to.equal(0);
    });

<<<<<<< Updated upstream
    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
=======
    it('Exploit', async function () {
        const attackerFactory = await ethers.getContractFactory('TrusterAttack', attacker);
        const attackerContract = await attackerFactory.deploy(this.pool.address, this.token.address);
        await attackerContract.attack();
>>>>>>> Stashed changes
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player has taken all tokens from the pool
        expect(
            await token.balanceOf(player.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await token.balanceOf(pool.address)
        ).to.equal(0);
    });
});

