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
import "./interfaces/IDebondFactory.sol";

contract DebondFactory is IDebondFactory {
    mapping(address => mapping(address => address)) public pairs;

    function createPair(address _token0, address _token1) external view returns(address pair) {
        require(_token0 != _token1, "Debond: identical token addresses");
        require(_token0 != address(0) && _token1 != address(0), "Debond: zero address");

        pair = getPair(_token0, _token1);
        require(pair == address(0), "Debond: pair exists");

        // CREATE PAIR LOGIC GOES UNDER THIS
    }

    function getPair(address token0, address token1) public view returns(address pair) {
        return pairs[token0][token1];
    }
}