// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "solmate/tokens/ERC20.sol";

contract USDC is ERC20{

    constructor() ERC20("USDC", "USDC", 6) {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}
