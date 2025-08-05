// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_, decimals_) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Optional: Add burn if needed for tests
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}