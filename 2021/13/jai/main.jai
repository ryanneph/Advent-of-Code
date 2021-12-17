// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Hash";
#import "Hash_Table";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Coord :: struct {
   x, y: int;
};
make_coord :: (x: int, y: int) -> Coord {
   coord: Coord;
   coord.x = x;
   coord.y = y;
   return coord;
}
coord_hash :: (coord: Coord) -> u32 {
   return (get_hash(coord.x) + get_hash(coord.y)) % U32_MAX;
}

coord_compare :: (c1: Coord, c2: Coord) -> bool {
   return c1.x == c2.x && c1.y == c2.y;
}

Axis :: enum {
   XAXIS;
   YAXIS;
}
Fold :: struct {
   axis: Axis;
   value: int;
}

parse_contents_to_data :: (contents: string) -> (coords: [..]Coord, folds: [..]Fold) {
   parse_coords := true;
   coords: [..]Coord;
   folds: [..]Fold;

   remainder := contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      if line.count == 0 {
         parse_coords = false;
         continue;
      }

      if parse_coords {
         found, x, y := split_from_left(line, ",");
         assert(found);
         array_add(*coords, make_coord(xx to_integer(x), xx to_integer(y)));
      } else {
         found, _, spec := split_from_right(line, " ");
         assert(found);
         found2, axis, value := split_from_left(spec, "=");
         assert(found2);

         using Axis;
         fold: Fold;
         fold.axis = xx ifx axis == "x" then XAXIS else YAXIS;
         fold.value = to_integer(value);
         array_add(*folds, fold);
      }
   }

   assert(coords.count > 0);
   assert(folds.count > 0);
   return coords, folds;
}

fold_coord :: (coord: Coord, fold: Fold) -> Coord {
   folded_coord := coord;

   using Axis;
   if #complete fold.axis == {
   case XAXIS;
      folded_coord.x = fold.value - (coord.x - fold.value);
   case YAXIS;
      folded_coord.y = fold.value - (coord.y - fold.value);
   }

   return folded_coord;
}

is_beyond_the_fold :: (coord: Coord, fold: Fold) -> bool {
   value := ifx fold.axis == Axis.XAXIS then coord.x else coord.y;
   assert(value != fold.value);
   return value > fold.value;
}

fold_once :: (coords: []Coord, fold: Fold) -> []Coord {
   // use Table as a hash set by setting value to arbitrary bool
   // (in the past, I've used 'void' for the Value_Type, but it's
   // not working this time for some reason...).
   coords_set: Table(Coord, bool, coord_hash, coord_compare);

   for coord: coords {
      if is_beyond_the_fold(coord, fold) {
         folded_coord := fold_coord(coord, fold);
         table_set(*coords_set, folded_coord, false);
      } else {
         // safely add to set, even if already there.
         table_set(*coords_set, coord, false);
      }
   }

   new_coords: [..]Coord;
   for _, coord: coords_set
      array_add(*new_coords, coord);

   return new_coords;
}

part1 :: (coords: []Coord, first_fold: Fold) {
   new_coords := fold_once(coords, first_fold);

   print("PART1: %\n", new_coords.count);
}

visualize_coords :: (coords: []Coord) {
   min_coord := make_coord(S64_MAX, S64_MAX);
   max_coord := make_coord(S64_MIN, S64_MIN);

   for coord: coords {
      min_coord.x = min(min_coord.x, coord.x);
      min_coord.y = min(min_coord.y, coord.y);
      max_coord.x = max(max_coord.x, coord.x);
      max_coord.y = max(max_coord.y, coord.y);
   }

   display_size_x := max_coord.x - min_coord.x + 1;
   display_size_y := max_coord.y - min_coord.y + 1;

   display: *u8 = alloc(display_size_x * display_size_y); // (set element to >0 for a coord occupying that space)
   memset(display, 0, display_size_x * display_size_y);
   for coord: coords {
      display[display_size_x * (coord.y - min_coord.y) + (coord.x - min_coord.x)] = 1;
   }

   for r: 0..display_size_y-1 {
      print("  ");
      for c: 0..display_size_x-1 {
         if (display[display_size_x * r + c])  print("#");
         else                                  print(" ");
      }
      print("\n");
   }

   free(display);
}

part2 :: (coords: []Coord, folds: []Fold) {
   new_coords: []Coord = coords;
   for fold: folds {
      new_coords = fold_once(new_coords, fold);
   }
   print("PART2: (see below)\n");
   visualize_coords(new_coords);
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   coords, folds := parse_contents_to_data(file_contents);

   part1(coords, folds[0]);
   part2(coords, folds);
}
