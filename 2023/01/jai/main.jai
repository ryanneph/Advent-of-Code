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


digit_as_number :: (char: u8) -> s64 {
    assert(char >= #char "0" && char <= #char "9");
    number := cast(s64)char - #char "0";

    debug("'");
    debug_character(char);
    debug("' -> %\n", number);

    return number;
}

matches :: (full: string, sub: string, $from_back := false) -> bool {
    if sub.count > full.count
        return false;

    partial := full;
    #if from_back {
        partial.data += partial.count - sub.count;
    }
    partial.count = sub.count;

    matches := !compare(partial, sub);
    return matches;
}

find_first_digit :: (line: string, $search_words := false, $reverse := false) -> s64 {
    for <=reverse :chars c, i: line {
        if is_digit(c)  return digit_as_number(c);

        #if search_words {
            return_if_matches :: (full: string, sub: string, return_value: s64, $from_back := false) #expand {
                if matches(full, sub, from_back) {
                    debug("'%' -> %\n", sub, return_value);
                    `return return_value;
                }
            }
            return_if_matches_back :: #bake_arguments return_if_matches(from_back=true);

            #if !reverse {
                remaining := slice(line, i, line.count - i);
                if c == {
                    case #char "z"; // 0
                        return_if_matches(remaining, "zero", 0);

                    case #char "o"; // 1
                        return_if_matches(remaining, "one", 1);

                    case #char "t"; // 2, 3
                        return_if_matches(remaining, "two",   2);
                        return_if_matches(remaining, "three", 3);

                    case #char "f"; // 4, 5
                        return_if_matches(remaining, "four", 4);
                        return_if_matches(remaining, "five", 5);

                    case #char "s"; // 6, 7
                        return_if_matches(remaining, "six",   6);
                        return_if_matches(remaining, "seven", 7);

                    case #char "e"; // 8
                        return_if_matches(remaining, "eight", 8);

                    case #char "n"; // 9
                        return_if_matches(remaining, "nine", 9);
                }
            } else {
                remaining := slice(line, 0, i + 1);
                if c == {
                    case #char "o"; // 0, 2
                        return_if_matches_back(remaining, "zero", 0);
                        return_if_matches_back(remaining, "two",  2);

                    case #char "e"; // 1, 3, 5, 9
                        return_if_matches_back(remaining, "one",   1);
                        return_if_matches_back(remaining, "three", 3);
                        return_if_matches_back(remaining, "five",  5);
                        return_if_matches_back(remaining, "nine",  9);

                    case #char "r"; // 4
                        return_if_matches_back(remaining, "four", 4);

                    case #char "x"; // 6
                        return_if_matches_back(remaining, "six", 6);

                    case #char "n"; // 7
                        return_if_matches_back(remaining, "seven", 7);

                    case #char "t"; // 8
                        return_if_matches_back(remaining, "eight", 8);
                }
            }
        }
    }

    // We should never reach this for well-formed input
    assert(false);
    return 0;
}

calibrate :: (file_contents: File_Contents, $search_words: bool) -> s64 {
    first, last: s64;
    total := 0;
    for line, lineno: file_contents {
        debug("line %: %\n", lineno, line);

        debug("  First: ");
        first = find_first_digit(line, search_words=search_words);

        debug("  Last: ");
        last  = find_first_digit(line, search_words=search_words, reverse=true);

        number := first * 10 + last;
        debug("  Number: %\n\n", number);

        total += number;
    }

    return total;
}

part_1 :: inline (file_contents: File_Contents) {
    total := calibrate(file_contents, search_words=false);
    print("Part 1: %\n", total);
}

part_2 :: inline (file_contents: File_Contents) {
    total := calibrate(file_contents, search_words=true);
    print("Part 2: %\n", total);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
    part_2(file_contents);
}
