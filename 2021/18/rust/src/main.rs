use std::fs;
use std::cmp::{max};

type NodeIndex = usize;

#[derive(Copy, Clone)]
enum TreeNodeType {
    Number,
    Pair
}

#[derive(Copy, Clone)]
struct TreeNode {
    node_type: TreeNodeType,
    parent: Option<NodeIndex>,
    left: Option<NodeIndex>,
    right: Option<NodeIndex>,
    value: Option<i32>,
}
impl Default for TreeNode {
    fn default() -> Self { TreeNode { node_type: TreeNodeType::Pair, parent: None, left: None, right: None, value: None } }
}

#[derive(Clone)]
struct Tree {
    nodes: Vec<TreeNode>,
    root: Option<NodeIndex>,
}
impl Default for Tree {
    fn default() -> Self {
        Tree {
            nodes: vec![ TreeNode::default() ],
            root: Some(0),
        }
    }
}

#[derive(Clone)]
enum BranchSelect {
    Left,
    Right,
}

fn tree_insert_child_node(tree: &mut Tree, node_index: NodeIndex, select: BranchSelect, new_node: TreeNode) -> NodeIndex {
    let new_index = tree.nodes.len();
    tree.nodes.push(new_node);
    let parent = &mut tree.nodes[node_index];
    if let TreeNodeType::Pair = parent.node_type {
        match select {
            BranchSelect::Left  => { parent.left  = Some(new_index); }
            BranchSelect::Right => { parent.right = Some(new_index); }
        }
    }
    return new_index;
}

fn parse_line_to_tree(line: &str) -> Tree {
    // create a tree and add the root node
    let mut tree = Tree::default();

    let mut current_node_index: NodeIndex = 0;
    let mut current_branch = BranchSelect::Left;

    // we already start with a root node, so we can skip the initial opening '['
    for c in line.chars().skip(1) {
        match c {
            '[' => {
                // create a new Pair node and attach to the current node as a child
                let node = &mut tree.nodes[current_node_index];
                node.node_type = TreeNodeType::Pair;

                let child_node = TreeNode{ node_type: TreeNodeType::Pair, parent: Some(current_node_index), ..Default::default()};
                current_node_index = tree_insert_child_node(&mut tree, current_node_index, current_branch, child_node);
                current_branch = BranchSelect::Left;
            },
            ']' => {
                // climb back up to the parent
                if let Some(parent_index) = tree.nodes[current_node_index].parent {
                    current_node_index = parent_index;
                } else { break; }
            },
            ',' => {
                current_branch = BranchSelect::Right;
                continue;
            },
            _   => {
                // create a new Number node and atach to the current node as a child
                let value: i32 = c.to_string().parse().unwrap();
                let new_node = TreeNode{ node_type: TreeNodeType::Number, parent: Some(current_node_index), value: Some(value), ..Default::default() };
                tree_insert_child_node(&mut tree, current_node_index, current_branch.clone(), new_node);
            },
        }
    }

    return tree;
}

/// carry out a depth first search and return the "Number" node immediately
/// after the passed node_index in the DFS preorder search.
fn tree_dfs_find_neighboring_numbers(tree: &Tree, node_index: NodeIndex)
    -> (Option<NodeIndex>, Option<NodeIndex>)
{
    let mut prev_index: Option<NodeIndex> = None;
    let mut next_index: Option<NodeIndex> = None;

    let mut last_visited: Option<NodeIndex> = None;
    let mut stack = vec![tree.root.unwrap()];
    while stack.len() > 0 {
        let head_index = stack.pop().unwrap();
        let head_node = &tree.nodes[head_index];

        if head_index == node_index {
            prev_index = last_visited;
            last_visited = Some(node_index);
            continue;
        }

        if matches!(head_node.node_type, TreeNodeType::Pair) {
            stack.push(head_node.right.unwrap());
            stack.push(head_node.left.unwrap());
        } else {
            if last_visited.is_some() && last_visited.unwrap() == node_index {
                next_index = Some(head_index);
                break;
            }
            last_visited = Some(head_index);
        }
    }

    return (prev_index, next_index);
}

fn tree_explode_node(tree: &mut Tree, node_index: NodeIndex) {
    let original_value_left: i32;
    let original_value_right: i32;
    {
        // exploding nodes are guaranteed by the task to have two "number" nodes as children
        let node = &tree.nodes[node_index];
        original_value_left  = tree.nodes[node.left.unwrap()].value.unwrap();
        original_value_right = tree.nodes[node.right.unwrap()].value.unwrap();
    }

    let (left, right) = tree_dfs_find_neighboring_numbers(&tree, node_index);
    if let Some(index) = left {
        let node = &mut tree.nodes[index];
        node.value = Some(node.value.unwrap() + original_value_left);
    }
    if let Some(index) = right {
        let node = &mut tree.nodes[index];
        node.value = Some(node.value.unwrap() + original_value_right);
    }

    // convert exploded node to a "Number"
    let node = &mut tree.nodes[node_index];
    node.node_type = TreeNodeType::Number;
    node.value = Some(0);
}

fn tree_reduce_subtree_explode(tree: &mut Tree, node_index: NodeIndex, depth: i32) -> bool {
    let node_type = tree.nodes[node_index].node_type;
    if matches!(node_type, TreeNodeType::Pair) {
        if depth == 4 {
            // println!("EXPLODE {}", node_index);
            tree_explode_node(tree, node_index);
            return true;
        }

        let left_index = tree.nodes[node_index].left.unwrap();
        if tree_reduce_subtree_explode(tree, left_index, depth + 1) { return true; }

        let right_index = tree.nodes[node_index].right.unwrap();
        if tree_reduce_subtree_explode(tree, right_index, depth + 1) { return true; }
    }

    return false;
}

fn tree_split_node(tree: &mut Tree, node_index: NodeIndex) {
    let node_value: i32;
    {
        let node = &mut tree.nodes[node_index];
        node_value = node.value.unwrap();
        node.node_type = TreeNodeType::Pair;
    }

    let left_value: i32 = node_value / 2;
    let left_node = TreeNode{ node_type: TreeNodeType::Number, parent: Some(node_index),
                              value: Some(left_value), ..Default::default() };
    tree_insert_child_node(tree, node_index, BranchSelect::Left, left_node);

    let right_value: i32 = node_value - left_value;
    let right_node = TreeNode{ node_type: TreeNodeType::Number, parent: Some(node_index),
                               value: Some(right_value), ..Default::default() };
    tree_insert_child_node(tree, node_index, BranchSelect::Right, right_node);
}

fn tree_reduce_subtree_split(tree: &mut Tree, node_index: NodeIndex) -> bool {
    let node_type = tree.nodes[node_index].node_type;
    if matches!(node_type, TreeNodeType::Number) {
        let node = &tree.nodes[node_index];
        if node.value.unwrap() > 9 {
            // println!("SPLIT {}", node_index);
            tree_split_node(tree, node_index);
            return true;
        }
    } else {
        let left_index = tree.nodes[node_index].left.unwrap();
        if tree_reduce_subtree_split(tree, left_index) { return true; }

        let right_index = tree.nodes[node_index].right.unwrap();
        if tree_reduce_subtree_split(tree, right_index) { return true; }
    }

    return false;
}

fn tree_reduce(tree: &mut Tree) {
    loop {
        // print_tree(&tree);
        if !tree_reduce_subtree_explode(tree, tree.root.unwrap(), 0) {
            if !tree_reduce_subtree_split(tree, tree.root.unwrap()) {
                break;
            }
        }
    }
}

fn tree_add(tree: &mut Tree, other: &Tree) {
    let first_index = tree.nodes.len();
    for node in &other.nodes {
        let mut new_node = node.clone();

        if let Some(parent_index) = new_node.parent {
            new_node.parent = Some(parent_index + first_index);
        }
        if let Some(left_index) = new_node.left {
            new_node.left = Some(left_index + first_index);
        }
        if let Some(right_index) = new_node.right {
            new_node.right = Some(right_index + first_index);
        }

        tree.nodes.push(new_node);
    }

    let new_root_index = tree.nodes.len();

    let left_root_node = &mut tree.nodes[tree.root.unwrap()];
    left_root_node.parent = Some(new_root_index);

    let right_root_index_new = other.root.unwrap() + first_index;
    let right_root_node = &mut tree.nodes[right_root_index_new];
    right_root_node.parent = Some(new_root_index);

    let new_root_node = TreeNode{ node_type: TreeNodeType::Pair, parent: None,
                                  left: tree.root,
                                  right: Some(right_root_index_new),
                                  ..Default::default() };
    tree.nodes.push(new_root_node);
    tree.root = Some(new_root_index);

    // print!("ADDED ");
    // print_tree(&tree);
}

fn tree_subtree_magnitude(tree: &Tree, node_index: NodeIndex) -> i32 {
    let node = &tree.nodes[node_index];
    if matches!(node.node_type, TreeNodeType::Number) {
        return node.value.unwrap();
    } else {
        return 3 * tree_subtree_magnitude(tree, node.left.unwrap()) +
               2 * tree_subtree_magnitude(tree, node.right.unwrap());
    }
}

#[allow(dead_code)]
fn print_tree_node(tree: &Tree, node_index: NodeIndex) {
    let node = &tree.nodes[node_index];
    if let TreeNodeType::Number = node.node_type {
        print!("{}", node.value.unwrap());
    } else {
        print!("[");
        print_tree_node(tree, node.left.unwrap());
        print!(",");
        print_tree_node(tree, node.right.unwrap());
        print!("]");
    }
}

#[allow(dead_code)]
fn print_tree(tree: &Tree) {
    print!("TREE :: ");
    assert!(tree.root.is_some());
    print_tree_node(tree, tree.root.unwrap());

    print!("\n");
}

fn part1(contents: &String) {
    let mut result: Tree = parse_line_to_tree(contents.lines().nth(0).unwrap());

    for line in contents.lines().skip(1) {
        let tree = parse_line_to_tree(&line);
        tree_add(&mut result, &tree);
        tree_reduce(&mut result);
    }

    print!("Final tree is: ");
    print_tree(&result);
    let magnitude = tree_subtree_magnitude(&result, result.root.unwrap());

    println!("PART1: final magnitude: {}", magnitude);
}

fn part2(contents: &String) {
    let mut trees = Vec::<Tree>::new();
    for line in contents.lines() {
        let tree = parse_line_to_tree(&line);
        trees.push(tree);
    }

    let mut max_magnitude: i32 = i32::MIN;
    for i in 0..trees.len() {
        for j in i+1..trees.len() {
            {
                let mut result = trees[i].clone();
                tree_add(&mut result, &trees[j]);
                tree_reduce(&mut result);
                let magnitude = tree_subtree_magnitude(&result, result.root.unwrap());
                max_magnitude = max(max_magnitude, magnitude);
            }

            {
                let mut result = trees[j].clone();
                tree_add(&mut result, &trees[i]);
                tree_reduce(&mut result);
                let magnitude = tree_subtree_magnitude(&result, result.root.unwrap());
                max_magnitude = max(max_magnitude, magnitude);
            }
        }
    }


    println!("PART2: max magnitude: {}", max_magnitude);
}

fn main() {
    let filename = "../input.txt";
    // let filename = "../test6.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    part1(&contents);
    part2(&contents);
}
