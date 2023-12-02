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

to_integer :: (char: u8) -> s64 {
    assert(char >= #char "0" && char <= #char "9");
    return cast(s64)char - #char "0";
}

find_first_digit :: (line: string, $from_back := false) -> s64 {
    for <=from_back :chars c: line {
        if is_digit(c) {
            number := to_integer(c);

            debug("'");
            debug_character(c);
            debug("' -> %\n", number);

            return number;
        }
    }

    // We should never reach this with well-formed input
    assert(false);
}

part_1 :: (file_contents: File_Contents) {
    first, last: s64;
    total := 0;
    for line, lineno: file_contents {
        debug("line %: %\n", lineno, line);

        first = find_first_digit(line);
        last = find_first_digit(line, from_back=true);

        number := first * 10 + last;
        debug("Number: %\n\n", number);
        total += number;
    }

    debug("Part 1: %\n", total);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
}
