// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Shape :: enum {
    Unknown  :: 0;

    Rock     :: 1;
    Paper    :: 2;
    Scissors :: 3;
}

shape_get_from_char :: (c: string) -> Shape {
    if c == {
        case "X"; #through;
        case "A"; return .Rock;

        case "Y"; #through;
        case "B"; return .Paper;

        case "Z"; #through;
        case "C"; return .Scissors;

        case;
            print("Unknown value %", c);
            assert(false);
            return .Unknown;
    }
}

shape_get_score :: inline (shape: Shape) -> s64 {
    return cast(s64)shape;
}

score_from_pair :: (shape1: Shape, shape2: Shape) -> s64 {
    score: s64;
    if shape1 == shape2
        score = 3;
    else {
        diff := (cast(s64)(shape2 - 1) - cast(s64)(shape1 - 1)) % 3;
        score = ifx diff == 1 || diff == -2 then 6 else 0;
    }

    score += shape_get_score(shape2);
    return score;
}

part1 :: (contents: string) {
    score := 0;

    line: string;
    remainder := contents;
    while remainder.count {
        line, remainder = string_next_line(remainder);

        tokens := split(line, " ");
        assert(tokens.count == 2);
        score += score_from_pair(
            shape_get_from_char(tokens[0]),
            shape_get_from_char(tokens[1])
        );
    }
    print("part1: %\n", score);
}

main :: () {
    filename := "../input.txt";
    file_contents, success := file_read_all_as_string(filename);
    assert(success);

    part1(file_contents);
}
