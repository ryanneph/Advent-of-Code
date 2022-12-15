// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Sort";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Op_Type :: enum {
    Add;
    Multiply;
}

Value_Type :: enum {
    Number;
    Self;
}

Op :: struct {
    type: Op_Type;

    value_type: Value_Type;
    value: s64; // only for value_type == .Number
}

Monkey :: struct {
    items: [..]s64;
    op: Op;
    test_divisor: s64;
    true_dest: s64;
    false_dest: s64;

    inspect_count: s64;
}

deep_copy :: (monkeys: [..]Monkey) -> [..]Monkey {
    new: [..]Monkey;
    for monkeys {

        new_items: [..]s64;
        for item: it.items
            array_add(*new_items, item);

        new_monkey := it;
        new_monkey.items = new_items;

        array_add(*new, new_monkey);
    }

    return new;
}

apply_op :: (item: s64, op: Op) -> s64 {
    arg := ifx op.value_type == .Self then item else op.value;

    new := item;
    if op.type == .Add  new += arg;
    else                new *= arg;

    return new;
}

simulate :: (monkeys: [..]Monkey, num_rounds: s64, divisor: s64, modulo: s64 = -1) ->s64 {
    round := 0;
    while round < num_rounds {
        round += 1;
        // print("ROUND %\n", round);

        for *monkey: monkeys {
            // print("  MONKEY %\n", it_index);
            for monkey.items {
                item := it;
                // print("    Inspecting item %\n", item);
                item = apply_op(item, monkey.op) / divisor;
                if (modulo > 0) item %= modulo;
                // print("    item is now %\n", item);

                dest_monkey := ifx item % monkey.test_divisor == 0
                               then *monkeys[monkey.true_dest]
                               else *monkeys[monkey.false_dest];
                array_add(*dest_monkey.items, item);
            }
            monkey.inspect_count += monkey.items.count;
            array_reset_keeping_memory(*monkey.items);
        }

        // for monkeys {
        //     print("%: % %\n", it_index, it.items, it.inspect_count);
        // }
        // print("\n");
    }

    quick_sort(monkeys, it=>-it.inspect_count);
    return monkeys[0].inspect_count * monkeys[1].inspect_count;
}

part_1 :: (monkeys: [..]Monkey) {
    print("part_1: %\n", simulate(monkeys, 20, 3, -1));
}

part_2 :: (monkeys: [..]Monkey) {
    worry_control := 1;
    for monkeys
        worry_control *= it.test_divisor;

    print("part_2: %\n", simulate(monkeys, 10000, 1, worry_control));
}

parse_monkeys :: (contents: string) -> [..]Monkey {
    monkeys: [..]Monkey;

    line: string;
    remainder := contents;
    while remainder {
        monkey: Monkey;
        tokens: []string;

        line, remainder = string_next_line(remainder);

        line, remainder = string_next_line(remainder);
        tokens = split(trim(line, " "), " ");
        for i: 2..tokens.count-1
            array_add(*monkey.items, to_integer(trim_right(tokens[i], ",")));

        line, remainder = string_next_line(remainder);
        tokens = split(trim(line, " "), " ");
        op: Op;
        if tokens[4] == {
            case "+"; op.type = .Add;
            case "*"; op.type = .Multiply;
            case; assert(false);
        }
        if is_digit(tokens[5][0]) {
            op.value_type = .Number;
            op.value = to_integer(tokens[5]);
        } else {
            op.value_type = .Self;
        }
        monkey.op = op;

        line, remainder = string_next_line(remainder);
        tokens = split(trim(line, " "), " ");
        assert(tokens[1] == "divisible");
        monkey.test_divisor = to_integer(tokens[3]);

        line, remainder = string_next_line(remainder);
        tokens = split(trim(line, " "), " ");
        monkey.true_dest = to_integer(tokens[5]);

        line, remainder = string_next_line(remainder);
        tokens = split(trim(line, " "), " ");
        monkey.false_dest = to_integer(tokens[5]);

        line, remainder = string_next_line(remainder);

        array_add(*monkeys, monkey);
    }

    return monkeys;
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all_as_string(filename);
    monkeys := parse_monkeys(file_contents);

    monkeys_copy := deep_copy(monkeys);
    part_1(monkeys_copy);
    part_2(monkeys);
}
