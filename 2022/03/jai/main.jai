// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";
#import "Hash_Table";

// from ../../../jai-common
#import "file";
#import "string";

// for_expansion for iterating characters of a string
chars :: (line: *string, body: Code, flags: For_Flags) #expand {
    for i: 0..line.count-1 {
        `it_index := i;
        `it := (<<line)[i];

        #insert body;
    }
}

get_priority :: (char: s64) -> s64 {
    if (char < #char "a") {
        assert(char >= #char "A" && char <= #char "Z");
        return char - #char "A" + 27;
    } else {
        assert(char >= #char "a" && char <= #char "z");
        return char - #char "a" + 1;
    }
}

part_1 :: (contents: File_Contents) {
    first: Table(u8, bool);
    priority_sum := 0;

    for line: contents {
        table_reset(*first);

        found_char := -1;
        for :chars  char, index: line {
            if (index < line.count / 2) {
                table_add(*first, char, true);
            } else {
                _, found := table_find(*first, char);
                if (found) {
                    found_char = char;
                    break char;
                }
            }
        }
        assert(found_char >= 0);
        priority_sum += get_priority(found_char);
    }

    print("part1: %\n", priority_sum);
}

part_2 :: (contents: File_Contents) {
    seen: Table(u8, s8);
    priority_sum := 0;

    group_line_count := 0;
    for line: contents {
        if (group_line_count >= 3) {
            group_line_count = 0;
            table_reset(*seen);
        }
        group_line_count += 1;

        line_seen: Table(u8, bool);
        for :chars  char: line {
            table_set(*line_seen, char, true);
        }

        for _, char: line_seen {
            seen_count := table_find_pointer(*seen, char);
            if (seen_count) {
                if (<<seen_count) == 2 {
                    priority_sum += get_priority(char);
                    break line;
                } else {
                    (<<seen_count) += 1;
                }
            } else {
                table_add(*seen, char, 1);
            }
        }
    }

    print("part2: %\n", priority_sum);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
    part_2(file_contents);
}
