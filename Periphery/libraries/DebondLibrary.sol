pragma solidity ^0.8.0;


//import '../../Core/DebondPair.sol';
import '../../Core/interfaces/IDebondPair.sol';
import './PRBMathSD59x18.sol';


library DebondLibrary  {

    

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'DebondLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'DebondLibrary: ZERO_ADDRESS');
    }

    /*function getReserves(address tokenA, address tokenB) public view returns (uint112 reserveA, uint112 reserveB) {
        (address token0, address token1) = DebondLibrary.sortTokens(tokenA, tokenB);
        Pair pair = addressToPair[token0][token1];
        (uint reserve0, uint reserve1) = (pair.reserveTokenA, pair.reserveTokenB);
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
       
    }*/

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(int256 amountA, int256 reserveA, int256 reserveB) internal pure returns (int256 amountB) { /// use uint?? int256???
        require(amountA > 0, 'DebondLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'DebondLibrary: INSUFFICIENT_LIQUIDITY');
        //amountB = amountA.mul(reserveB) / reserveA;
        amountB = PRBMathSD59x18.div( PRBMathSD59x18.mul(amountA,reserveB), reserveA);

    }

    /*// given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'DebondLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DebondLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'DebondLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'DebondLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }*/

}
