// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Stack :: struct ($T: Type) {
    crates: [..]T;
}

stack_push :: inline (stack: *Stack($T), val: T) {
    array_add(*stack.crates, val);
}

Move :: struct {
    count, from, to: s64;
}

// DEBUG
print_stacks :: (stacks: []Stack(u8)) {
    tallest_count := 0;
    for stack: stacks {
        tallest_count = max(tallest_count, stack.crates.count);
    }

    for i: 0..tallest_count-1 {
        for *stack: stacks {
            if stack.crates.count >= tallest_count - i {
                print_character(stack.crates[tallest_count - 1 - i]);
            } else {
                print(" ");
            }
            print(" ");
        }
        print("\n");
    }
    for i: 1..stacks.count
        print("--", i);
    print("\n");
    for i: 1..stacks.count
        print("% ", i);
    print("\n");
}

do_move :: (stacks: *[..]Stack(u8), move: Move) {
    assert((<<stacks)[move.from - 1].crates.count >= move.count);
    for _: 1..move.count {
        crate := pop(*(<<stacks)[move.from - 1].crates);
        array_add(*(<<stacks)[move.to - 1].crates, crate);
    }
}

part_1 :: (stacks: [..]Stack(u8), moves: []Move) {
    for move: moves
        do_move(*stacks, move);

    string_builder: String_Builder;
    for stack: stacks
        append(*string_builder, stack.crates[stack.crates.count - 1]);

    print("FINAL STACK ARRANGEMENT:\n");
    print_stacks(stacks);
    print("part1: %\n", builder_to_string(*string_builder));
}

parse_stacks :: (contents: File_Contents) -> [..]Stack(u8) {
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

    stacks: [..]Stack(u8);
    array_resize(*stacks, stack_count);

    // Read row-by-row from the bottom of the stacks, upwards.
    // Skip first char, then every 4 chars is a crate letter, or empty
    // there can be up to `stack_count` in each row.
    for <line: stack_lines {
        for i: 0..stack_count-1 {
            char_index := 1 + i * 4;
            if char_index < line.count && line[char_index] != #char " "
                stack_push(*stacks[i], line[char_index]);
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
    part_1(stacks, moves);
}
