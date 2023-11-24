// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "TA") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function approveSpender(address spender, uint256 amount) external {
        _approve(msg.sender, spender, amount);
    }
}
