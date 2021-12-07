// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

find_best_position :: (positions: []int, cost_proc: (position: int, alignment: int) -> int)
                      -> (best_position: int, best_cost: int)
{
   min_position := S64_MAX;
   max_position := S64_MIN;
   for position: positions {
      min_position = min(min_position, position);
      max_position = max(max_position, position);
   }

   min_cost := S64_MAX;
   best_position := min_position - 1;
   for i: min_position..max_position {
      cost := 0;
      for position: positions {
         cost += cost_proc(position, i);
      }
      if (cost < min_cost) {
         min_cost = cost;
         best_position = i;
      }
   }

   assert(best_position >= min_position && best_position <= max_position);
   return best_position, min_cost;
}

part1 :: (positions: []int) {
   cost_proc :: (position, alignment) => abs(position - alignment);
   best_position, best_cost := find_best_position(positions, cost_proc);
   print("PART1: minimal cost position: %, total fuel cost: %\n", best_position, best_cost);
}

part2 :: (positions: []int) {
   cost_proc :: (position: int, alignment: int) -> int {
      distance := abs(position - alignment);
      return distance * (distance + 1) / 2;
   }

   best_position, best_cost := find_best_position(positions, cost_proc);
   print("PART2: minimal cost position: %, total fuel cost: %\n", best_position, best_cost);
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   tokens: []string = split(trim(file_contents, "\n "), ",");
   positions: [..]int;
   array_reserve(*positions, tokens.count);
   for tokens array_add(*positions, to_integer(it));

   part1(positions);
   part2(positions);
}
