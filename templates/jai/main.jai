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

part_1 :: (file_contents: File_Contents) {
    for line: file_contents {
        print("%: %\n", it_index, line);
    }
    print("Part1: %\n", 0);
}

main :: () {
    filename := "../input.txt";

    file_contents, success := file_read_all(filename);
    if !success {
        print("Failed to read file '%s'", filename);
        exit(1);
    }

    part_1(file_contents);
}
