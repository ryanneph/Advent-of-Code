// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

Sorted_Array :: struct ($N: s64) {
    data: [N]s64;
}

sorted_insert :: (array: *Sorted_Array, val: s64) {
    for *array.data {
        if val <= <<it continue;
        temp := <<it;
        <<it = val;
        val = temp;
    }
}

array_sum :: (array: []s64) -> s64 {
    sum := 0;
    for array  sum += it;
    return sum;
}

part_all :: (contents: string) {
    top : Sorted_Array(3);
    group_sum := 0;

    line: string;
    remainder := contents;
    while remainder.count {
        line, remainder = string_next_line(remainder);

        num := to_integer(line);
        group_sum += num;
        if (!line.count || !remainder.count) {
            sorted_insert(*top, group_sum);
            group_sum = 0;
        }
    }

    print("part1: %\n", top.data[0]);
    print("part2: %\n", array_sum(top.data));
}

main :: () {
    filename := "../input.txt";
    file_contents, success := file_read_all_as_string(filename);
    assert(success);

    part_all(file_contents);
}
