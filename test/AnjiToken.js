const {ethers} = require('hardhat');
const {expect} = require('chai');

describe('ERC20 Anji Token Testing',function(){
    let accounts;
    let token;
    const amount = ethers.parseEther("1");

    before(async()=>{
        accounts = await ethers.getSigners();
        const contract = await ethers.getContractFactory("AnjiToken");
        token = await contract.deploy();
    })

    it('Test for Initial Supply',async()=>{
        const supply = await token.totalSupply();
        expect(await token.balanceOf(accounts[0].address)).to.equal(supply);
    })

    it('Only Owner can Mint Tokens - Not EOA',async()=>{
        const wallet = await token.connect(accounts[2]);
        expect(wallet.mint(accounts[2].address,amount)).to.be.reverted;
    })

    it('Do not have Permission to Burn Tokens',async()=>{
        const wallet = token.connect(accounts[2]);
        expect(wallet.burn(accounts[2].address,amount)).to.be.reverted;
    })

    it('Buy Tokens With Ethers',async()=>{
        const wallet = token.connect(accounts[2]);
        const option = {value:amount};
        const calculate = (option.value).mul(1000);
        await wallet.buy(option);
        expect(await wallet.balanceOf(accounts[2].address)).to.equal(calculate);
    })
})