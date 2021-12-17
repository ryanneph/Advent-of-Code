// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

part1 :: () {
   print("PART1: %\n", 0);
}

main :: () {
   // filename := "../input.txt";
   filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      print("%\n", line);
   }

   part1();
}
