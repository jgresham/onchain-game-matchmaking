// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "../src/RBTree.sol";

// forge test -vvvv --gas-limit 3000000000 --match-path "*RBTree**"
contract RBTreeTest is Test {
    RBTree.Tree rbtree;
    RBTree.Tree rbtree10k;

    function setUp() public {
        rbtree.root = RBTree.EMPTY;
        rbtree10k.root = RBTree.EMPTY;
        for (uint256 i = 1; i < 10000; i++) {
            RBTree.insert(rbtree10k, address(uint160(i)), i);
        }
        console.log("setUp");
    }

    function testEmptyTree() public view {
        assertEq(RBTree.first(rbtree), RBTree.EMPTY);
        assertEq(RBTree.last(rbtree), RBTree.EMPTY);
        assertEq(RBTree.findNodesInRange(rbtree, 1, 0, 1).length, 0);
        assertEq(RBTree.findNodesInRange(rbtree, 10, 0, 10000).length, 0);
    }

    function testInsertOneNode() public {
        RBTree.insert(rbtree, address(0x1), 1);
        assertEq(RBTree.first(rbtree), address(0x1));
        assertEq(RBTree.last(rbtree), address(0x1));
        assertEq(RBTree.findNodesInRange(rbtree, 1, 0, 1).length, 1);
        assertEq(RBTree.findNodesInRange(rbtree, 10, 0, 10000).length, 1);
        RBTree.remove(rbtree, address(0x1));
        assertEq(RBTree.first(rbtree), RBTree.EMPTY);
        assertEq(RBTree.last(rbtree), RBTree.EMPTY);
        assertEq(RBTree.findNodesInRange(rbtree, 1, 0, 1).length, 0);
        assertEq(RBTree.findNodesInRange(rbtree, 10, 0, 10000).length, 0);
    }

    function testInsertTwoNodes() public {
        RBTree.insert(rbtree, address(0x1), 1);
        RBTree.insert(rbtree, address(0x2), 2);
        assertEq(RBTree.first(rbtree), address(0x1));
        assertEq(RBTree.last(rbtree), address(0x2));
        assertEq(RBTree.findNodesInRange(rbtree, 1, 0, 1).length, 1);
        assertEq(RBTree.findNodesInRange(rbtree, 1, 0, 2).length, 1);
        assertEq(RBTree.findNodesInRange(rbtree, 2, 0, 2).length, 2);
        assertEq(RBTree.findNodesInRange(rbtree, 2, 1, 1).length, 1);
        assertEq(RBTree.findNodesInRange(rbtree, 2, 1, 2).length, 2);
        assertEq(RBTree.findNodesInRange(rbtree, 2, 2, 2).length, 1);
    }

    // early 10/22: gas: 1,005,711
    function testInsertTenNodes() public {
        // sequential insertions
        for (uint256 i = 1; i < 11; i++) {
            RBTree.insert(rbtree, address(uint160(i)), i);
        }
        assertEq(RBTree.first(rbtree), address(1));
        assertEq(RBTree.last(rbtree), address(10));

        // print tree
        // console.log("rbtree.root", rbtree.root);
        // for (uint256 i = 0; i < 10; i++) {
        //     console.log("rbtree.nodes[address(uint160(i + 1))].parent", rbtree.nodes[address(uint160(i + 1))].parent);
        //     console.log("rbtree.nodes[address(uint160(i + 1))].key", rbtree.nodes[address(uint160(i + 1))].key);
        //     console.log("rbtree.nodes[address(uint160(i + 1))].value", rbtree.nodes[address(uint160(i + 1))].value);

        //     console.log("rbtree.nodes[address(uint160(i + 1))].left", rbtree.nodes[address(uint160(i + 1))].left);
        //     console.log("rbtree.nodes[address(uint160(i + 1))].right", rbtree.nodes[address(uint160(i + 1))].right);
        // }
        address lowestNode = RBTree.findLowestNodeToValue(rbtree, 0);
        assertEq(lowestNode, address(1));
        lowestNode = RBTree.findLowestNodeToValue(rbtree, 1);
        assertEq(lowestNode, address(1));
        lowestNode = RBTree.findLowestNodeToValue(rbtree, 2);
        assertEq(lowestNode, address(2));
        lowestNode = RBTree.findLowestNodeToValue(rbtree, 4);
        assertEq(lowestNode, address(4));

        lowestNode = RBTree.findLowestNodeToValue(rbtree, 10);
        assertEq(lowestNode, address(10));
        // no node with value 11 or more
        lowestNode = RBTree.findLowestNodeToValue(rbtree, 11);
        assertEq(lowestNode, address(0));

        // test next
        address nextNode = RBTree.next(rbtree, address(1));
        assertEq(nextNode, address(2));
        nextNode = RBTree.next(rbtree, address(2));
        assertEq(nextNode, address(3));

        address[] memory nodes = RBTree.findNodesInRange(rbtree, 10, 0, 10);
        assertEq(nodes.length, 10);
        for (uint256 i = 0; i < 10; i++) {
            assertEq(nodes[i], address(uint160(i + 1)));
        }
        nodes = RBTree.findNodesInRange(rbtree, 2, 0, 1);
        assertEq(nodes[0], address(1));
        console.log("nodes[0]", nodes[0]);
        assertEq(nodes.length, 1);

        nodes = RBTree.findNodesInRange(rbtree, 3, 3, 8);
        assertEq(nodes[0], address(3));
        assertEq(nodes[1], address(4));
        assertEq(nodes[2], address(5));
        assertEq(nodes.length, 3);
    }

    // early 10/22: gas: 1,138,561,017
    // function testInsertTenThousandNodes() public {
    //     // sequential insertions
    //     for (uint256 i = 1; i < 10001; i++) {
    //         RBTree.insert(rbtree, address(uint160(i)), i);
    //     }
    //     assertEq(RBTree.first(rbtree), address(1));
    //     assertEq(RBTree.last(rbtree), address(10000));
    // }

    // early 10/22: gas: 301,352
    function testInsertTenThousandThNodeGreatestValue() public {
        RBTree.insert(rbtree10k, address(uint160(10000)), 10000);
        assertEq(RBTree.first(rbtree10k), address(1));
        assertEq(RBTree.last(rbtree10k), address(10000));
    }

    // early 10/22: gas: 268,463
    function testInsertTenThousand1stNodeMedianValue() public {
        RBTree.insert(rbtree10k, address(uint160(10001)), 5000);
        assertEq(RBTree.exists(rbtree10k, address(10001)), true);
        assertEq(RBTree.first(rbtree10k), address(1));
        assertEq(RBTree.last(rbtree10k), address(9999));
    }

    function testFindNodesInRange_0_n() public view {
        address[] memory nodes = RBTree.findNodesInRange(rbtree10k, 0, 1000, 1001);
        assertEq(nodes.length, 0);
    }

    function testFindNodesInRange_1_n() public view {
        address[] memory nodes = RBTree.findNodesInRange(rbtree10k, 1, 1000, 1001);
        assertEq(nodes.length, 1);
    }

    function testFindNodesInRange_2_n() public view {
        address[] memory nodes = RBTree.findNodesInRange(rbtree10k, 2, 1000, 1001);
        // assertTrue(nodes[0] >= 1000 && nodes[0] <= 1001);
        // assertTrue(nodes[1] >= 1000 && nodes[1] <= 1001);
        assertEq(nodes.length, 2);
        assertEq(nodes[0], address(1000));
        assertEq(nodes[1], address(1001));
    }

    function testFindNodesInRange_5_n_onlyTwoNodesExist() public view {
        address[] memory nodes = RBTree.findNodesInRange(rbtree10k, 3, 2000, 2001);
        console.log("rbtree10k.root", rbtree10k.root);
        console.log("nodes[0] value", rbtree10k.nodes[nodes[0]].value);
        console.log("nodes[1] value", rbtree10k.nodes[nodes[1]].value);
        // assertTrue(nodes[0] >= 1000 && nodes[0] <= 1001);
        // assertTrue(nodes[1] >= 1000 && nodes[1] <= 1001);
        // assertEq(nodes.length, 2);
        assertEq(nodes[0], address(2000));
        assertEq(nodes[1], address(2001));
    }

    // Test remove node not in tree
    function testRemoveNodeNotInTree() public {
        vm.expectRevert("Key does not exist");
        RBTree.remove(rbtree10k, address(10002));
        assertEq(RBTree.exists(rbtree10k, address(10002)), false);
    }
}
