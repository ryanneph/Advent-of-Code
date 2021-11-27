// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Hash_Table";

// personal modules
#import "file";
#import "string";

part1 :: (contents: string) {
   accumulator: s64 = 0;
   remainder := contents;
   while(remainder.count) {
      line: string;
      line, remainder = string_next_line(remainder);
      // log("line is '%'", line);

      assert(line.count > 0);
      assert(line[0] == #char "-" || line[0] == #char "+");

      numeric_digits: string;
      numeric_digits.data = line.data + 1;
      numeric_digits.count = line.count - 1;

      numeric_val : s64;
      success     : bool;
      numeric_val, success = string_to_int(numeric_digits);
      assert(success);

      if      (line[0] == #char "-") accumulator -= numeric_val;
      else if (line[0] == #char "+") accumulator += numeric_val;
   }

   log("Part1 solution: Accumulated value is %", accumulator);
}

part2 :: (contents: string) {
   accumulator: s64 = 0;
   remainder := contents;
   table: Table(s64, void);
   while(true) {
      line: string;
      line, remainder = string_next_line(remainder);
      // log("line is '%'", line);

      assert(line.count > 0);
      assert(line[0] == #char "-" || line[0] == #char "+");

      numeric_digits: string;
      numeric_digits.data = line.data + 1;
      numeric_digits.count = line.count - 1;

      numeric_val : s64;
      success     : bool;
      numeric_val, success = string_to_int(numeric_digits);
      assert(success);

      if      (line[0] == #char "-") accumulator -= numeric_val;
      else if (line[0] == #char "+") accumulator += numeric_val;

      void, found := table_find(table, accumulator);
      if (found)  {
         break;
      }
      else { 
         // log("adding % to table", accumulator);
         table_add(*table, accumulator, void);
      }      

      if (remainder.count <= 0) remainder = contents;
   }

   log("Part2 solution: first repeated accumulator value is %", accumulator);
}

main :: () {
   filename := "../input.txt";
   contents, success := file_read_all_as_string(filename);
   // log("Contents of '%'\n%", filename, contents);

   part1(contents);
   part2(contents);
}
