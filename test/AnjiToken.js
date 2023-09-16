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
        const calculate = (option.value);
        await wallet.buyTokensWithEthers(option);
        expect(await wallet.balanceOf(accounts[2].address)).to.equal(calculate);
    })

    it('Do not have permission to withdraw ether',async()=>{
        const wallet = await token.connect(accounts[3]);
        await expect(wallet.withdraw(amount)).to.be.reverted;
    })

    it('transfer amount to destination account',async()=>{
        await token.transfer(accounts[1].address,amount);
        expect(await token.balanceOf(accounts[1].address)).to.equal(amount);
    })

    it('can not transfer above the amount',async()=>{
        const wallet = await token.connect(accounts[3]);
        await expect(wallet.transfer(accounts[1].address,1)).to.be.reverted;
    })

    it('can not transfer from empty account',async()=>{
        const wallet = await token.connect(accounts[3]);
        await expect(wallet.transfer(accounts[1].address,1)).to.be.reverted;
    })

    it('minting token test',async()=>{
        const before_mint = await token.balanceOf(accounts[0].address);
        await token.mint(accounts[0].address,amount);
        const after_mint = await token.balanceOf(accounts[0].address);
        expect(after_mint).to.equal(before_mint+amount);
    })

    it('burning token test',async()=>{
        const before_burn = await token.balanceOf(accounts[0].address);
        await token.burn(accounts[0].address,amount);
        const after_burn = await token.balanceOf(accounts[0].address);
        expect(after_burn).to.equal(before_burn-amount);
    })

    it('withdraw ether from contract account',async()=>{
        const before_withdraw = await ethers.provider.getBalance(accounts[0].address);
        await token.withdraw(amount);
        const after_withdraw = await ethers.provider.getBalance(accounts[0].address);
        expect(before_withdraw<after_withdraw).to.equal(true);
    })

    it('No enough ethers to buy tokens',async()=>{
        const wallet = await token.connect(accounts[3]);
        const amt = ethers.parseEther("100");
        const msg = {value:amt};
        try{
            await wallet.buyTokensWithEthers(msg);
            throw new Error("No enough ethers to buy tokens");
        }catch(err){
            expect(err.message).to.equal("No enough ethers to buy tokens");
        }
    })
})