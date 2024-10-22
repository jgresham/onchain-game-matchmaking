// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../src/RBTree.sol";

contract RBTreeTest is Test {
    RBTree.Tree rbtree;

    function setUp() public {
        rbtree.root = RBTree.EMPTY;
    }

    function testEmptyTree() public view {
        assertEq(RBTree.first(rbtree), RBTree.EMPTY);
        assertEq(RBTree.last(rbtree), RBTree.EMPTY);
    }

    function testInsertOneNode() public {
        RBTree.insert(rbtree, address(0x1), 1);
        assertEq(RBTree.first(rbtree), address(0x1));
        assertEq(RBTree.last(rbtree), address(0x1));
    }
}
