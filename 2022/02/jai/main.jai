// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

// NOTE: enum integer values must not change
Shape :: enum {
    Rock     :: 0;
    Paper    :: 1;
    Scissors :: 2;

    Unknown;
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
            return 0;
    }
}

shape_get_score :: inline (shape: Shape) -> s64 {
    return cast(s64)shape + 1;
}

score_from_pair :: (shape1: Shape, shape2: Shape) -> s64 {
    score: s64;
    if shape1 == shape2
        score = 3;
    else {
        diff := (cast(s64)(shape2) - cast(s64)(shape1) + 3) % 3;
        score = ifx diff == 1 then 6 else 0;
    }

    score += shape_get_score(shape2);
    return score;
}

part_all :: (contents: string) {
    score_part1 := 0;
    score_part2 := 0;

    line: string;
    remainder := contents;
    while remainder.count {
        line, remainder = string_next_line(remainder);

        tokens := split(line, " ");
        assert(tokens.count == 2);

        // part1
        shape_oppenent := shape_get_from_char(tokens[0]);
        score_part1 += score_from_pair(
            shape_oppenent,
            shape_get_from_char(tokens[1])
        );

        // part2
        shape_ours: Shape;
        if tokens[1] == {
            case "X"; // lose
                shape_ours = cast(Shape)((cast(s64)shape_oppenent - 1 + 3) % 3);
            case "Y"; // draw
                score_part2 += 3;
                shape_ours = shape_oppenent;
            case "Z"; // win
                score_part2 += 6;
                shape_ours = cast(Shape)((cast(s64)shape_oppenent + 1) % 3);
        }
        score_part2 += shape_get_score(shape_ours);
    }
    print("part1: %\n", score_part1);
    print("part2: %\n", score_part2);
}

main :: () {
    filename := "../input.txt";
    file_contents, success := file_read_all_as_string(filename);
    assert(success);

    part_all(file_contents);
}
