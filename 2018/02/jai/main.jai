#import "Basic";

#import "file";
#import "string";

print_u64_as_binary :: (num: u64) {
   started := false;
   for i: 0..63 {
      index := 63 - i;
      bit := (num & (cast(u64)1 << index));
      binary: u8;
      if (bit) binary = 1;
      else     binary = 0;
      if (started || bit) {
         if (!started) started = true;
         print("%", binary);
      }
   }
}

part1 :: (contents: string) {

   double_count := 0;
   triple_count := 0;

   remainder := contents;
   while (remainder.count > 0) {
      line: string;
      line, remainder = string_next_line(remainder);
      // log("%", line);

      line = "aabcdf";
      // separately track which chars were seen once/twice/thrice/more
      seen_chars1: u64 = 0;
      seen_chars2: u64 = 0;
      seen_chars3: u64 = 0;
      seen_chars4: u64 = 0;

      for i: 0..line.count-1 {
         // log("%", formatline[i]);
         // print_character(line[i]);
         char_index: u64 = line[i] - #char "a";
         mask: u64 = (cast(u64)1 << char_index);

         // only need 4 bits per character.
         // let's track as separate counters
         if (seen_chars1 & mask) {
            seen_chars1 &= ~mask;
            double_count += 1;
        } else if (seen_chars2 & mask) {
            seen_chars2 &= ~mask;
            double_count -= 1;
            triple_count += 1;
        } else if (seen_chars3 & mask) {
            seen_chars3 &= ~mask;
            seen_chars4 |= mask;
            triple_count -= 1;
         } else {
            seen_chars1 |= mask;
         }

      }
      print("%\n", line);
      print_u64_as_binary(seen_chars1);
      print("\n");
      print("double_count: %\n", double_count);
   }
}

main :: () {
   filename := "../test1.txt";
   contents, success := file_read_all_as_string(filename);
   if (!success) {
      log("ERROR: failed to read file '%'", filename);
   }

   part1(contents);
}
