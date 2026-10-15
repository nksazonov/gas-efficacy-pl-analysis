// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm, Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {IERC20} from "../src/IERC20.sol";
import {ERC20} from "../src/solidity/ERC20.sol";

contract ERC20Test is StdCheats, Test {
    address beneficiary = vm.createWallet("beneficiary").addr;

    IERC20 token;

    string name = "TestToken";
    string symbol = "TT";
    uint8 decimals = 18;
    uint256 totalSupply = 1000000e18;

    function createContract(
        bytes memory bytecode
    ) public returns (address addr) {
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
            if and(iszero(addr), not(iszero(returndatasize()))) {
                let p := mload(0x40)
                returndatacopy(p, 0, returndatasize())
                revert(p, returndatasize())
            }
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        return addr;
    }

    function deployBytecodeERC20(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address beneficiary_
    ) public returns (IERC20) {
        string memory bytecodePath = vm.envString("BYTECODE_PATH");
        bytes memory params = abi.encode(
            name_,
            symbol_,
            decimals_,
            totalSupply_,
            beneficiary_
        );
        bytes memory creationBytecode = abi.encodePacked(
            vm.getCode(bytecodePath),
            params
        );

        IERC20 erc20Token = IERC20(createContract(creationBytecode));
        return erc20Token;
    }

    function setUp() public {
        token = deployBytecodeERC20(
            name,
            symbol,
            decimals,
            totalSupply,
            beneficiary
        );
    }

    function testMetadata(
        string calldata name_,
        string calldata symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        address beneficiary_
    ) public {
        vm.assume(bytes(name_).length < 32);
        vm.assume(bytes(symbol_).length < 32);
        vm.assume(decimals_ > 0);
        vm.assume(totalSupply_ > 0);
        vm.assume(beneficiary_ != address(0));
        IERC20 tkn = deployBytecodeERC20(
            name_,
            symbol_,
            decimals_,
            totalSupply_,
            beneficiary_
        );
        assertEq(tkn.name(), name_);
        assertEq(tkn.symbol(), symbol_);
        assertEq(tkn.decimals(), decimals_);
        assertEq(tkn.totalSupply(), totalSupply_);
        assertEq(tkn.balanceOf(beneficiary_), totalSupply_);
    }

    function testBurn(uint256 burnAmount) public {
        burnAmount = bound(burnAmount, 1, totalSupply);

        vm.prank(beneficiary);
        token.burn(burnAmount);

        assertEq(token.totalSupply(), totalSupply - burnAmount);
        assertEq(token.balanceOf(beneficiary), totalSupply - burnAmount);
    }

    function testApprove(address to, uint256 amount) public {
        vm.assume(to != address(0));
        assertTrue(token.approve(to, amount));

        assertEq(token.allowance(address(this), to), amount);
    }

    function testTransfer(address to, uint256 amount) public {
        vm.assume(to != address(0));
        amount = bound(amount, 0, totalSupply);
        assertEq(token.balanceOf(beneficiary), totalSupply);

        vm.prank(beneficiary);
        assertTrue(token.transfer(to, amount));
        assertEq(token.totalSupply(), totalSupply);

        if (to == beneficiary) {
            assertEq(token.balanceOf(beneficiary), totalSupply);
        } else {
            assertEq(token.balanceOf(beneficiary), totalSupply - amount);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testTransferFrom(
        address to,
        address transferer,
        uint256 approval,
        uint256 amount
    ) public {
        vm.assume(to != address(0));
        vm.assume(transferer != address(0));
        amount = bound(amount, 0, totalSupply);
        amount = bound(amount, 0, approval);

        assertEq(token.balanceOf(beneficiary), totalSupply);

        vm.prank(beneficiary);
        token.approve(transferer, approval);

        vm.prank(transferer);
        assertTrue(token.transferFrom(beneficiary, to, amount));
        assertEq(token.totalSupply(), totalSupply);

        uint256 app = transferer == beneficiary || approval == type(uint256).max
            ? approval
            : approval - amount;
        assertEq(token.allowance(beneficiary, transferer), app);

        if (to == beneficiary) {
            assertEq(token.balanceOf(beneficiary), totalSupply);
        } else {
            assertEq(token.balanceOf(beneficiary), totalSupply - amount);
            assertEq(token.balanceOf(to), amount);
        }
    }

    function testFailTransferInsufficientBalance(
        address to,
        uint256 sendAmount
    ) public {
        vm.assume(to != address(0));
        sendAmount = bound(sendAmount, totalSupply + 1, type(uint256).max);

        assertEq(token.balanceOf(beneficiary), totalSupply);
        vm.prank(beneficiary);
        token.transfer(to, sendAmount);
    }

    function testFailTransferFromInsufficientAllowance(
        address to,
        uint256 approval,
        uint256 amount
    ) public {
        vm.assume(to != beneficiary);
        vm.assume(to != address(0));
        approval = bound(approval, 0, totalSupply);
        amount = bound(amount, approval + 1, type(uint256).max);

        address transferer = address(0xABCD);

        assertEq(token.balanceOf(beneficiary), totalSupply);

        vm.prank(beneficiary);
        token.approve(transferer, approval);

        vm.prank(transferer);
        token.transferFrom(beneficiary, to, amount);
    }

    function testFailTransferFromInsufficientBalance(
        address to,
        uint256 sendAmount
    ) public {
        vm.assume(to != beneficiary);
        vm.assume(to != address(0));
        sendAmount = bound(sendAmount, totalSupply + 1, type(uint256).max);

        address transferer = address(0xABCD);

        vm.prank(beneficiary);
        token.approve(transferer, sendAmount);

        vm.prank(transferer);
        token.transferFrom(transferer, to, sendAmount);
    }
}
