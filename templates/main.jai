// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

part_1 :: (contents: File_Contents) {
    for line: contents {
        print("LINE %: %\n", it_index, line);
    }
}

main :: () {
    filename := "../test1.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
}
