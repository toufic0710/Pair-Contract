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

// DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    uint128 constant WAD = 10 ** 18;
    uint128 constant RAY = 10 ** 27;

    function add(uint128 x, uint128 y) internal pure returns (uint128 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint128 x, uint128 y) internal pure returns (uint128 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint128 x, uint128 y) internal pure returns (uint128 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint128 x, uint128 y) internal pure returns (uint128 z) {
        return x <= y ? x : y;
    }
    function max(uint128 x, uint128 y) internal pure returns (uint128 z) {
        return x >= y ? x : y;
    }
    function imin(int128 x, int128 y) internal pure returns (int128 z) {
        return x <= y ? x : y;
    }
    function imax(int128 x, int128 y) internal pure returns (int128 z) {
        return x >= y ? x : y;
    }

    function wmul(uint128 x, uint128 y) internal pure returns (uint128 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint128 x, uint128 y) internal pure returns (uint128 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint128 x, uint128 n) internal pure returns (uint128 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        return a / b;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {
        return a % b;
    }

}
