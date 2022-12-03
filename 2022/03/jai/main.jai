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

part_all :: (contents: File_Contents) {
    first: Table(u8, bool);
    part1_total := 0;

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

        priority: s64;
        if (found_char < #char "a") {
            assert(found_char >= #char "A" && found_char <= #char "Z");
            priority = found_char - #char "A" + 27;
        } else {
            assert(found_char >= #char "a" && found_char <= #char "z");
            priority = found_char - #char "a" + 1;
        }
        part1_total += priority;
    }

    print("part1: %\n", part1_total);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_all(file_contents);
}
