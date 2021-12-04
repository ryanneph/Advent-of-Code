// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

parse_bitstring_to_integer :: (bitstring: string) -> int {
   number:= 0;
   for i: 0..bitstring.count-1 {
      if bitstring[bitstring.count - 1 - i] == #char "1"
         number |= (1 << i);
   }
   return number;
}

parse_lines_to_int_array :: (file_contents: string) -> (numbers: [..]int, bit_count: int) {
   numbers: [..]int;

   first_line, _ := string_next_line(file_contents);
   bit_count := first_line.count;

   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);
      array_add(*numbers, parse_bitstring_to_integer(line));
   }

   return numbers, bit_count;
}

// bit_position starts from LSB == 0
get_most_common_bit :: (numbers: [..]int, bit_position: int, prefer_high: bool) -> (bit_value: int) {
   half_count := cast(float)numbers.count / 2.0;

   high_count := 0;
   for numbers {
      bit := ifx (it & (1 << bit_position)) 1 else 0;
      high_count += bit;

      // early-out since we already know 1 is most common bit-value
      if (cast(float)high_count > half_count)
         break;
   }

   if (cast(float)high_count == half_count)
      return cast(int)prefer_high;
   else
      return cast(int)(cast(float)high_count > half_count);
}

get_most_common_bits :: (numbers: [..]int, bit_count: int, prefer_high: bool = true) -> (bit_values: int) {
   most_common_bits := 0;
   for i: 0..bit_count-1 {
      // most_common_bit is returned in the LSB position
      most_common_bits |= (get_most_common_bit(numbers, i, prefer_high) << i);
   }

   return most_common_bits;
}

filter_by_bit_value :: (original_numbers: [..]int, bit_count: int, keep_if_most_common: bool, prefer_high: bool) -> remaining_number: int {
   numbers : [..]int;
   array_copy(*numbers, original_numbers);

   for i: 0..bit_count-1 {
      if (numbers.count == 1) break;

      // filter_bit is returned as 1 or 0 in the LSB position
      filter_bit := get_most_common_bit(numbers, bit_count - 1 - i, true);
      if (!keep_if_most_common)
         filter_bit = cast(int) !filter_bit;

      mask := (1 << (bit_count - 1 - i));

      j := 0;
      while numbers.count > 1 && j < numbers.count {
         num := numbers[j];
         number_bit := ifx (num & mask) 1 else 0;

         if (filter_bit ^ number_bit) {
            array_unordered_remove_by_index(*numbers, j);
            continue; // without incrementing j
         }

         j += 1;
      }
   }

   assert(numbers.count == 1);
   remaining_number := numbers[0];
   array_free(numbers);
   return remaining_number;
}

part1 :: (file_contents: string) {
   numbers: [..]int;
   bit_count: int;
   numbers, bit_count = parse_lines_to_int_array(file_contents);
   gamma_rate := get_most_common_bits(numbers, bit_count);

   mask := (1 << (bit_count)) - 1;
   epsilon_rate: int = ~gamma_rate & mask;

   print("PART1: gamma=%, epsilon=%, product=%\n",
         gamma_rate, epsilon_rate, gamma_rate * epsilon_rate);
}

part2 :: (file_contents: string) {
   original_numbers: [..]int;
   bit_count: int;
   original_numbers, bit_count = parse_lines_to_int_array(file_contents);

   oxygen_rating := filter_by_bit_value(original_numbers, bit_count, true,  true);
   co2_rating    := filter_by_bit_value(original_numbers, bit_count, false, false);

   print("PART2: O=%, CO2=%, product=%\n", oxygen_rating, co2_rating, oxygen_rating * co2_rating);
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   part1(file_contents);
   part2(file_contents);
}
