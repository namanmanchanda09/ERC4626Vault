//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/DiamondHands.sol";
import "../src/WETH.sol";
import "../src/USDC.sol";


contract DiamondHandsTest is Test {

    WETH public weth;
    USDC public usdc;
    DiamondHands public vault;

    function setUp() public {
        weth = new WETH();
        usdc = new USDC();
        vault = new DiamondHands(weth, address(usdc));
    }

    /**
    Calling "beforeEach()" before all tests
     */
    function beforeEach() internal {

        vm.startPrank(address(0xab));
        weth.mint(address(0xab), 300);
        weth.approve(address(vault), 300);
        vault.depositAsset(100);
        vault.depositAsset(100);
        vault.depositAsset(100);
        vm.stopPrank();

        vm.startPrank(address(0xcd));
        weth.mint(address(0xcd), 100);
        weth.approve(address(vault), 100);
        vault.depositAsset(100);
        vm.stopPrank();

        // mocking the yield by transferring some USDC to vault
        usdc.mint(address(vault), 1000);
    }

    /**
    Testing Deposits
     */
    function testDeposit() external {
        beforeEach();

        // Checking the total deposited WETH in vault
        assertEq(vault.totalAssets(), 400);
    }

    /**
    Testing Redeems
     */
    function testRedeem() external {

        beforeEach();

        vm.startPrank(address(0xab));
        vault.redeemAsset(50);
        
        // Checking the amount of redeemed WETH
        assertEq(weth.balanceOf(address(0xab)), 50);

        // Checking the amount of rewarded USDC
        assertEq(usdc.balanceOf(address(0xab)), 5);
    }
}











