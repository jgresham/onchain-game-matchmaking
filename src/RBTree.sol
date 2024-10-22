// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.24;

// ----------------------------------------------------------------------------
// BokkyPooBah's Red-Black Tree Library v1.0-pre-release-a
//
// A Solidity Red-Black Tree binary search library to store and access a sorted
// list of unsigned integer data. The Red-Black algorithm rebalances the binary
// search tree, resulting in O(log n) insert, remove and search time (and ~gas)
//
// https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.
// ----------------------------------------------------------------------------
library RBTree {
    struct Node {
        address key;
        uint256 value;
        address parent;
        address left;
        address right;
        bool red;
    }

    struct Tree {
        address root;
        mapping(address => Node) nodes;
    }

    address public constant EMPTY = address(0);

    /**
     * @notice Get the smallest value node in the tree
     * @param self The tree
     * @return _key The smallest value node
     */
    function first(Tree storage self) internal view returns (address _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].left != EMPTY) {
                _key = self.nodes[_key].left;
            }
        }
    }

    function last(Tree storage self) internal view returns (address _key) {
        _key = self.root;
        if (_key != EMPTY) {
            while (self.nodes[_key].right != EMPTY) {
                _key = self.nodes[_key].right;
            }
        }
    }

    /**
     * @notice Get the next node in the tree by value (ex. min in right subtree)
     * @param self The tree
     * @param target The target node
     * @return cursor The next node
     */
    function next(Tree storage self, address target) internal view returns (address cursor) {
        require(target != EMPTY, "Target cannot be empty");
        if (self.nodes[target].right != EMPTY) {
            cursor = treeMinimum(self, self.nodes[target].right);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].right) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function prev(Tree storage self, address target) internal view returns (address cursor) {
        require(target != EMPTY, "Target cannot be empty");
        if (self.nodes[target].left != EMPTY) {
            cursor = treeMaximum(self, self.nodes[target].left);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].left) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function exists(Tree storage self, address key) internal view returns (bool) {
        return (key != EMPTY) && ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }

    function isEmpty(address key) internal pure returns (bool) {
        return key == EMPTY;
    }

    function getEmpty() internal pure returns (address) {
        return EMPTY;
    }

    function getNode(Tree storage self, address key)
        internal
        view
        returns (address _returnKey, uint256 _value, address _parent, address _left, address _right, bool _red)
    {
        require(exists(self, key), "Node does not exist");
        return (
            key,
            self.nodes[key].value,
            self.nodes[key].parent,
            self.nodes[key].left,
            self.nodes[key].right,
            self.nodes[key].red
        );
    }

    function insert(Tree storage self, address key, uint256 value) internal {
        require(key != EMPTY, "Key cannot be empty");
        require(!exists(self, key), "Key already exists");
        address cursor = EMPTY;
        address probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (value < self.nodes[probe].value) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key] = Node({key: key, value: value, parent: cursor, left: EMPTY, right: EMPTY, red: true});
        if (cursor == EMPTY) {
            self.root = key;
        } else if (value < self.nodes[cursor].value) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        insertFixup(self, key);
    }

    function remove(Tree storage self, address key) internal {
        require(key != EMPTY, "Key cannot be empty");
        require(exists(self, key), "Key does not exist");
        address probe;
        address cursor;
        if (self.nodes[key].left == EMPTY || self.nodes[key].right == EMPTY) {
            cursor = key;
        } else {
            cursor = self.nodes[key].right;
            while (self.nodes[cursor].left != EMPTY) {
                cursor = self.nodes[cursor].left;
            }
        }
        if (self.nodes[cursor].left != EMPTY) {
            probe = self.nodes[cursor].left;
        } else {
            probe = self.nodes[cursor].right;
        }
        address yParent = self.nodes[cursor].parent;
        self.nodes[probe].parent = yParent;
        if (yParent != EMPTY) {
            if (cursor == self.nodes[yParent].left) {
                self.nodes[yParent].left = probe;
            } else {
                self.nodes[yParent].right = probe;
            }
        } else {
            self.root = probe;
        }
        bool doFixup = !self.nodes[cursor].red;
        if (cursor != key) {
            replaceParent(self, cursor, key);
            self.nodes[cursor].left = self.nodes[key].left;
            self.nodes[self.nodes[cursor].left].parent = cursor;
            self.nodes[cursor].right = self.nodes[key].right;
            self.nodes[self.nodes[cursor].right].parent = cursor;
            self.nodes[cursor].red = self.nodes[key].red;
            (cursor, key) = (key, cursor);
        }
        if (doFixup) {
            removeFixup(self, probe);
        }
        delete self.nodes[cursor];
    }

    function treeMinimum(Tree storage self, address key) private view returns (address) {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }

    function treeMaximum(Tree storage self, address key) private view returns (address) {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(Tree storage self, address key) private {
        address cursor = self.nodes[key].right;
        address keyParent = self.nodes[key].parent;
        address cursorLeft = self.nodes[cursor].left;
        self.nodes[key].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].left) {
            self.nodes[keyParent].left = cursor;
        } else {
            self.nodes[keyParent].right = cursor;
        }
        self.nodes[cursor].left = key;
        self.nodes[key].parent = cursor;
    }

    function rotateRight(Tree storage self, address key) private {
        address cursor = self.nodes[key].left;
        address keyParent = self.nodes[key].parent;
        address cursorRight = self.nodes[cursor].right;
        self.nodes[key].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].right) {
            self.nodes[keyParent].right = cursor;
        } else {
            self.nodes[keyParent].left = cursor;
        }
        self.nodes[cursor].right = key;
        self.nodes[key].parent = cursor;
    }

    function insertFixup(Tree storage self, address key) private {
        address cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            address keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                        key = keyParent;
                        rotateLeft(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateRight(self, self.nodes[keyParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                        key = keyParent;
                        rotateRight(self, key);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateLeft(self, self.nodes[keyParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(Tree storage self, address a, address b) private {
        address bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function removeFixup(Tree storage self, address key) private {
        address cursor;
        while (key != self.root && !self.nodes[key].red) {
            address keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateLeft(self, keyParent);
                    cursor = self.nodes[keyParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[keyParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, keyParent);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateRight(self, keyParent);
                    cursor = self.nodes[keyParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[keyParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, keyParent);
                    key = self.root;
                }
            }
        }
        self.nodes[key].red = false;
    }

    /**
     * @notice Find the node with the value closest to or equal to minValue, going to the leftmost node.
     * @param self The tree
     * @param minValue The target minimum value
     * @return closest The address of the node with the closest value
     */
    function findLowestNodeToValue(Tree storage self, uint256 minValue) internal view returns (address closest) {
        address current = self.root;
        closest = EMPTY; // Initialize as EMPTY

        while (current != EMPTY) {
            if (self.nodes[current].value >= minValue) {
                // If current node's value is greater than or equal to minValue,
                // it might be a candidate for the closest match.
                closest = current;
                current = self.nodes[current].left; // Move to the left subtree to find a smaller value
            } else {
                // If the current node's value is less than minValue, move right.
                current = self.nodes[current].right;
            }
        }
    }

    /**
     * @notice Find the first n nodes in the tree that are within the given range
     * @param self The tree
     * @param n The number of nodes to find
     * @param minValue The minimum value
     * @param maxValue The maximum value
     * @return nodes The nodes in the range
     */
    function findNodesInRange(Tree storage self, uint256 n, uint256 minValue, uint256 maxValue)
        public
        view
        returns (address[] memory)
    {
        // todo: find "lowest" value by minValue first then call next() and iterate?
        address[] memory nodes = new address[](n);
        uint256 count = 0;
        address cursor = findLowestNodeToValue(self, minValue);
        while (cursor != EMPTY && count < n) {
            if (self.nodes[cursor].value >= minValue && self.nodes[cursor].value <= maxValue) {
                nodes[count] = cursor;
                count++;
            }
            if (self.nodes[cursor].value < minValue) {
                cursor = self.nodes[cursor].right;
            } else if (self.nodes[cursor].value > maxValue) {
                cursor = self.nodes[cursor].left;
            } else {
                cursor = next(self, cursor);
                // if the next value is greater than maxValue, break because the current cursor
                // is already within the range. So it is the last in the range, if the next() is out of range.
                if (self.nodes[cursor].value > maxValue) {
                    break;
                }
            }
        }
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = nodes[i];
        }
        return result;

        // iterative approach chat
        // require(minValue <= maxValue, "Invalid range");
        // address[] memory result = new address[](n); // Initialize result array
        // uint256 count = 0;

        // address[] memory stack = new address[](n); // Stack for iterative traversal
        // uint256 stackPointer = 0; // Points to the top of the stack
        // address current = self.root;

        // // Iterative in-order traversal with range checks
        // while (stackPointer > 0 || current != EMPTY) {
        //     // Traverse left while skipping nodes that are too large
        //     while (current != EMPTY) {
        //         if (self.nodes[current].value >= minValue) {
        //             // Push nodes only if they can potentially be in the range
        //             stack[stackPointer] = current;
        //             stackPointer++;
        //             current = self.nodes[current].left;
        //         } else {
        //             // Skip left subtree if current node value is smaller than minValue
        //             current = self.nodes[current].right;
        //         }
        //     }

        //     // Pop from the stack
        //     stackPointer--;
        //     current = stack[stackPointer];

        //     Node storage currentNode = self.nodes[current];

        //     // If current node is in range, add it to the result
        //     if (currentNode.value >= minValue && currentNode.value <= maxValue) {
        //         result[count] = currentNode.key;
        //         count++;

        //         // Stop if we found enough nodes
        //         if (count == n) {
        //             return result;
        //         }
        //     }

        //     // Skip the right subtree if current node value is larger than maxValue
        //     if (currentNode.value <= maxValue) {
        //         current = currentNode.right;
        //     } else {
        //         current = EMPTY;
        //     }
        // }

        // return result; // If fewer than n nodes are found, return as many as we found

        // recursive approach
        // require(minValue <= maxValue, "Invalid range");
        // address[] memory result = new address[](n); // Initialize array for the result
        // uint256 count = 0; // Keep track of found nodes

        // // Helper function to perform in-order traversal and collect nodes in range
        // function _findInRange(address node) internal view {
        //     if (node == EMPTY || count >= n) {
        //         return; // Stop if node is empty or enough nodes found
        //     }

        //     Node storage currentNode = self.nodes[node];

        //     // Traverse the left subtree
        //     if (currentNode.left != EMPTY) {
        //         _findInRange(currentNode.left);
        //     }

        //     // Check if the current node is within the range
        //     if (currentNode.value >= minValue && currentNode.value <= maxValue && count < n) {
        //         result[count] = currentNode.key;
        //         count++;
        //     }

        //     // Traverse the right subtree
        //     if (currentNode.right != EMPTY && count < n) {
        //         _findInRange(currentNode.right);
        //     }
        // }

        // // Start from the root node and search
        // _findInRange(self.root);
        // return result;
    }
}
