pragma solidity ^0.8.4;



import '../Core/DebondPair.sol';
import './libraries/DebondLibrary.sol';



contract Bank  {  //is IBank

    address dataContract; // put here or in constructor?

    // we need to have here the mapping of class and nounce? or in data?

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    /*constructor(address _factory, address _WETH) public {
        factory = _factory;
        WETH = _WETH;
        getInfos [tokenA] [tokenB] = (True, 5,['1month', '6month']);

    }*/

    /*receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }*/

    function amountOfDBITToMint(uint256 amountA) public pure returns(uint256 amountToMint) {
		//== THIS TWO VARIABLE MUS BE IMPORTED FROM SIGMOID CONTRACT
		uint256 dbitMaxSupply = 10000000;
		uint256 dbitTotalSupply = 1000000;
		//===

		require(amountA > 0, "Amount of DBIT");
		require(dbitTotalSupply.add(amountA) <= dbitMaxSupply, "Not enough DBIT remins to buy");

		// amount of of DBIT to mint
		uint amountDBIT = amountA /* dbitUSDPrice()*/;
	}

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA, // token added
        address tokenB, //token minted
        uint amountADesired,
        uint amountBMin  // a verifier
    ) internal virtual returns (uint amountA, uint amountB) {
        //require (IData(dataContract).tokenAllowed[tokenA][tokenB]); 

        (uint reserveA, uint reserveB) = DebondPair.getReserves( tokenA, tokenB);
        
        
        uint amountBOptimal = amountOfDBITToMint(amountADesired);
        //should calculate how much debit should be minted, 
        //maybe should be added in core contracts and not in debond router
        
        require(amountBOptimal >= amountBMin, 'UniswapV2Router: formula of dbit minting changed too fast');
        (amountA, amountB) = (amountADesired, amountBOptimal);
        
    }




    function addLiquidity(
        address tokenA,
        address tokenB,
        
        uint amountADesired,
        
        uint amountBMin,
        
        address to,
        uint deadline,
        uint choice,  //0 for stacking, 1 for buying : bool is better? see gas
        uint nounce, // verify format here : [ (time1, %1), (time 2, %2), etc...]
        // faire [uint] nounce (time) et [uint] interets et vérifier que les tailles sont égales
        uint interest // should be a function
        //uint class we don't need, as we already have tokenA address
    ) external virtual /*override*/ ensure(deadline) returns (uint amountA, uint amountDbit, uint liquidity) {
        (amountA, amountDbit) = _addLiquidity(tokenA, tokenB, amountADesired, amountBMin); 

        //address pair = DebondLibrary.pairFor(factory, tokenA, tokenDbit); // this is not a pair but a n-uplet

        //look if nounce exist: if not, create new one
        
        IERC20(tokenA).safeTransferFrom(tokenA, msg.sender, pair, amountA); 
        IDBITERC20(Dbit_address).mint(pair, amountDbit); // syntax
        
        liquidity = IDebondPair(pair).mint(to, /* amountA, does not need to be added*/ choice, nounce, interest, class, tokenA); // mint of the bond, we do not precise class as we provide pair address
        // interest should be calculated and not directly put in param, because everyone can call this function
    }
    
/*
    // **** REMOVE LIQUIDITY ****

    //add step here : verify if the bond is reedemable.
    //when we redeem, we are not sure if we burn dbit or not
    function removeLiquidity(
        address tokenA, //we have the address of the bond, and we will then see how much of bonds you have
        //address tokenDbit,
        //uint liquidity, 
        //uint amountA, 
        uint amountAMin, // amount of bond we want to redeem (could be amount/2, or else...)
        //uint amountBMin,
        address to,
        uint deadline
        //should have a param to know if flexible rate or fix rate, so we now if there is priority to redeem. 
    ) public virtual  ensure(deadline) returns (uint amountA, uint amountB) { //override
        address pair = DebondLibrary.pairFor(factory, BondA, tokenDbit);
        DebondPair(pair).transferFrom(msg.sender, pair, amountAMin); // send liquidity to pair
        (uint amount0, uint amount1) = IDebondPair(pair).burn(to , amountAMin); 
        

        //amount0=token0, amount1 = tokendbit, interest
        (address token0,) = DebondLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        //require(amountA >= amountAMin, 'UniswapV2Router: INSUFFICIENT_A_AMOUNT');  We do not need that : bond can be lower than expected.
        //require(amountB >= amountBMin, 'UniswapV2Router: INSUFFICIENT_B_AMOUNT');
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    


    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual  returns (uint amountB) { //override
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }
*/
    
}
