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

import "./libraries/SafeMath.sol";

contract DebondPair {
    using SafeMath for uint256;

    address public factory;
    address public token0;
    address public token1;

    uint256 private reserve0; 
    uint256 private reserve1;

    // to be checked
    uint256 private totalReserve0;
    uint256 private totalReserve1;

    uint256 public price0;
    uint256 public price1;
    uint256 public k; // reserv0 * reserv1

    // ratio factors r_{t1 (t2)} and r_{t2 (t1)}
    mapping(address => mapping(address => uint256[2])) ratio;
    uint256 public ratioFactor01;
    uint256 public ratioFactor10;

    // mapping of pairs tokens in a pool
    // tokenA => tokenB => r_{tA (tB)}
    //mapping(tokenA => mapping(tokenB => r_{A (B)})) private pools;
    //mapping(tokenB => mapping(tokenA => r_{B (A)})) private pools;

    // THIS MAPPING MUST BE REMOVED, IT SHOULD COME FROM THE GOUVERNANCE CONTRACT
    mapping(address => bool) tokenList;


    /**
    * @dev add liquidity of one token to the pool, the amount of the second token (DBIT or DBGT) is minted
    * @dev The _tokenList input must be retrieved from the Gouvernance contract
    */
    function _addLiquidityForOneToken(
        address _token,
        uint256 _amountToken,
        uint256 _amountDBIT
    ) internal view returns(uint256 amountToken, uint256 amountDBIT) {
        // ToDo: the _tokenList mapping must be retrieved from the Gouvernance contract
        bool _tokenList = tokenList[_token];
        require(_tokenList, "Token not listed");

        // ToDo: Toufic must PROVIDE the DBIT mint function
        // CALL function mintDBIT() function and store the result to dbitAmount;
        uint256 dbitAmount = _amountDBIT * 1000;  // MUST BE _amountDebond * mint(debond)

        (amountToken, amountDBIT) = (_amountToken, dbitAmount);
    }

    function addLiquidityForOneToken(
        address _token,
        uint256 _amountToken,
        uint256 _amountDebond
    ) public {

    }

	function updateRatioFactor(uint256 amount0, uint256 amount1) internal returns(uint256, uint256) {
        ratioFactor01 = (reserve0.add(amount0).mul(1 ether)).div(totalReserve0.add(amount0));
        ratioFactor10 = (reserve1.add(amount1).mul(1 ether)).div(totalReserve1.add(amount1));

        reserve0 = reserve0.add(amount0);
        reserve1 = reserve1.add(amount1);
        k = reserve0.mul(reserve1);
        totalReserve0 = totalReserve0.add(amount0);
        totalReserve1 = totalReserve1.add(amount1);

        return (ratioFactor01, ratioFactor10);
    }

    function updatePrice() internal returns(uint256, uint256) {
        price0 = (ratioFactor10.mul(totalReserve1)).div(reserve0);
        price1 = (ratioFactor01.mul(totalReserve0)).div(reserve1);

        return (price0, price1);
    }

    function getReserves() public view returns(uint256 _reserve0, uint256 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    } 


    function test(uint256 _amount0, uint256 _amount1) external {
        reserve0 = 100;
        reserve1 = 200;
        totalReserve0 = 500;
        totalReserve1 = 800;

        updateRatioFactor(_amount0, _amount1);
        updatePrice();
    }
}