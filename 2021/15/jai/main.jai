// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "Hash";
#import "Hash_Table";

// from ../../../jai-common
#import "file";
#import "string";

Risk_Map :: struct {
   data: []u8;
   width: int;
   height: int;

   // special rule: the map represented can tile vertically/horizontally, but each tile
   // has risk values corresponding to the original tile according to the formula:
   //    new_risk = (original_risk + tile_index_x + tile_index_y) % 9
   // only if (original_risk + tile_index_x + tile_index_y) > 9. This corresponds to a
   // wrap from 9 -> 1 (bypassing 0).
   tile_count_x: int;
   tile_count_y: int;
}

parse_contents_to_risk_map :: (contents: string) -> (risk_map: Risk_Map) {
   width := 0;
   height := 0;

   remainder := contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);
      if !width  width = line.count;
      height += 1;
   }

   data: [..]u8;
   array_resize(*data, width * height);

   row := 0;
   remainder = contents;
   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      for col: 0..width-1 {
         sub := to_string(*line.data[col], 1);
         risk, success := to_integer(sub);
         assert(success);
         assert(risk >= 0 && risk < U8_MAX);
         data[row * width + col] = cast(u8) risk;
      }
      row += 1;
   }

   risk_map: Risk_Map;
   risk_map.data = data;
   risk_map.width = width;
   risk_map.height = height;
   risk_map.tile_count_x = 1;
   risk_map.tile_count_y = 1;

   return risk_map;
}

Position :: struct {
   x, y: s32;
}
make_position :: (x: s32, y: s32) -> Position {
   position: Position = ---;
   position.x = x;
   position.y = y;
   return position;
}
position_hash :: (position: Position) -> u32 {
   return (get_hash(position.x) + get_hash(position.y)) % U32_MAX;
}
position_compare :: (p1: Position, p2: Position) -> bool {
   return p1.x == p2.x && p1.y == p2.y;
}

Candidate :: struct {
   position: Position;
   risk: s64;
}
make_candidate :: (position: Position, risk: s64) -> Candidate {
   candidate: Candidate = ---;
   candidate.position = position;
   candidate.risk = risk;
   return candidate;
}

candidates_add_sorted_or_decrease :: (candidates: *[..]Candidate, new_candidate: Candidate)
                                     -> min_risk_to_node: s64
{
   // array is maintained in sorted order by decreasing risk, such that pop() gives
   // the lowest risk candidate in constant time.
   // check if already a member; if so and new risk is lower, update
   for i: 0..candidates.count-1 {
      it: *Candidate = *candidates.data[i];
      if (position_compare(it.position, new_candidate.position)) {
         if it.risk > new_candidate.risk { it.risk = new_candidate.risk; }
         return it.risk;
      }
   }

   i := 0;
   for <<candidates {
      if it.risk < new_candidate.risk  break;
      i += 1;
   }
   array_insert_at(candidates, new_candidate, i);
   return new_candidate.risk;
}

can_visit_node :: inline (risk_map: *Risk_Map, x: s32, y: s32) -> bool {
   return x >= 0 && y >= 0 &&
          x < risk_map.width  * risk_map.tile_count_x &&
          y < risk_map.height * risk_map.tile_count_y;
}

is_end_node :: inline (risk_map: *Risk_Map, x: s32, y: s32) -> bool {
   return x == risk_map.width * risk_map.tile_count_x - 1 &&
          y == risk_map.height * risk_map.tile_count_y - 1;
}

get_risk :: inline (risk_map: *Risk_Map, x: s32, y: s32) -> s64 {
   assert(risk_map.tile_count_x > 0 && risk_map.tile_count_y > 0);
   assert(can_visit_node(risk_map, x, y));
   tile_index_x := x / risk_map.width;
   tile_index_y := y / risk_map.height;

   data_index_x := x % risk_map.width;
   data_index_y := y % risk_map.height;

   // we wrap from 9 -> 1 (not 0)
   risk := risk_map.data[data_index_y * risk_map.width + data_index_x] + tile_index_x + tile_index_y;
   if risk > 9  risk = risk % 9;
   return risk;
}

dijkstra_get_min_path_risk :: (risk_map: *Risk_Map) -> min_risk: s64 {
   // Dijkstra's algorithm
   candidates: [..]Candidate;

   // maintain total risk of neighbors throughout Dijkstra's algorithm
   risk_to_node: Table(Position, s64, position_hash, position_compare);
   visited: Table(Position, Any, position_hash, position_compare);

   // add start node
   candidates_add_sorted_or_decrease(*candidates, make_candidate(make_position(0, 0), 0));
   table_set(*visited, make_position(0, 0), false);

   best_risk: s64 = -1;
   while candidates.count > 0 {
      c := pop(*candidates); // get lowest risk candidate
      if is_end_node(risk_map, c.position.x, c.position.y) {
         best_risk = c.risk;
         break;
      }
      table_set(*visited, c.position, false);

      update_neighbor :: (offset_x: s32, offset_y: s32) #expand {
         position := make_position(`c.position.x + offset_x, `c.position.y + offset_y);
         if can_visit_node(`risk_map, position.x, position.y) && !table_find_pointer(visited, position) {
            // update minimum risk to neighbor, we don't care about the path so we omit the
            // pointer to 'previous' node.
            risk_to_neighbor := `c.risk + get_risk(`risk_map, position.x, position.y);

            // add current risk_to_neighbor if it doesn't exist, or update if it's the lowest so
            // far. The lowest so far is always returned so it can be used elsewhere.
            min_risk_to_neighbor := candidates_add_sorted_or_decrease(*candidates, make_candidate(position, risk_to_neighbor));

            old_risk_to_node, found := table_find(risk_to_node, position);
            if !found || old_risk_to_node > min_risk_to_neighbor
               table_set(*`risk_to_node, position, min_risk_to_neighbor);
         }
      }

      update_neighbor(-1,  0);
      update_neighbor( 0, -1);
      update_neighbor( 1,  0);
      update_neighbor( 0,  1);
   }

   assert(best_risk > 0);
   return best_risk;
}

part1 :: (risk_map: *Risk_Map) {
   risk_map.tile_count_x = 1;
   risk_map.tile_count_y = 1;
   best_risk := dijkstra_get_min_path_risk(risk_map);

   print("PART1: %\n", best_risk);
}

part2 :: (risk_map: *Risk_Map) {
   // like part 1 except we actually allow tiling
   risk_map.tile_count_x = 5;
   risk_map.tile_count_y = 5;
   best_risk := dijkstra_get_min_path_risk(risk_map);

   print("PART2: %\n", best_risk);
}

main :: () {
   filename := "../input.txt";
   // filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   risk_map := parse_contents_to_risk_map(file_contents);

   part1(*risk_map);
   part2(*risk_map);
}
