pragma solidity =0.8.12;


import './interfaces/Idata.sol';


contract Data is IData { 

    address USDT;
    address USDC;
    address DAI;

    address DBIT;
    address DBGT;

    address governance;
    
    modifier onlyGov()  {
        if(msg.sender == governance) {
           _;
        }
    }

    mapping (address => mapping ( address => bool ) ) public tokenAllowed; //private or??

    //tokens whitlistées

    // mapping class nounce?
    
    constructor() {
        tokenAllowed[DBIT][USDT] = true; 
        tokenAllowed[DBIT][USDC] = true;
        tokenAllowed[DBIT][DAI] = true;

        tokenAllowed[DBGT][USDT] = true;
        tokenAllowed[DBGT][USDC] = true;
        tokenAllowed[DBGT][DAI] = true;

    }


    function updateTokenAllowed ( 
        address tokenA, 
        address tokenB, 
        bool allowed
        ) external onlyGov {
        tokenAllowed [tokenA] [tokenB] = allowed;
    }

   
}
