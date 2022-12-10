// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Instruction_Type :: enum {
    Noop;
    Add;
}

Instruction :: struct {
    type: Instruction_Type;
    duration: s64;

    value: s64; // .Add
}

part_1 :: (instructions: []Instruction) {
    x := 1;
    clock := 0;

    total_signal_strength := 0;
    for instructions {
        instruction := it;

        while instruction.duration > 0 {
            clock += 1;
            instruction.duration -= 1;

            // check stuff here
            if (clock - 20) % 40 == 0 && clock <= 220 {
                print("%: %\n", clock, x);
                total_signal_strength += clock * x;
            }
        }

        if instruction.type == .Add {
            x += instruction.value;
        }
    }

    print("part1: %\n", total_signal_strength);
}

part_2 :: (instructions: []Instruction) {
    WIDTH :: 40;
    HEIGHT :: 6;

    x := 1;
    clock := 0;

    crt_pixmap: [WIDTH * HEIGHT]u8;

    for instructions {
        instruction := it;

        while instruction.duration > 0 {
            clock += 1;
            instruction.duration -= 1;

            col := (clock-1) % WIDTH;
            row := (clock-1) / WIDTH;
            if col >= x-1 && col <= x+1 {
                crt_pixmap[row * WIDTH + col] = 1;
            }
        }

        if instruction.type == .Add {
            x += instruction.value;
        }
    }

    loc := 0;
    for row: 0..HEIGHT-1 {
        for col: 0..WIDTH-1 {
            if crt_pixmap[loc] > 0 print_character(#char "#");
            else                   print_character(#char " ");
            loc += 1;
        }
        print("\n");
    }
}

parse_instructions :: (file_contents: File_Contents) -> [..]Instruction {
    instructions: [..]Instruction;

    for line: file_contents {
        instruction: Instruction;

        if line == "noop" {
            instruction.type = .Noop;
            instruction.duration = 1;
        } else {
            _, cmd, operand := split_from_left(line, " ");
            instruction.type = .Add;
            instruction.duration = 2;
            instruction.value = to_integer(operand);
        }

        array_add(*instructions, instruction);
    }

    return instructions;
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    instructions := parse_instructions(file_contents);

    part_1(instructions);
    part_2(instructions);
}
