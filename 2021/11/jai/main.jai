// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

grid_value_pointer :: (grid: []u8, row: u8, col: u8) -> *u8 #expand { return *(grid[row * 10 + col]); }

print_grid :: (grid: []u8, emphasize_value: u8 = 0, indent: u8 = 2) {
   for r: 0..9 {
      for _: 1..indent  print(" ");
      for c: 0..9 {
         val := <<grid_value_pointer(grid, xx r, xx c);
         format := cast(bool)(val == emphasize_value);

         #if OS == .LINUX if format print("\e[1;33m"); // style: bold+yellow
         print("% ", val);
         #if OS == .LINUX if format print("\e[0m"); // style: reset
      }
      print("\n");
   }
   print("\n");
}

Flash :: struct {
   row, col: u8;
};
make_Flash :: (row: u8, col: u8) -> Flash {
   f: Flash;
   f.row = row;
   f.col = col;
   return f;
}

update_grid :: (grid: []u8) -> s64 {
   grid_map :: (stack: *[..]Flash, grid: []u8, map_func: (stack: *[..]Flash, grid: []u8, row: u8, col: u8)) {
      for r: 0..9 {
         for c: 0..9 {
            map_func(stack, grid, xx r, xx c);
         }
      }
   }

   stack: [..]Flash;

   // 1. Do the per-element increment
   grid_increment :: (stack: *[..]Flash, grid: []u8, row: u8, col: u8) {
      vp := grid_value_pointer(grid, row, col);
      <<vp += 1;
      if <<vp == 10 { array_add(stack, make_Flash(row, col)); }
   }
   grid_map(*stack, grid, grid_increment);

   // 2. Keep processing new flashes until the stack runs dry
   flash_count := stack.count;
   while stack.count > 0 {
      flash := pop(*stack);

      // NOTE(ryan): either I don't know how, or jai doesn't seem to allow us to use
      // signed integers in for ranges, so we just subtract 1 before using below...
      for r_offset: 0..2 {
         for c_offset: 0..2 {
            r: s8 = cast(s8) (flash.row + r_offset - 1);
            c: s8 = cast(s8) (flash.col + c_offset - 1);

            if (r < 0 || r >= 10)  continue;
            if (c < 0 || c >= 10)  continue;
            if (r == xx flash.row && c == xx flash.col)  continue;

            vp := grid_value_pointer(grid, xx r, xx c);
            <<vp += 1;
            if <<vp == 10 {
               array_add(*stack, make_Flash(xx r, xx c));
               flash_count += 1;
            }
         }
      }
   }

   grid_zero_flashed :: (stack: *[..]Flash, grid: []u8, row: u8, col: u8) {
      vp := grid_value_pointer(grid, row, col);
      if <<vp > 9  { <<vp = 0; }
   }
   grid_map(*stack, grid, grid_zero_flashed);

   return flash_count;
}

part1 :: (grid: []u8) {
   // print("Before any steps\n");
   // print_grid(grid);

   total_flash_count := 0;
   for i: 1..100 {
      total_flash_count += update_grid(grid);
      // print("After step %\n", i);
      // print_grid(grid);
   }

   print("PART1: flash count after 100 steps: %\n", total_flash_count);
}

part2 :: (grid: []u8) {
   step := 0;
   while true {
      step += 1;
      flash_count := update_grid(grid);
      if flash_count == 100  break;
   }

   // NOTE(ryan): there seems to be a typo in the problem
   // since the accepted answer is 100 + step for both the
   // example and the official input...
   print("PART1: first sync after % steps\n", 100 + step);
}

parse_contents_to_grid :: (file_contents: string, grid: *[100]u8) {
   next := grid.data;
   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      for i: 0..line.count-1 {
         <<next = cast(u8)(line.data[i] - #char "0");
         assert(<<next >= 0 && <<next <= 9);
         next += 1;
      }
   }
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   grid: [100]u8;
   parse_contents_to_grid(file_contents, *grid);

   part1(grid);
   part2(grid);
}
