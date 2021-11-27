#import "Basic";
#import "File";
#import "Hash_Table";

file_read_all_as_string :: (filename: string) -> (string, bool) {
   file, success := file_open(filename, for_writing=false, keep_existing_content=true);
   if !success {
      log("Failed to open file '%' for reading", filename);
      return "", false;
   }
   
   length := file_length(file);
   buffer := cast(*u8) alloc(length);
   success = file_read(file, buffer, length);
   if !success {
      log("Failed to read data from file '%'", filename);
      return "", false;
   }

   file_close(*file);
   
   // create a string to hold the contents
   data: string;
   data.data = buffer;
   data.count = length;

   return data, true;
}

string_next_line :: (str: string) -> (string, string) {
   if (!str.count) return ("", "");

   // split on the first '\n' and discard the '\n'
   len := 0;
   while (len < str.count && str[len] != #char "\n")  len += 1;

   line: string;
   line.data = str.data;
   line.count = len;

   out_string: string;
   if (len == str.count && str[len - 1] != #char "\n") {
      out_string.data = null;
      out_string.count = 0;
   } else {
      out_string.data = str.data + len + 1;
      out_string.count = str.count - len - 1;
   }
   
   return (line, out_string);
}

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
