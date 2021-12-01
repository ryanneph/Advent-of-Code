// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

part1 :: (file_contents: string) {
   previous_depth := -1;
   increase_count := 0;

   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      current_depth := to_integer(line);
      // print("Current depth is %\n", current_depth);

      if (previous_depth >= 0 && previous_depth < current_depth)
         increase_count += 1;
      previous_depth = current_depth;
   }

   print("PART1: Number of times the depth increased from previous: %\n", increase_count);
}

Window3 :: struct {
   values: [3] int;
   valid_count: int;
}

Window3_update :: (window: *Window3, new_value: int) {
   if (window.valid_count < window.values.count) 
      window.valid_count += 1;

   for i: 0..window.values.count-2 
      window.values[i] = window.values[i + 1];
   window.values[window.values.count - 1] = new_value;
}

Window3_sum :: (window: *Window3) -> (sum: int, full_window: bool) {
   sum := 0;
   for window.values 
      sum += it;
   return sum, window.valid_count == window.values.count;
}

Window3_update_and_sum :: (window: *Window3, new_value: int) -> (sum: int, full_window: bool) {
   Window3_update(window, new_value);
   sum, window_full := Window3_sum(window);
   return sum, window_full;
}

part2 :: (file_contents: string) {
   window: Window3;
   previous_sum := -1;
   increase_count := 0;

   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      current_depth := to_integer(line);
      current_sum, window_full := Window3_update_and_sum(*window, current_depth);
      // print("Current Sum: % (window_full: %)\n", Window3_sum(*window), window_full);

      if window_full {
         if previous_sum >= 0 && current_sum > previous_sum 
            increase_count += 1;
         previous_sum = current_sum;
      }
   }      
   print("PART2: Number of times the windowed sum increased from previous: %\n", increase_count);
}

main :: () {
   filename := "../input.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'", filename);
      return;
   }
   
   part1(file_contents);
   part2(file_contents);
}
