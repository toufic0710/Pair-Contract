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

contract SigmoidBank {
	struct List {
        address[] tokenAddress;
        uint256 numberOfTokens;
    }

    struct Pair {
        address token0;
        address token1;
        uint256 reserveToken0;
        uint256 reserveToken1;
    }

    address public DBITContract;
    address public DBGTContract;
    address public DAIContract;
    address public gouvernanceContract;
    address public bankContract;
    address public bondContract;

    mapping(uint256 => List) internal list;
    mapping(address => mapping(address => uint256[2])) internal pairs;
    mapping(address => bool) public whitelist;

    bool public contractIsActive;

    constructor() {
        DBITContract = 0x1aEBC194Adc787656901F6857008FA2CecAE0d0f;
        DBGTContract = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

        DAIContract = 0x963026A3616A7e27235ffa87592CebAaF340Af7a;
    }

    function setList() public {
        address USDT = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        address USDC = 0x9F08560CBF0204c8bB4c45F1E9808549Be01A39A;
        address BUSD = 0x128172788D386E44e37eFF38454Ba54cf350206F;
        address UST  = 0x9a25f122Fb39B6cB17fcCd63584f8473C09A683C;

        /**
        * @dev list index: 0 - DBIT, 1 - DBGT
        */
        list[0].tokenAddress.push(USDT);
        list[0].tokenAddress.push(USDC);
        list[0].tokenAddress.push(BUSD);
        list[0].tokenAddress.push(UST);
        list[0].tokenAddress.push(DAIContract);

        list[0].numberOfTokens = 5;
    }

    function tokenListed(address _address, uint256 _coinIndex) public view returns(bool listed) {
        address[] memory addresses = fetchAllTokenListed(_coinIndex);

        for (uint256 i = 0; i < list[0].numberOfTokens; i++) {
            if (addresses[i] == _address) listed = true;
        }
    }

    function fetchAllTokenListed(uint256 _coinIndex) public view returns(address[] memory) {
        return list[_coinIndex].tokenAddress;
    }

    function listToken(address _token, uint256 _coinIndex) public returns(bool) {
        // ToDo: Check that token with index _coinIndex (such as DBIT) is allowed by Gouvernance contract
        bool listed = tokenListed(_token, _coinIndex);
        require(listed == false, "Debond: Token already listed");

        list[_coinIndex].tokenAddress.push(_token);
        list[_coinIndex].numberOfTokens += 1;

        return true;
    }
}