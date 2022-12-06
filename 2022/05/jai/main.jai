// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Crate : Type : u8;
Stack : Type : [..]Crate;

deep_copy :: (stacks: []Stack) -> [..]Stack {
    stacks_copy: [..]Stack;
    array_reserve(*stacks_copy, stacks.count);
    for stack: stacks {
        new_stack: Stack;
        array_reserve(*new_stack, stack.count);
        for crate: stack {
            array_add(*new_stack, crate);
        }
        array_add(*stacks_copy, new_stack);
    }
    return stacks_copy;
}

Move :: struct {
    count, from, to: s64;
}

// DEBUG
print_stacks :: (stacks: []Stack) {
    tallest_count := 0;
    for stack: stacks {
        tallest_count = max(tallest_count, stack.count);
    }

    for i: 0..tallest_count-1 {
        for stack: stacks {
            if stack.count >= tallest_count - i {
                print_character(stack[tallest_count - 1 - i]);
            } else {
                print(" ");
            }
            print(" ");
        }
        print("\n");
    }
    for i: 1..stacks.count
        print("--");
    print("\n");
    for i: 1..stacks.count
        print("% ", i);
    print("\n");
}

do_move_one_at_a_time :: (stacks: *[..]Stack, move: Move) {
    assert((<<stacks)[move.from - 1].count >= move.count);
    for _: 1..move.count {
        crate := pop(*(<<stacks)[move.from - 1]);
        array_add(*(<<stacks)[move.to - 1], crate);
    }
}

part_1 :: (stacks: [..]Stack, moves: []Move) {
    for move: moves
        do_move_one_at_a_time(*stacks, move);

    string_builder: String_Builder;
    for stack: stacks
        append(*string_builder, stack[stack.count - 1]);

    print("FINAL STACK ARRANGEMENT:\n");
    print_stacks(stacks);
    print("part1: %\n", builder_to_string(*string_builder));
}

do_move_many_at_a_time :: (stacks: *[..]Stack, move: Move) {
    assert((<<stacks)[move.from - 1].count >= move.count);
    temp_crates: [..]Crate;
    for _: 1..move.count {
        crate := pop(*(<<stacks)[move.from - 1]);
        array_add(*temp_crates, crate);
    }
    for <crate: temp_crates
        array_add(*(<<stacks)[move.to - 1], crate);
}

part_2 :: (stacks: [..]Stack, moves: []Move) {
    for move: moves
        do_move_many_at_a_time(*stacks, move);

    string_builder: String_Builder;
    for stack: stacks
        append(*string_builder, stack[stack.count - 1]);

    print("FINAL STACK ARRANGEMENT:\n");
    print_stacks(stacks);
    print("part2: %\n", builder_to_string(*string_builder));
}

parse_stacks :: (contents: File_Contents) -> [..]Stack {
    stack_lines: [..]string;
    stack_count := 0;
    for line: contents {
        if !line.count {
            stack_id_line := eat_trailing_spaces(pop(*stack_lines));
            found, _, right := split_from_right(stack_id_line, " ");
            assert(found);
            stack_count = to_integer(right);
            break;
        }
        array_add(*stack_lines, line);
    }

    stacks: [..]Stack;
    array_resize(*stacks, stack_count);

    // Read row-by-row from the bottom of the stacks, upwards.
    // Skip first char, then every 4 chars is a crate letter, or empty
    // there can be up to `stack_count` in each row.
    for <line: stack_lines {
        for i: 0..stack_count-1 {
            char_index := 1 + i * 4;
            if char_index < line.count && line[char_index] != #char " "
                array_add(*stacks[i], line[char_index]);
        }
    }

    return stacks;
}

parse_moves :: (contents: File_Contents) -> [..]Move {
    moves: [..]Move;

    parsing := false;
    for line: contents {
        if !line.count {
            parsing = true;
            continue;
        }
        if !parsing continue;

        move: Move;
        tokens := split(line, " ");
        assert(tokens[0] == "move");
        move.count = to_integer(tokens[1]);
        assert(tokens[2] == "from");
        move.from = to_integer(tokens[3]);
        assert(tokens[4] == "to");
        move.to = to_integer(tokens[5]);

        array_add(*moves, move);
    }

    return moves;
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    stacks := parse_stacks(file_contents);
    moves := parse_moves(file_contents);

    part_1(deep_copy(stacks), moves);

    print("\n");
    part_2(stacks, moves);
}
