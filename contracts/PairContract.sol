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
import "./libraries/SafeMath.sol";

contract PairContract is IPairContract {
	using SafeMath for uint128;

	uint128 public k;  // reserv0 * reserv1

	// ratio factors r_{tA (tB)} of a pair
	mapping(address => mapping(address => uint128[2])) internal ratio;
	// price P(tA, tB) in a pair
	mapping(address => mapping(address => uint128)) internal price;
	// token reserve L(tA) for the Pool
	mapping(address => uint128[2]) internal reserve;


	//====== TO BE REMOVED
    mapping(address => bool) tokenList;  // THIS MAPPING MUST BE REMOVED, IT SHOULD COME FROM THE GOUVERNANCE CONTRACT
	
	// This must be Bonds from EIP-3475
	struct Bond {
		uint128 tokenBond;
		uint128 dbitBond;
	}

	mapping(address => mapping(address => Bond)) public bonds;

	address tokenBondAddress = "0x62C549A323e1864f49ac3A5Bb1448De20b0f5538";
	address DBITBondAddress = "0xC0D335A6296310895E87fcAa31466283f65f43Eb";
	//====================

	modifier inTime(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }


	/**
    * @dev add liquidity of one token to the pool, the amount of the second token (DBIT or DBGT) is minted
    * @dev The _tokenList input must be retrieved from the Gouvernance contract
    */
    function _addLiquidityForOneToken(
        address _token,
        uint128 _amountToken,
        uint128 _amountDBIT
    ) internal view returns(uint128 amountToken, uint128 amountDBIT) {
        // ToDo: the _tokenList mapping must be retrieved from the Gouvernance contract
        bool _tokenList = tokenList[_token];
        require(_tokenList, "Token not listed");

        // ToDo: Toufic must PROVIDE the DBIT mint function
        // CALL function mintDBIT() function and store the result to dbitAmount;
        uint128 dbitAmount = _amountDBIT * 1000;  // MUST BE _amountDebond * mint(debond)

        (amountToken, amountDBIT) = (_amountToken, dbitAmount);
    }

	function addLiquidity(
		address _token,
		uint128 _amountToken,
		uint128 _amountDBIT,
		address _to,
		uint deadline
	) external virtual inTime(deadline) returns(uint128 amountToken, uint128 amountDBIT, uint128 tokenBond, uint128 dbitBond) {
		(amountToken, amountDBIT) = _addLiquidityForOneToken(_token, _amountToken, _amountDBIT);

		// get the _token Bond address from Bank Contract
		// get the DBIT Bond address from Bank Contrat
	}
	
	function updateRatioFactor(address token0, address token1, uint128 amount0, uint128 amount1) external returns(uint128 ratio01, uint128 ratio10) {
		uint128[2] memory _ratio01 = ratio[token0][token1];  // gas savings
		uint128[2] memory _ratio10 = ratio[token1][token0]; // gas savings
		uint128 _reserve0 = reserve[token0][1];
		uint128 _reserve1 = reserve[token1][1];

		reserve[token0][0] = _reserve0;
		reserve[token1][0] = _reserve1;

		uint128 numerator0 = (_ratio01[0].mul(_reserve0)).add(amount1.mul(1 ether));
		uint128 numerator1 = (_ratio10[0].mul(_reserve1)).add(amount1.mul(1 ether));

		ratio[token0][token1][1] = numerator0.div(_reserve0.add(amount0));
		ratio[token1][token0][1] = numerator1.div(_reserve1.add(amount1));

		reserve[token0][1] = _reserve0.add(amount0);
		reserve[token1][1] = _reserve1.add(amount1);

		return (ratio[token0][token1][1], ratio[token1][token0][1]);
	}

	function updatePrice(address token0, address token1) external returns(uint128 price0, uint128 price1) {
		uint128[2] memory _ratio01 = ratio[token0][token1];  // gas savings
		uint128[2] memory _ratio10 = ratio[token1][token0]; // gas savings
		uint128 _previousReserve0 = reserve[token0][0];
		uint128 _previousReserve1 = reserve[token1][0];
		uint128 _reserve0 = reserve[token0][1];
		uint128 _reserve1 = reserve[token1][1];

		uint128 denominator0 = (_ratio01[0].div(1 ether)).mul(_previousReserve0).add(reserve[token0][1].sub(reserve[token0][0]));
		uint128 denominator1 = (_ratio10[0].div(1 ether)).mul(_previousReserve1).add(reserve[token1][1].sub(reserve[token1][0]));

		price[token0][token1] = _ratio10[1].mul(_reserve0).div(denominator0);
		price[token1][token0] = _ratio01[1].mul(_reserve1).div(denominator1);

		return (price[token0][token1], price[token1][token0]);
	}

	function getReserves(address token) external view returns(uint128 previousReserve, uint128 currentReserve) {
		return (reserve[token][0], reserve[token][1]);
	}

	function getRatios(address token0, address token1) external view returns(uint128 previousRatio, uint128 currentRatio) {
		return (ratio[token0][token1][0], ratio[token0][token1][1]);
	}

	function getPrices(address token0, address token1) external view returns(uint128) {
		return price[token0][token1];
	}
}