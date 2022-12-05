// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Range :: struct {
    first, last : s64;
}

range_fully_contains :: inline (outer: Range, inner: Range) -> bool {
    return outer.first <= inner.first && outer.last >= inner.last;
}

ranges_overlap :: inline (a: Range, b: Range) -> bool {
    return (a.last >= b.first && a.last <= b.last) ||
           (b.last >= a.first && b.last <= a.last);
}

range_from_string :: (s: string) -> Range {
    found, left, right := split_from_left(s, "-");
    assert(found);

    range: Range;
    range.first = to_integer(left);
    range.last = to_integer(right);

    return range;
}

part_all :: (contents: File_Contents) {
    fully_contain_count := 0;
    overlap_count := 0;

    for line: contents {
        found, elf1, elf2 := split_from_left(line, ",");
        assert(found);

        range1 := range_from_string(elf1);
        range2 := range_from_string(elf2);

        if range_fully_contains(range1, range2) || range_fully_contains(range2, range1)
            fully_contain_count += 1;
        if ranges_overlap(range1, range2)
            overlap_count += 1;
    }

    print("part1: %\n", fully_contain_count);
    print("part2: %\n", overlap_count);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_all(file_contents);
}
