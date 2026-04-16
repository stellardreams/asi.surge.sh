// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    uint256 constant INITIAL_SUPPLY = 10000000000 * 10**18;

    constructor() ERC20("TestToken", "TEST") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}