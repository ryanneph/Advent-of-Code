// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Range :: struct {
    first, last : s64;
}

range_fully_contains :: (outer: Range, inner: Range) -> bool {
    return outer.first <= inner.first && outer.last >= inner.last;
}

range_from_string :: (s: string) -> Range {
    found, left, right := split_from_left(s, "-");
    assert(found);

    range: Range;
    range.first = to_integer(left);
    range.last = to_integer(right);

    return range;
}

part_1 :: (contents: File_Contents) {
    fully_contain_count := 0;

    for line: contents {
        print("LINE %: %\n", it_index, line);
        found, elf1, elf2 := split_from_left(line, ",");
        assert(found);

        range1 := range_from_string(elf1);
        range2 := range_from_string(elf2);

        print("  Elf1: %\n", range1);
        print("  Elf2: %\n", range2);

        if range_fully_contains(range1, range2) || range_fully_contains(range2, range1)
            fully_contain_count += 1;
    }

    print("part1: %\n", fully_contain_count);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
}
