// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MultiSigWallet{

    event Deposit(address indexed sender,uint amount,uint balance);
    event SubmitTransaction(
        address indexed owner,
        address indexed to,
        uint indexed txIndex,
        uint value,
        bytes data
    );
    event ExecuteTransaction(address indexed owner,uint txIndex);
    event ConfirmTransaction(address indexed owner,uint txIndex);
    event RevokeTransaction(address indexed owner,uint txIndex);

    address[] public owners;
    uint public numConfirmationsRequired;
    mapping(address=>bool) public isOwner;

    struct Transaction{
        address to;
        bool executed;
        uint value;
        bytes data;
        uint numConfirmations;
    }

    Transaction[] public transactions;
    mapping(uint=>mapping(address=>bool)) public isConfirmed;

     modifier onlyOwner(){
        require(isOwner[msg.sender],"Not an owner");
        _;
    }

    modifier txExists(uint _txIndex){
        require(_txIndex<transactions.length,"Txn doesn't exist");
        _;
    }

    modifier notExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed,"tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"txn already confirmed");
        _;
    }

    constructor(address[] memory _owners,uint _numConfirmationsRequired){
        require(_owners.length>0,"atleast one owner is required");
        require(_numConfirmationsRequired>0 && _numConfirmationsRequired<=_owners.length);
        for(uint i=0;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner!=address(0),"owner invalid");
            require(!isOwner[owner],"owner not unique");
            isOwner[owner]=true;
            owners.push(owner);
        }
        numConfirmationsRequired=_numConfirmationsRequired;
    }

    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner{
        uint txIndex=transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value:_value,
                data:_data,
                executed:false,
                numConfirmations:0
            })
        );
        emit SubmitTransaction(msg.sender,_to,txIndex,_value,_data);
    }

    function confirmTransaction(uint _txIndex) public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
    notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations+=1;
        isConfirmed[_txIndex][msg.sender]=true;
        emit ConfirmTransaction(msg.sender,_txIndex);
    }

    function DepsoitEther() public payable{
        emit Deposit(msg.sender,msg.value,address(this).balance);
    }

    function executeTransaction(uint _txIndex) public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations>=numConfirmationsRequired,"Confirmations required");
        transaction.executed = true;
        (bool success,) = transaction.to.call{gas:25000,value:transaction.value}(transaction.data);
        require(success,"Txn failed");
        emit ExecuteTransaction(msg.sender,_txIndex);
    }

    function revokeConfirmation(uint _txIndex) public 
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender],"Txn not confirmed to revoke");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokeTransaction(msg.sender,_txIndex);
    }

    function getOwners() public view returns(address[] memory){
        return owners;
    }

    function getTransactionCount() public view returns(uint){
        return transactions.length;
    }

    function getTransaction(uint _txIndex) public view
    returns(
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint numConfirmations
    )
    {
        Transaction storage transaction = transactions[_txIndex];
        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }  
}