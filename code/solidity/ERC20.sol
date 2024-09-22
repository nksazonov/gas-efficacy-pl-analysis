// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AbstractERC20Capped} from "./AbstractERC20Capped.sol";
import {AbstractERC20} from "./AbstractERC20.sol";

contract ERC20 is AbstractERC20Capped {
    uint8 private immutable _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 cap_,
        address beneficiary
    ) AbstractERC20Capped(cap_) AbstractERC20(name_, symbol_) {
        _decimals = decimals_;
        _mint(beneficiary, cap_);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
