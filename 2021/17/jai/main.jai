// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";

Area :: struct {
   x1: int; // left edge
   x2: int; // right edge
   y1: int; // bottom edge
   y2: int; // top edge
}
make_area :: (x1: int, x2: int, y1: int, y2: int) -> Area #expand {
   area: Area;
   area.x1 = x1;
   area.x2 = x2;
   area.y1 = y1;
   area.y2 = y2;
   return area;
}

sum_t :: (t: int) -> int {
   total := 0;
   for i: 0..t  total += i;
   return total;
}

area_contains :: (area: *Area, x: int, y: int) -> bool {
   return x >= area.x1 && x <= area.x2 && y <= area.y2 && y >= area.y1;
}

simulate :: (area: *Area, vx0: int, vy0: int) -> (does_hit: bool, max_height: s64) {
   x := 0;
   y := 0;
   vx := vx0;
   vy := vy0;

   max_height: int = S64_MIN;
   while x <= area.x2 && y >= area.y1 {
      x += vx;
      if       vx > 0  vx -= 1;
      else if  vx < 0  vx += 1;

      y += vy;
      vy -= 1;
      max_height = max(max_height, y);

      if area_contains(area, x, y) {
         return true, max_height;
      }
   }

   return false, 0;
}

part1 :: (area: *Area) {
   // There are ways we can stop iterating early such as by tracking the change in height
   // for independently increasing vx and vy, but this is fast enough already and simpler, so...
   max_height := S64_MIN;
   best_vx := 0;
   best_vy := 0;
   for vx: 0..500 {
      for vy: 0..600 {
         // can't start the iteration range below 0, so do the subtraction on a temp var
         vy_actual := vy - 100;
         does_hit, height := simulate(area, vx, vy_actual);
         if does_hit && height > max_height {
            max_height = height;
            best_vx = vx;
            best_vy = vy_actual;
         }
      }
   }
   assert(max_height > S64_MIN);

   print("PART1: max_height = %, best_vx = %, best_vy = %\n", max_height, best_vx, best_vy);
}

part2 :: (area: *Area) {
   success_count := 0;
   for vx: 0..1000 {
      for vy: 0..1000 {
         // can't start the iteration range below 0, so do the subtraction on a temp var
         vy_actual := vy - 300;
         does_hit := simulate(area, vx, vy_actual);
         if does_hit {
            success_count += 1;
         }
      }
   }

   print("PART2: successful velocity configurations: %\n", success_count);
}

main :: () {
   target_area := make_area(139, 187, -148, -89); // input
   // target_area := make_area(20, 30, -10, -5); // test

   // ensure the target is below/right of the starting position, otherwise we need to
   // generalize the algorithm to handle all cases.
   assert(target_area.x1 < target_area.x2);
   assert(target_area.y1 < target_area.y2);
   assert(target_area.x1 > 0);
   assert(target_area.y2 < 0);

   part1(*target_area);
   part2(*target_area);
}
