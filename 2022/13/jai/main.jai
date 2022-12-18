// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Sort";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Input_Type :: enum s8 {
    Integer;
    List;
}

Input :: struct {
    type: Input_Type;
    union {
        integer: s64;
        list: [..]Input;
    }

    // Debug
    original: string;
}

parse_line_as_packet :: (line: string) -> Input {
    stack: [..]Input;
    number_string: string;

    maybe_add_number :: () #expand {
        if !number_string.count return;

        value: Input;
        value.type = .Integer;
        value.integer = to_integer(number_string);
        // print("    VALUE: %: %\n", number_string, value.integer);

        current := *stack[stack.count-1];
        assert(current.type == .List);
        array_add(*current.list, value);

        number_string.data = null;
        number_string.count = 0;
    }

    tokens := split(line, ",");
    for token: tokens {
        // print("  TOKEN: %\n", token);

        for j: 0..token.count-1 {
            c := token[j];
            if c == #char "[" {
                maybe_add_number();

                input: Input;
                input.type = .List;

                array_add(*stack, input);
                // print("    {\n");
            } else if c == #char "]" {
                maybe_add_number();

                // print("    }\n");
                if stack.count == 1 && j == token.count-1
                    return stack[0];

                child := pop(*stack);
                array_add(*stack[stack.count-1].list, child);
            } else {
                if !number_string
                    number_string.data = *token[j];
                number_string.count += 1;

                if j == token.count-1
                    maybe_add_number();
            }
        }
    }
    assert(false);
}

parse_packets :: (contents: File_Contents) -> [..]Input {
    packets: [..]Input;

    for line: contents {
        if !line.count continue;
        // print("LINE: %\n", line);

        packet := parse_line_as_packet(line);
        packet.original = line;
        // print("  PACKET: %\n\n", packet.list);
        array_add(*packets, packet);
    }

    return packets;
}

Compare_Result :: enum {
    Correct;
    Incorrect;
    Undetermined;
}

compare_inputs :: (left: Input, right: Input) -> Compare_Result {
    assert(left .type == .List);
    assert(right.type == .List);

    i := 0;
    while true {
        if i >= left.list.count || i >= right.list.count {
            if left.list.count == right.list.count
                return Compare_Result.Undetermined;

            print("list overrun at index=% (left:%, right:%)\n", i, left.list.count, right.list.count);
            return ifx i < right.list.count
                then Compare_Result.Correct
                else Compare_Result.Incorrect;
        }

        l := left .list[i];
        r := right.list[i];
        if l.type == .Integer && r.type == .Integer {
            print("  compare <int>% to <int>%\n", l.integer, r.integer);
            if l.integer != r.integer {
                return ifx l.integer < r.integer
                    then Compare_Result.Correct
                    else Compare_Result.Incorrect;
            }
        } else if l.type == .List && r.type == .List {
            print("  compare <list:%> to <list:%>\n", l.list.count, r.list.count);
            result := compare_inputs(l, r);
            if result != .Undetermined  return result;
        } else if l.type == .List {
            temp: Input;
            temp.type = .List;
            array_add(*temp.list, r);

            print("  compare <list:%> to <int>%\n", l.list.count, r.integer);
            result := compare_inputs(l, temp);
            if result != .Undetermined  return result;
        } else if r.type == .List {
            temp: Input;
            temp.type = .List;
            array_add(*temp.list, l);

            print("  compare <int>% to <list:%>\n", l.integer, r.list.count);
            result := compare_inputs(temp, r);
            if result != .Undetermined  return result;
        } else {
            assert(false);
        }

        print("  keep going\n");
        i += 1;
    }

    return .Undetermined;
}

part_1 :: (packets: [..]Input) {
    sum := 0;

    index := 0;
    assert(packets.count % 2 == 0);
    while index < packets.count-1 {
        left  := packets[index];
        right := packets[index+1];
        print("INPUT %:  %\n", index,   left .original);
        print("INPUT %:  %\n", index+1, right.original);
        index += 2;

        result := compare_inputs(left, right);
        if result == .Correct {
            sum += (index + 1) / 2;
        }
        print("Result: %\n\n", result);
    }

    print("part_1: %\n", sum);
}

part_2 :: (packets: [..]Input) {
    make_divider :: (integer: s64) -> Input {
        value: Input;
        value.type = .Integer;
        value.integer = integer;

        inner: Input;
        inner.type = .List;
        array_add(*inner.list, value);

        divider: Input;
        divider.type = .List;
        array_add(*divider.list, inner);
        divider.original = "DIVIDER";

        return divider;
    }

    divider1 := make_divider(2);
    divider2 := make_divider(6);
    array_add(*packets, divider1);
    array_add(*packets, divider2);

    compare_for_sort :: (l: Input, r: Input) -> s64 {
        result := compare_inputs(l, r);
        if result == {
            case .Correct;      return -1;
            case .Incorrect;    return 1;
            case .Undetermined; return 0;
        }
    }
    quick_sort(packets, compare_for_sort);

    decoder_key := 1;
    for packets {
        print("%\n", it.original);
        if it.original == "DIVIDER"
            decoder_key *= (it_index + 1);
    }

    print("part_2: %\n", decoder_key);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    packets := parse_packets(file_contents);

    part_1(packets);
    part_2(packets);
}
