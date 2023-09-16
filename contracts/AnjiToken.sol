// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AnjiToken is ERC20,Ownable{

    constructor() ERC20('AnjiToken','AT'){
        _mint(msg.sender,100000*(10**decimals()));
    }

    function mint(address account,uint amount) public onlyOwner returns(bool){
        require(account != address(this) && amount != uint(0),'ERC20: Mint Failed');
        _mint(account,amount);
        return true;
    }

    function burn(address account,uint amount) public onlyOwner returns(bool){
        require(account != address(this) && amount != uint(0),'ERC20: Burn Failed');
        _burn(account,amount);
        return true;
    }

    function buyTokensWithEthers() public payable{
        require(msg.value<=msg.sender.balance && msg.value != 0 ether,"ICO: Insufficiet Funds");
        uint amount = msg.value;
        _transfer(owner(),_msgSender(),amount);
    }

    function withdraw(uint amount) public payable onlyOwner returns(bool){
        require(amount<=address(this).balance,'Insufficient Funds in CA to withdraw');
        payable(_msgSender()).transfer(amount);
        return true;
    }
}