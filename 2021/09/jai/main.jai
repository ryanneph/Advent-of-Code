// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

Grid :: struct {
   data: *s8;
   rows: int;
   cols: int;
};

Coord :: struct {
   row: int;
   col: int;
   value: s8;
};

grid_find_low_points :: (grid: Grid) -> [..]Coord {
   grid_value :: (r: int, c: int) -> s8 #expand {
      return `grid.data[r * `grid.cols + c];
   }

   low_points: [..]Coord;
   for r: 0..grid.rows-1 {
      for c: 0..grid.cols-1 {
         // check 4-connected neighborhood for values lower than current
         center := grid_value(r, c);
         if (r > 0             && center >= grid_value(r - 1, c)) ||
            (r < grid.rows - 1 && center >= grid_value(r + 1, c)) ||
            (c > 0             && center >= grid_value(r, c - 1)) ||
            (c < grid.cols - 1 && center >= grid_value(r, c + 1)) {;}
         else {
            coord: Coord;
            coord.row = r;
            coord.col = c;
            coord.value = center;
            array_add(*low_points, coord);
         }
      }
   }

   return low_points;
}

part1 :: (grid: Grid) {
   low_points := grid_find_low_points(grid);

   total_risk := 0;
   for low_points {
      total_risk += it.value + 1;
   }

   print("PART1: %\n", total_risk);
}

grid_get_basin_size :: (grid: Grid, row: int, col: int) -> int {
   grid_value_pointer :: (r: int, c: int) -> *s8 #expand {
      return *`grid.data[r * `grid.cols + c];
   }
   enqueue_coord :: (r: int, c: int) #expand {
      coord: Coord;
      coord.row = r;
      coord.col = c;
      // no use for coord.value, just ignore
      array_add(*`to_visit, coord);
   }

   // do bounds check, basin membership check (<9),
   // count basin size, and enqueue eligible neighbors for DFS
   visit_coord :: (r: int, c: int) #expand {
      if (r < 0 || r >= `grid.rows || c < 0 || c >= `grid.cols)
         return;

      value := <<grid_value_pointer(r, c);
      if value < 0  return;
      else if value < 9 {
         `basin_size += 1;
         enqueue_coord(r, c);
      }

      // mark as visited
      <<grid_value_pointer(r, c) = -1;
   }

   to_visit: [..]Coord;
   enqueue_coord(row, col);

   basin_size := 0;
   while to_visit.count > 0 {
      coord := pop(*to_visit);
      visit_coord(coord.row - 1, coord.col);
      visit_coord(coord.row + 1, coord.col);
      visit_coord(coord.row,     coord.col - 1);
      visit_coord(coord.row,     coord.col + 1);
   }

   return basin_size;
}

part2 :: (grid: Grid) {
   // if basin_size is top-3 maximum (so far), add
   // to the list in descending sorted order.
   store_sorted :: (basin_size: int) #expand {
      if basin_size > `max_basin_sizes[0] {
         `max_basin_sizes[2] = `max_basin_sizes[1];
         `max_basin_sizes[1] = `max_basin_sizes[0];
         `max_basin_sizes[0] = basin_size;
      }
      else if basin_size > `max_basin_sizes[1] {
         `max_basin_sizes[2] = `max_basin_sizes[1];
         `max_basin_sizes[1] = basin_size;
      }
      else if basin_size > `max_basin_sizes[2] {
         `max_basin_sizes[2] = basin_size;
      }
   }

   low_points := grid_find_low_points(grid);
   max_basin_sizes: [3]int;
   for low_points {
      basin_size := grid_get_basin_size(grid, it.row, it.col);
      store_sorted(basin_size);
   }

   total := 1;
   for max_basin_sizes {
      assert(it > 0);
      total *= it;
   }

   print("PART2: %\n", total);
}

parse_contents_to_grid :: (contents: string) -> Grid {
   rows := 0;
   cols := 0;
   remainder := contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);
      if !cols  cols = line.count;
      rows += 1;
   }

   heights: *s8 = alloc(rows * cols);
   next := heights;
   remainder = contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);
      assert(line.count == cols);
      for c: 0..cols-1 {
         <<next = cast(s8)(line.data[c] - #char "0");
         next += 1;
      }
   }

   grid: Grid;
   grid.data = heights;
   grid.rows = rows;
   grid.cols = cols;

   return grid;
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   grid := parse_contents_to_grid(file_contents);

   part1(grid);
   part2(grid);
}
