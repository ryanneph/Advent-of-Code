// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";

// from ../../../jai-common
#import "file";
#import "string";

Risk_Map :: struct {
   data: []u8;
   width: int;
   height: int;
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

   return risk_map;
}

can_visit_node :: (risk_map: Risk_Map, x: s32, y: s32) -> bool #expand {
   return x >= 0 && x < risk_map.width &&
          y >= 0 && y < risk_map.height;
}

// recursive evaluation of the accumulated risk after visiting another node
visit_node :: (risk_map: Risk_Map, x: s32, y: s32, total_risk: s64, min_risk: *s64) {
   if !can_visit_node(risk_map, x, y) { return; } // impossible path
   if total_risk > (<<min_risk)       { return; } // early-stopping

   new_total_risk := total_risk + risk_map.data[y * risk_map.width + x];

   // base-case
   if x == risk_map.width - 1 && y == risk_map.height - 1 {
      if (new_total_risk < (<<min_risk)) {
         print("found path with risk: %\n", new_total_risk);
      }
      <<min_risk = min(new_total_risk, <<min_risk);
      return;
   }

   // TODO(ryan): Assumes we can only travel down/right, but instead should only prohibit revisiting
   // nodes (using a hash set).
   visit_node(risk_map, x + 1, y, new_total_risk, min_risk);
   visit_node(risk_map, x, y + 1, new_total_risk, min_risk);
}

part1 :: (risk_map: Risk_Map) {
   start_node_risk: s64 = xx risk_map.data[0];
   min_risk: s64 = S64_MAX;
   visit_node(risk_map, 0, 0, -start_node_risk, *min_risk); // start node doesn't contribute a cost so we pre-subtract it

   print("PART1: %\n", min_risk);
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

   part1(risk_map);
}
