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
    using SafeMath for uint128;

    address public factory;
    address public token0;
    address public token1;

    uint128 private reserve0; 
    uint128 private reserve1;

    // to be checked
    uint128 private totalReserve0;
    uint128 private totalReserve1;

    uint128 public price0;
    uint128 public price1;
    uint128 public k; // reserv0 * reserv1

    // ratio factors r_{t1 (t2)} and r_{t2 (t1)}
    uint128 public ratioFactor01;
    uint128 public ratioFactor10;

    // mapping of pairs tokens in a pool
    //mapping(address => mapping(address => address)) private pools;


	function updateratioFactor(uint128 amount0, uint128 amount1) internal returns(uint128, uint128) {
        ratioFactor01 = (reserve0.add(amount0).mul(1 ether)).div(totalReserve0.add(amount0));
        ratioFactor10 = (reserve1.add(amount1).mul(1 ether)).div(totalReserve1.add(amount1));

        reserve0 = reserve0.add(amount0);
        reserve1 = reserve1.add(amount1);
        k = reserve0.mul(reserve1);
        totalReserve0 = totalReserve0.add(amount0);
        totalReserve1 = totalReserve1.add(amount1);

        return (ratioFactor01, ratioFactor10);
    }

    function updatePrice() internal returns(uint128, uint128) {
        price0 = (ratioFactor10.mul(totalReserve1)).div(reserve0);
        price1 = (ratioFactor01.mul(totalReserve0)).div(reserve1);

        return (price0, price1);
    }

    function getReserves() public view returns(uint128 _reserve0, uint128 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    } 



    function test(uint128 _amount0, uint128 _amount1) external {
        reserve0 = 100;
        reserve1 = 200;
        totalReserve0 = 500;
        totalReserve1 = 800;

        updateratioFactor(_amount0, _amount1);
        updatePrice();
    }
}