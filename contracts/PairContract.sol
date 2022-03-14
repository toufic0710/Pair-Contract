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
import "./SigmoidBank.sol";
import "./libraries/SafeMath.sol";
import "./libraries//PRBMathUD60x18.sol";
import "./ERC3475.sol";
import "./ERC20/IERC20.sol";


contract PairContract is ERC3475 {
	using SafeMath for uint256;
	SigmoidBank bank;
	// ratio factors r_{tA (tB)} of a pair
	mapping(address => mapping(address => uint256[2])) internal ratio;
	// price P(tA, tB) in a pair
	mapping(address => mapping(address => uint256)) internal price;
	// token reserve L(tA) for the Pool
	mapping(address => uint256[2]) internal reserve;

	modifier inTime(uint256 deadline) {
        require(deadline >= block.timestamp, 'Debond: EXPIRED');
        _;
    }

	constructor(address _bankContract) {
		bank = SigmoidBank(_bankContract);
		createClass(0, 0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47, "DBIT");
		createClass(1, 0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3, "DAI");
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
		bool listed = bank.tokenListed(_token, _coinIndex);
        require(listed, "Pair doesn't exist");
		
        uint256 dbitAmount = amountOfDebondToMint(_amountDBIT);
        (amountToken, amountDBIT) = (_amountToken, dbitAmount);
    }

	function addLiquidity(
		uint256 _coinIndex,
		address _token,
		uint256 _amountToken,
		uint256 _amountDBIT,
		uint256 _classIdDBIT,
		uint256 _classIdToken,
		uint256 _nonecDBIT,
		uint256 _nonceToken,
		address _to,
		uint deadline
	) external inTime(deadline) returns(uint256 amountToken, uint256 amountDBIT) {
		require(_to != address(0), "Zero address not allowed");
		address _DBIT = bank.DBITContract();
		//address _dai = bank.DAIContract();

		(amountToken, amountDBIT) = _addLiquidityForOneToken(_coinIndex, _token, _amountToken, _amountDBIT);

		// update the ratio factor
		updateRatioFactor(_token, _DBIT, amountToken, amountDBIT);

		// update the price
		updatePrice(_token, _DBIT);

		//require(IERC20(_DBIT).balanceOf(msg.sender) >= amountDBIT / 1 ether, "Debond: not enough DBIT");
		//require(IERC20(_token).balanceOf(msg.sender) >= amountToken / 1 ether, "Debond: not enough DAI");

		//IERC20(_DBIT).approve(address(this), amountDBIT);
		//IERC20(_dai).approve(address(this), amountToken);

		// transfer token to the Pair Contract
		IERC20(_DBIT).transferFrom(msg.sender, address(this), amountDBIT);
        IERC20(_token).transferFrom(msg.sender, address(this), amountToken / 1);

		// issuer DBIT and Token bonds
		issue(_to, _classIdDBIT, _nonecDBIT, amountDBIT);
		issue(_to, _classIdToken, _nonceToken, amountToken);

		return (
			amountToken,
			amountDBIT
		);
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

		require(_dbitIn > 0, "Amount of DBIT");
		require(dbitTotalSupply.add(_dbitIn) <= dbitMaxSupply, "Not enough DBIT remins to buy");

		// amount of of DBIT to mint
		amountDBIT = _dbitIn * dbitUSDPrice();
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
		//== THIS TWO VARIABLE MUST BE IMPORTED FROM SIGMOID CONTRACT
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