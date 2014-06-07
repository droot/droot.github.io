---
layout: post
title: "Deserialize a binary search tree from an inorder sequence"
date: 2014-08-07 21:20:23
---

A friend of mine asked me about the ways a binary search tree (BST henceforth) could be transferred over the network. There are many ways to do so but I found one approach worth discussing here. BST can be serialized by  storing the BST in pre-order or in-order sequence and then wired over the network and then reconstructed by deserializing the sequence. Deserialization from a pre-order sequence is pretty straight forward but deserializing a in-order sequence in to BST is worth a blog post, so I decided to post it here.  I have been spending some time with Python for sometime so decided to give a try (The fact is that I find Python to be really cool).

> DISCLAIMER: I am not a Python expert, so please do not expect perfect pythonic code here :)

It is being assumed that an in-order sequence will be given as input to be de-serialized.

Defined a class TreeNode to capture a  properties of tree node.

>
>     def __init__(self, val):
>               self.val = val
>               self.left = None
>               self.right = None

We can use famous Divide and Conquer philosophy to solve this problem by building first the left sub-tree, then right-subtree and then combining the two to create the complete tree. Here is the recursive function.

>
>     def build_tree(sequence, low, high):
>             if low > high:
>
>
>     return None
>             if low == high:
>                       return TreeNode(sequence[low])
>             mid = (low + high)/2
>             node = TreeNode(sequence[mid])
>             node.left = build_tree(sequence, low, mid -1)
>             node.right = build_tree(sequence, mid + 1, high)
>             return node

Recursive function to print the content of the tree in in-order sequence.

>
>     def traverse(node):
>             if not node:
>                return
>             traverse(node.left)
>             print node.val,
>             traverse(node.right)

Finally lets test out the code with following inorder sequence. Currently, we do not check if the input sequence if indeed a sorted sequence or not.

>
>     if __name__ == "__main__":
>              sequence = [8, 10, 11, 12, 14, 18, 20]
>             tree = build_tree(sequence, 0, len(sequence) -1)
>             traverse(tree)

Do share your views about it.