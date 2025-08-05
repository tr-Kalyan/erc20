pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "../src/ERC20Mock.sol";
import {IERC20Errors} from "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20Mock public token;
    address public owner = address(this);  // Test contract as owner 


    function setUp() public {
        token = new ERC20Mock("TestToken", "TST", 18);
    }


    function testMetaDat() public view {
        assertEq(token.name(), "TestToken");
        assertEq(token.symbol(), "TST");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 0); 
    }

    function testMintAndTransfer() public {
        uint256 amount = 1000;
        token.mint(owner,amount);
        assertEq(token.balanceOf(owner), amount);
        assertEq(token.totalSupply(), amount);

        address recipient = address(0x123);
        token.transfer(recipient, 500);
        assertEq(token.balanceOf(owner), 500);
        assertEq(token.balanceOf(recipient), 500);
    }

    function testApprovedAndTransferFrom() public {
        uint256 amount = 1000;
        token.mint(owner, amount);

        address spender = address(0x456);
        token.approve(spender, 600);
        assertEq(token.allowance(owner, spender), 600);

        vm.prank(spender);  // Simulate spender call 
        token.transferFrom(owner, spender, 400);
        assertEq(token.balanceOf(owner), 600);
        assertEq(token.balanceOf(spender), 400);
        assertEq(token.allowance(owner, spender), 200);
    }

    function testIncreaseDecreaseAllowance() public {
        address spender = address(0x456);
        token.approve(spender, 100);
        token.increaseAllowance(spender, 50);
        assertEq(token.allowance(owner, spender), 150);

        token.decreaseAllowance(spender, 30);
        assertEq(token.allowance(owner, spender), 120);
    }

    function testReverts() public {

        token.mint(owner, 100);

        
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.transfer(address(0), 1);

        
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, owner, 100, 101));
        token.transfer(address(0x123), 101);

        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(0x456), 0, 1));
        vm.prank(address(0x456));
        token.transferFrom(owner, address(0x456), 1);

        // Zero transfer ok
        token.transfer(address(0x123), 0);
    }

    // For the race test
    function testApprovalRace() public {
        token.approve(address(0x456), 100);
        // Sim race: Change approval
        token.approve(address(0x456), 50);
        vm.prank(address(0x456));
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(0x456), 50, 100));
        token.transferFrom(owner, address(0x456), 100); // Fails on old amount
    }

    function testBurn() public {
        token.mint(owner, 1000);
        token.burn(owner, 500);
        assertEq(token.balanceOf(owner), 500);
        assertEq(token.totalSupply(), 500);
    }

    function testSelfTransfer() public {
        token.mint(owner, 100);
        token.transfer(owner, 50); // Ok, but no change
        assertEq(token.balanceOf(owner), 100);
    }

}