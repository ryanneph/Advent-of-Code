#import "Basic";
#import "String";

#import,file "../../../jai-common/string.jai";
#import,file "../../../jai-common/file.jai";

DEBUG_PRINT :: false;
debug :: inline (fmt: string, args: .. Any) {
    #if DEBUG_PRINT  print(fmt, ..args);
}
debug_character :: inline (char: u8) {
    #if DEBUG_PRINT  print_character(char);
}

Part :: struct {
    x, y: s64;
    label_count: s64;
    label_product: s64 = 1;
}

Label :: struct {
    x, y: s64;
    value: s64;

    start_index: s64;
    count: s64;
    assign_count: s64;
}

Schematic :: struct {
    data: string;
    width, height: s64;

    labels: [..]Label;
    parts: [..]Part;
    id_sum: s64;
    gear_ratio_sum: s64;
}

remove_chars_in_place :: (s: *string, chars: string) -> found_count: s64 {
    to := 0;
    found_count := 0;
    for from: 0..s.count-1 {
        if is_any(s.*[from], chars) {
            found_count += 1;
            continue;
        }
        s.*[to] = s.*[from];
        to += 1;
    }

    s.count = to;
    return found_count;
}

print_schematic_diagram :: (using schematic: Schematic) {
    for row: 0..height-1 {
        for col: 0..width-1 {
            index := row * width + col;
            c := data[index];
            print_character(c);
        }
        print("\n");
    }
}

print_schematic :: (using schematic: Schematic) {
    print("Schematic:\n");
    print("  width:  %\n", width);
    print("  height: %\n", height);
    print("  part count:  %\n", parts.count);
    if parts.count {
        print("  parts (first few):\n");
        for 0..min(3, parts.count)-1 {
            part := *parts[it];
            print("    %: (x=%, y=%)\n", it, part.x, part.y);
        }
    }
    print("  label count: %\n", labels.count);
    if labels.count {
        print("  labels (first few):\n");
        for 0..min(3, labels.count)-1 {
            label := *labels[it];
            print("    %: (x=%, y=%) count=% value=%\n",
                it, label.x, label.y, label.count, label.value);
        }
    }
}

parse :: (file_contents: string) -> Schematic {
    using schematic: Schematic;

    NEWLINE :: "\n\r";
    data   = copy_string(file_contents);
    width  = find_index_of_any_from_left(data, NEWLINE);
    height = remove_chars_in_place(*data, NEWLINE);

    in_label := false;
    label: Label;
    for row: 0..height-1 {
        for col: 0..width-1 {
            index := row * width + col;
            c := data[index];

            rewind_and_commit_label :: (rewind_count: s64) #expand {
                label.count = index - label.start_index + 1 - rewind_count;

                s := slice(data, label.start_index, label.count);
                value, success := to_integer(s);
                if !success {
                    print("Error: failed to parse label '%s' as integer (row=%, col=%)\n",
                        s, row, col);
                    `return .{};
                }
                label.value = value;

                array_add(*labels, label);
            }

            c_is_digit := is_digit(c);
            last_char_in_row := col == width-1;

            if c_is_digit {
                if !in_label {
                    label = .{ x = col, y = row, start_index = index };
                }
                in_label = true;
            } else if c == #char "." {
            } else {
                part := Part.{ x = col, y = row };
                array_add(*parts, part);
            }

            // finish a label
            if (in_label) {
                if !c_is_digit {
                    rewind_and_commit_label(1);
                    in_label = false;
                } else if last_char_in_row {
                    rewind_and_commit_label(0);
                    in_label = false;
                }
            }
        }
    }

    // match parts to labels -> assign part id from label
    id_sum = 0;
    label_index_checkpoint := 0;
    for *part: parts {
        debug("Part % (x=%, y=%):\n", it_index, part.x, part.y);
        for label_index_checkpoint..labels.count-1 {
            label := *labels[it];

            if (label.x + label.count-1) < part.x-1  continue;
            if label.x > part.x+1  continue;
            if label.y < part.y-1  continue;
            if label.y > part.y+1  break;

            debug("    Label (x=%, y=%) value=%0%\n",
                label.x, label.y, label.value,
                ifx label.assign_count>0 then " (already counted)" else "");

            part.label_count += 1;
            part.label_product *= label.value;

            assert(!label.assign_count);
            id_sum += label.value;
            label.assign_count += 1;
        }
    }

    gear_ratio_sum = 0;
    for *part: parts {
        if part.label_count >= 2 {
            assert(part.label_count == 2);
            gear_ratio_sum += part.label_product;
        }
    }

    print_schematic(schematic);
    return schematic;
}

part_1 :: (schematic: Schematic) {
    print("Part1: %\n", schematic.id_sum);
}

part_2 :: (schematic: Schematic) {
    print("Part2: %\n", schematic.gear_ratio_sum);
}

main :: () {
    filename := "../input.txt";
    // filename = "../test1.txt";

    file_contents, success := file_read_all_as_string(filename);
    if !success {
        print("Failed to read file '%s'", filename);
        exit(1);
    }

    schematic := parse(file_contents);
    part_1(schematic);
    part_2(schematic);
}
