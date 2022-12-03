// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

part_all :: (contents: string) {

}

main :: () {
    filename := "../test1.txt";
    file_contents, success := file_read_all_as_string(filename);
    assert(success);

    part_all(file_contents);
}
