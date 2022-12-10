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
        // print("%\n", it);

        if instruction.type == .Add {
            x += instruction.value;
        }
    }

    print("part1: %\n", total_signal_strength);
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
}
