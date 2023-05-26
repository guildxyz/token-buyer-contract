// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

/// @title An ERC20 token that returns false on transfer, used only for tests.
contract MockBadERC20 is ERC20 {
    constructor() ERC20("MockToken", "MCKT") {
        _mint(msg.sender, 100 ether);
    }

    function transfer(address to, uint256 amount) public pure override returns (bool) {
        // not calling super.transfer anymore, because it reverts already if there's an error
        to;
        amount;
        return false;
    }

    function transferFrom(address from, address to, uint256 amount) public pure override returns (bool) {
        from;
        to;
        amount;
        return false;
    }
}
