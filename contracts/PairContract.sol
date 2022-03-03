pragma solidity 0.8.12;

// SPDX-License-Identifier: apache 2.0
/*
    Copyright 2020 Sigmoid Foundation <info@SGM.finance>
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

import "./interfaces/IPairContract.sol";
import "./SigmoidBank.sol";
import "./libraries/SafeMath.sol";
import "./libraries//PRBMathUD60x18.sol";

contract PairContract is IPairContract {
	using SafeMath for uint256;
	SigmoidBank bank;

	mapping(address => mapping(address => uint256)) public k; // reserv0 * reserve1
	// ratio factors r_{tA (tB)} of a pair
	mapping(address => mapping(address => uint256[2])) internal ratio;
	// price P(tA, tB) in a pair
	mapping(address => mapping(address => uint256)) internal price;
	// token reserve L(tA) for the Pool
	mapping(address => uint256[2]) internal reserve;


	//====== TO BE REMOVED
	
	// This must be Bonds from EIP-3475
	struct Bond {
		uint256 tokenBond;
		uint256 dbitBond;
	}

	mapping(address => mapping(address => Bond)) public bonds;

	address tokenBondAddress = 0x62C549A323e1864f49ac3A5Bb1448De20b0f5538;
	address DBITBondAddress  = 0xC0D335A6296310895E87fcAa31466283f65f43Eb;
	//====================

	modifier inTime(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

	constructor(address _bankContract) {
		bank = SigmoidBank(_bankContract);
	}


	/**
    * @dev add liquidity of one token to the pool, the amount of the second token (DBIT or DBGT) is minted
    * @dev The _tokenList input must be retrieved from the Gouvernance contract
    */
    function _addLiquidityForOneToken(
		uint256 _coinIndex,
        address _token,
        uint256 _amountToken,
        uint256 _amountDBIT
    ) internal view returns(uint256 amountToken, uint256 amountDBIT) {
        require(bank.tokenListed(_token, _coinIndex), "Pair doesn't exist");
		
        uint256 dbitAmount = amountOfDebondToMint(_amountDBIT);
        (amountToken, amountDBIT) = (_amountToken, dbitAmount);
    }

	function addLiquidity(
		uint256 _coinIndex,
		address _token,
		uint256 _amountToken,
		uint256 _amountDBIT,
		address _to,
		uint deadline
	) external virtual inTime(deadline) returns(uint256 amountToken, uint256 amountDBIT, uint256 tokenBond, uint256 dbitBond) {
		require(_to != address(0), "Zero address not allowed");
		address _DBIT = bank.DBITContract();

		(amountToken, amountDBIT) = _addLiquidityForOneToken(_coinIndex, _token, _amountToken, _amountDBIT);

		// get the _token Bond address from Bank Contract
		// get the DBIT Bond address from Bank Contrat
		(tokenBond, dbitBond) = (10, 10);

		// update the ratio factor
		updateRatioFactor(_token, _DBIT, amountToken, amountDBIT);

		// update the price
		updatePrice(_token, _DBIT);

		// Transfer bonds TokenBond and dbitBond the `to` address
		// Call transfer function
	}
	
	function updateRatioFactor(address token0, address token1, uint256 amount0, uint256 amount1) public returns(uint256 ratio01, uint256 ratio10) {
		uint256[2] memory _ratio01 = ratio[token0][token1];  // gas savings
		uint256[2] memory _ratio10 = ratio[token1][token0]; // gas savings
		uint256 _reserve0 = reserve[token0][1];
		uint256 _reserve1 = reserve[token1][1];

		reserve[token0][0] = _reserve0;
		reserve[token1][0] = _reserve1;

		uint256 numerator0 = (_ratio01[0].mul(_reserve0)).add(amount1.mul(1 ether));
		uint256 numerator1 = (_ratio10[0].mul(_reserve1)).add(amount1.mul(1 ether));

		ratio[token0][token1][1] = numerator0.div(_reserve0.add(amount0));
		ratio[token1][token0][1] = numerator1.div(_reserve1.add(amount1));

		reserve[token0][1] = _reserve0.add(amount0);
		reserve[token1][1] = _reserve1.add(amount1);

		return (ratio[token0][token1][1], ratio[token1][token0][1]);
	}

	function updatePrice(address token0, address token1) public returns(uint256 price0, uint256 price1) {
		uint256[2] memory _ratio01 = ratio[token0][token1];  // gas savings
		uint256[2] memory _ratio10 = ratio[token1][token0]; // gas savings
		uint256 _previousReserve0 = reserve[token0][0];
		uint256 _previousReserve1 = reserve[token1][0];
		uint256 _reserve0 = reserve[token0][1];
		uint256 _reserve1 = reserve[token1][1];

		uint256 denominator0 = (_ratio01[0].div(1 ether)).mul(_previousReserve0).add(reserve[token0][1].sub(reserve[token0][0]));
		uint256 denominator1 = (_ratio10[0].div(1 ether)).mul(_previousReserve1).add(reserve[token1][1].sub(reserve[token1][0]));

		price[token0][token1] = _ratio10[1].mul(_reserve0).div(denominator0);
		price[token1][token0] = _ratio01[1].mul(_reserve1).div(denominator1);

		return (price[token0][token1], price[token1][token0]);
	}

	function amountOfDebondToMint(uint256 _dbitIn) public pure returns(uint256 amountDBIT) {
		//== THIS TWO VARIABLE MUS BE IMPORTED FROM SIGMOID CONTRACT
		uint256 dbitMaxSupply = 10000000;
		uint256 dbitTotalSupply = 1000000;
		//===

		require(_dbitIn > 0, "Cannot mint 0 DBIT");
		require(dbitTotalSupply.add(_dbitIn) <= dbitMaxSupply, "Not enough DBIT remins to buy");

		// amount of of DBIT to mint
		amountDBIT = _dbitIn * dbitUSDPrice();
	}

	function mint(address to) external returns(uint256 boundToken1, uint256 boundToken2) {
		// ToDo: Toufic must provide the mint function

	}

	function getReserves(address token) external view returns(uint256 previousReserve, uint256 currentReserve) {
		return (reserve[token][0], reserve[token][1]);
	}

	function getRatios(address token0, address token1) external view returns(uint256 previousRatio, uint256 currentRatio) {
		return (ratio[token0][token1][0], ratio[token0][token1][1]);
	}

	function getPrices(address token0, address token1) external view returns(uint256) {
		return price[token0][token1];
	}

	function dbitUSDPrice() public pure returns(uint256 DBITPrice) {
		//== THIS TWO VARIABLE MUS BE IMPORTED FROM SIGMOID CONTRACT
		uint256 dbitTotalSupply = 1000000;
		//===

		if (dbitTotalSupply < 1e5) {
			DBITPrice = 1 ether;
		} else {
			uint256 logTotalSupply = PRBMathUD60x18.ln(dbitTotalSupply * 1e13);
			DBITPrice = PRBMathUD60x18.pow(1.05 * 1 ether, logTotalSupply);
		}
	}
}