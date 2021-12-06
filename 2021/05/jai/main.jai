// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Line :: struct {
   x1, y1, x2, y2: u32;
};

parse_lines_to_lines :: (file_contents: string) -> [..]Line {
   lines: [..]Line;

   remainder := file_contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      new_line: Line;

      found, left, right := split_from_left(line, ",");
      assert(found);
      new_line.x1 = cast(u32) to_integer(left);

      found, left, right = split_from_left(right, " ");
      assert(found);
      new_line.y1 = cast(u32) to_integer(left);

      // length of next chars '-> ' is always 3, so we just skip ahead
      right.data += 3;
      right.count -= 3;

      found, left, right = split_from_left(right, ",");
      assert(found);
      new_line.x2 = cast(u32) to_integer(left);
      new_line.y2 = cast(u32) to_integer(right);

      array_add(*lines, new_line);
   }

   return lines;
}

get_grid_size_from_line_bounds :: (lines: []Line) -> (rows: u32, cols: u32) {
   max_x, max_y: u32;
   for line: lines {
      max_x = max(max_x, line.x1);
      max_x = max(max_x, line.x2);
      max_y = max(max_y, line.y1);
      max_y = max(max_y, line.y2);
   }
   // bounds are inclusive and indices start at 0
   return max_x + 1, max_y + 1;
}

Grid :: struct {
   cells: [..]u32;
   rows, cols: u32;
};

Grid_Create :: (rows: u32, cols: u32) -> Grid {
   grid: Grid;
   grid.rows = rows;
   grid.cols = cols;
   count := rows * cols;
   grid.cells.count = count;
   array_resize(*grid.cells, count);
   // print("Bounds (%, %)\n", cols, rows);
   // print("Grid storage uses % bytes\n", type_info(u32).runtime_size * (cols + 1) * (rows + 1));

   return grid;
}

line_rasterize_vertical :: (grid: *Grid, line: *Line) -> new_overlap_count: u32 {
   assert(line.x1 == line.x2);
   new_overlap_count: u32 = 0;

   y1 := min(line.y1, line.y2);
   y2 := max(line.y1, line.y2);
   for y: y1..y2 {
      grid_index := y * grid.cols + line.x1;
      if grid.cells[grid_index] == 1
         new_overlap_count += 1;
      grid.cells[grid_index] += 1;
   }

   return new_overlap_count;
}

line_rasterize_horizontal :: (grid: *Grid, line: *Line) -> new_overlap_count: u32 {
   assert(line.y1 == line.y2);
   new_overlap_count: u32 = 0;

   x1 := min(line.x1, line.x2);
   x2 := max(line.x1, line.x2);
   for x: x1..x2 {
      grid_index := line.y1 * grid.cols + x;
      if grid.cells[grid_index] == 1
         new_overlap_count += 1;
      grid.cells[grid_index] += 1;
   }

   return new_overlap_count;
}

line_rasterize_diagonal :: (grid: *Grid, line: *Line) -> new_overlap_count: u32 {
   assert(line.x1 != line.x2 && line.y1 != line.y2);
   new_overlap_count: u32 = 0;

   direction_x := ifx line.x2 > line.x1 then 1 else -1;
   direction_y := ifx line.y2 > line.y1 then 1 else -1;
   len_x := (cast(int)line.x2 - cast(int)line.x1) * direction_x;
   len_y := (cast(int)line.y2 - cast(int)line.y1) * direction_y;
   assert(len_x == len_y);

   for i: 0..len_x {
      grid_index := (line.y1 + i * direction_y) * grid.cols + (line.x1 + i * direction_x);
      if grid.cells[grid_index] == 1
         new_overlap_count += 1;
      grid.cells[grid_index] += 1;
   }

   return new_overlap_count;
}

part1 :: (grid: *Grid, lines: []Line) {
   overlapping_cell_count := 0;
   for line, i: lines {
      if (line.x1 == line.x2)
         overlapping_cell_count += line_rasterize_vertical(grid, *line);
      else if (line.y1 == line.y2)
         overlapping_cell_count += line_rasterize_horizontal(grid, *line);
   }

   print("PART1: overlapping count %\n", overlapping_cell_count);
}

part2 :: (grid: *Grid, lines: []Line) {
   overlapping_cell_count := 0;
   for line, i: lines {
      if (line.x1 == line.x2)
         overlapping_cell_count += line_rasterize_vertical(grid, *line);
      else if (line.y1 == line.y2)
         overlapping_cell_count += line_rasterize_horizontal(grid, *line);
      else
         overlapping_cell_count += line_rasterize_diagonal(grid, *line);
   }

   print("PART2: overlapping count %\n", overlapping_cell_count);
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   lines := parse_lines_to_lines(file_contents);
   rows, cols := get_grid_size_from_line_bounds(lines);
   grid := Grid_Create(rows, cols);

   part1(*grid, lines);
   memset(grid.cells.data, 0, type_info(u32).runtime_size * grid.rows * grid.cols); // reset the grid's rasterized data
   part2(*grid, lines);
}
