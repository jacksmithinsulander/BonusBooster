// SPDX-License-Identifier: ISC
pragma solidity 0.8.27;

/* BonusBooster Contract */
import {BonusBooster} from "src/BonusBooster.sol";

/* Bonus Libraries */
import {BonusErrors} from "src/libraries/BonusErrors.sol";
import {ContractCheck} from "src/libraries/ContractCheck.sol";

/* Mock Contracts */
import {MockToken} from "test/mock/MockToken.sol";

/* Forge std */
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract BonusBoosterTest is Test {
    using ContractCheck for address;

    address alice;
    address bob;
    address bonusDeployer;
    MockToken token;
    BonusBooster booster;

    function setUp() external {
        bonusDeployer = address(69);
        alice = address(420);
        bob = address(666);

        vm.startPrank(bonusDeployer);
        token = new MockToken();
        booster = new BonusBooster("imgur.com/");
        vm.stopPrank();

        vm.prank(alice);
        token.mint(1e18);

        assertEq(token.balanceOf(alice), 1e18);
    }

    function test_globalVars() external view {
        assertEq(booster.name(), "Bonus Booster", "Issues displaying name");
        assertEq(booster.symbol(), "BB", "Issues displaying ticker");
        //assertEq(booster.getTokenAddress(), address(token), "Issues fetching token address");
    }

    function test_mint() external {
        assertEq(booster.balanceOf(alice), 0, "Alice balance does not start at 0");
        assertFalse(booster.mintStatusOf(alice), "Alice mintstatus does not start as false");

        // Alice owns tokens and therefor she should be able to mint
        vm.startPrank(alice);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(alice), 1, "Alice balance has not updated correctly");
        assertEq(booster.ownerOf(1), alice, "Alice does not read as owner correctly");
        assertEq(booster.tokenURI(1), "imgur.com/1", "Alice uri not correct");
        assertTrue(booster.mintStatusOf(alice), "Alice mintstatus is not correctly updated");

        // Alice has already minted her booster, and therefor she should not be able to mint again
        vm.startPrank(alice);
        vm.expectRevert(BonusErrors.ALREADY_MINTED.selector);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 0, "Bobs balance does not start at 0");
        assertFalse(booster.mintStatusOf(bob), "Bobs mintstatus does not start as false");

        // Bob does not own any tokens and therefor it should revert
        vm.startPrank(bob);
        //vm.expectRevert(BonusErrors.YOU_DO_NOT_OWN_ANY_OP.selector);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 0, "Bobs balance updated wrongly");
        assertFalse(booster.mintStatusOf(bob), "Bobs mintstatus is falsely updated");

        vm.startPrank(bob);
        token.mint(1);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 1, "Bob balance has not updated correctly");
        assertEq(booster.ownerOf(2), bob, "Bob does not read as owner correctly");
        assertEq(booster.tokenURI(2), "imgur.com/2", "Bob uri not correct");
        assertTrue(booster.mintStatusOf(alice), "Bobs mintstatus is not correctly updated");
    }

    function test_boost() external {
        assertEq(booster.balanceOf(alice), 0, "Alice balance does not start at 0");

        // Alice owns tokens and therefor she should be able to mint
        vm.startPrank(alice);

        // Try to burn, should revert because alice dont hold any tokens
        vm.expectRevert(BonusErrors.YOU_DONT_OWN_ANY_BOOSTER.selector);
        booster.boost(1);

        // Mint
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(alice), 1, "Alice balance has not updated correctly");
        assertEq(booster.ownerOf(1), alice, "Alice does not read as owner correctly");
        assertEq(booster.tokenURI(1), "imgur.com/1", "Alice uri not correct");

        // Alice has already minted her booster, and therefor she should not be able to mint again
        vm.startPrank(alice);
        vm.expectRevert(BonusErrors.ALREADY_MINTED.selector);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 0, "Bobs balance does not start at 0");

        // Bob does not own any tokens and therefor it should revert
        vm.startPrank(bob);
        // Try to burn, should revert because bob dont hold any tokens
        vm.expectRevert(BonusErrors.YOU_DONT_OWN_ANY_BOOSTER.selector);
        booster.boost(0);

        //vm.expectRevert(BonusErrors.YOU_DO_NOT_OWN_ANY_OP.selector);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 0, "Bobs balance updated wrongly");

        vm.startPrank(bob);
        token.mint(1);
        booster.mintBooster();
        vm.stopPrank();

        assertEq(booster.balanceOf(bob), 1, "Bob balance has not updated correctly");
        assertEq(booster.ownerOf(2), bob, "Bob does not read as owner correctly");
        assertEq(booster.tokenURI(2), "imgur.com/2", "Bob uri not correct");

        vm.startPrank(alice);
        // Try index alice dont own
        vm.expectRevert(BonusErrors.NOT_YOUR_BOOSTER.selector);
        booster.boost(2);

        // Then do it for real with the index she owns
        booster.boost(1);
        vm.stopPrank();

        assertEq(booster.balanceOf(alice), 0, "Alice balance does not start at 0");
        assertTrue(booster.mintStatusOf(alice), "Alice minststatus updated to false wrongly");

        vm.expectRevert();
        booster.ownerOf(1);
    }

    function test_updateUri() external {
        vm.prank(alice);
        booster.mintBooster();

        assertEq(booster.tokenURI(1), "imgur.com/1", "tokenUri faulty");

        vm.startPrank(alice);
        vm.expectRevert();
        booster.resetBaseUri("myspace.com/");
        vm.stopPrank();

        vm.startPrank(bonusDeployer);
        booster.resetBaseUri("myspace.com/");
        vm.stopPrank();

        assertNotEq(booster.tokenURI(1), "imgur.com/1", "tokenUri did not update");

        assertEq(booster.tokenURI(1), "myspace.com/1", "something wrong with new token uri");
    }

    function test_resetTokenAddress(address _notContract) external {
        vm.assume(!_notContract.isContract());

        vm.startPrank(bonusDeployer);
        vm.expectRevert(BonusErrors.NOT_A_CONTRACT.selector);
        //booster.resetTokenAddress(_notContract);
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert();
        //booster.resetTokenAddress(_notContract);
        vm.stopPrank();

        vm.startPrank(bonusDeployer);
        MockToken newToken = new MockToken();
        //booster.resetTokenAddress(address(newToken));
        vm.stopPrank();

        //assertEq(booster.getTokenAddress(), address(newToken), "Token address not correctly updated");
    }
}