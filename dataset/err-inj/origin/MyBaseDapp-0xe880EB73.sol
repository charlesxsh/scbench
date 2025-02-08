// SPDX-License-Identifier: MIT

    pragma solidity ^0.8.0;

    contract MyBaseDapp {

    uint256 private counter;

    event CounterUpdated(uint256 newValue);

    constructor() {

    counter = 0;

    }

    function getCounter() public view returns (uint256) {

    return counter;

    }

    function increment() public {

    counter++;

    emit CounterUpdated(counter);

    }

    }