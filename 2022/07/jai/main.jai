// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";
#import "Sort";

// from ../../../jai-common
#import "file";
#import "string";

advance :: (s: string, count: u64) -> string {
    new_string := s;
    new_string.data += count;
    new_string.count -= xx count;
    return new_string;
}

Node_Type :: enum {
    File;
    Directory;
}

Node :: struct {
    parent: *Node;
    full_path: string;

    type: Node_Type;
    union {
        file: struct {
            name: string;
            size: s64;
        }
        dir: struct {
            name: string;
            dir_children: [..]*Node;
            file_children: [..]*Node;
            total_size: s64;
        }
    }

    // DEBUG
    depth: s64;
}

make_directory_node :: (name: string, parent: *Node) -> *Node {
    node := New(Node, allocator=temp);
    node.parent   = parent;
    node.type     = .Directory;
    node.dir.name = name;

    if (parent != null) {
        assert(parent.type == .Directory);
        array_add(*parent.dir.dir_children, node);
        node.full_path = tprint("%/%", trim_right(parent.full_path, "/"), name);
        node.depth = parent.depth + 1;
    } else {
        node.full_path = name;
        node.depth = 0;
    }

    return node;
}

make_file_node :: (name: string, size: s64, parent: *Node) -> *Node {
    assert(parent != null && parent.type == .Directory);

    node := New(Node, allocator=temp);
    node.parent    = parent;
    node.type      = .File;
    node.file.name = name;
    node.file.size = size;
    node.depth     = parent.depth + 1;

    array_add(*parent.dir.file_children, node);

    return node;
}

tree_dfs :: (root: *Node, body: Code, flags: For_Flags) #expand {
    queue: [..]*Node;
    array_add(*queue, root);

    node_counter := 0;
    while queue {
        node := pop(*queue);

        `it := node;
        `it_index := node_counter;
        node_counter += 1;

        for node.dir.dir_children {
            array_add(*queue, it);
        }

        #insert body;
    }
}

construct_tree_from_log_string :: (contents: File_Contents) -> (root: *Node) {
    root := make_directory_node("/", null);
    current := root;

    // construct tree
    for line: contents {
        if line[0] == #char "$" {
            found, cmd, args := split_from_left(advance(line, 2), " ");
            if cmd == "cd" {
                if args == ".." {
                    if current.parent  current = current.parent;
                } else if (args[0] == #char "/") {
                    assert(args.count == 1); // absolute paths not supported
                    current = root;
                } else {
                    found := false;
                    for current.dir.dir_children {
                        if it.dir.name == args {
                            found = true;
                            current = it;
                            break;
                        }
                    }
                    if !found
                        current = make_directory_node(args, current);
                }
            }
        } else {
            _, file_size, name := split_from_left(line, " ");
            if file_size == "dir" {
                make_directory_node(name, current);
            } else {
                make_file_node(name, to_integer(file_size), current);
            }
        }
    }

    // calculate directory sizes
    for :tree_dfs root {
        // calculate size of immediate file children
        total_size_of_files := 0;
        for it.dir.file_children {
            total_size_of_files += it.file.size;
        }
        it.dir.total_size += total_size_of_files;

        // propagate upwards
        cur := it;
        while cur.parent != null {
            cur.parent.dir.total_size += total_size_of_files;
            cur = cur.parent;
        }
    }

    return root;
}

print_tree :: (root: *Node) {
    for :tree_dfs root {
        for i: 1..it.depth print("  ");
        print("DIR: % %\n", it.dir.total_size, it.full_path);

        for it.dir.file_children {
            for i: 1..it.depth print("  ");
            print("FILE: % %\n", it.file.size, it.file.name);
        }
    }
}

part_1 :: (root: *Node) {
    sum := 0;
    for :tree_dfs root {
        if it.dir.total_size <= 100000
            sum += it.dir.total_size;
    }

    print("part1: %\n", sum);
}

part_2 :: (root: *Node) {
    dir_sizes: [..]s64;
    for :tree_dfs root {
        array_add(*dir_sizes, it.dir.total_size);
    }

    needed_size := 30000000 - (70000000 - root.dir.total_size);
    sorted := quick_sort(dir_sizes, (x,y)=>x-y);
    for sorted {
        if it >= needed_size {
            print("part2: %\n", it);
            break;
        }
    }
}


main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    filesystem_root := construct_tree_from_log_string(file_contents);
    print_tree(filesystem_root);

    part_1(filesystem_root);
    part_2(filesystem_root);
}
