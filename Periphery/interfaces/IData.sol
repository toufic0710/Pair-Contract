pragma solidity >=0.6.2;

interface IData {
    function updateTokenAllowed ( 
        address tokenA, 
        address tokenB, 
        bool allowed
        ) external;
    
}
