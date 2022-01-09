// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Sort";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Beacon :: struct {
   r1, r2, r3: int;
}
make_beacon_from_csv :: (csv: string) -> Beacon {
   beacon: Beacon;
   next_as_int :: () -> int #expand {
      found, left, right := split_from_left(`remainder, ",");
      if found  `remainder = right;
      v, success := to_integer(left);
      assert(success);
      return v;
   }

   remainder := csv;
   beacon.r1 = next_as_int();
   beacon.r2 = next_as_int();
   beacon.r3 = next_as_int();
   return beacon;
}
operator- :: (beacon: Beacon) -> Beacon {
   new_beacon: Beacon;
   new_beacon.r1 = -beacon.r1;
   new_beacon.r2 = -beacon.r2;
   new_beacon.r3 = -beacon.r3;
   return new_beacon;
}
operator+ :: (beacon1: Beacon, beacon2: Beacon) -> Beacon {
   new_beacon: Beacon;
   new_beacon.r1 = beacon1.r1 + beacon2.r1;
   new_beacon.r2 = beacon1.r2 + beacon2.r2;
   new_beacon.r3 = beacon1.r3 + beacon2.r3;
   return new_beacon;
}
operator- :: inline (beacon1: Beacon, beacon2: Beacon) -> Beacon {
   return beacon1 + -beacon2;
}

Scanner :: struct {
   beacons: [..]Beacon;
}

parse_contents :: (contents: string) -> [..]Scanner {
   scanners: [..]Scanner;
   scanner: Scanner;

   remainder := contents;
   // skip the first line since it will always be the beginning of a scanner
   {
      line: string;
      line, remainder = string_next_line(remainder);
      assert(begins_with(line, "--- scanner"));
   }

   while remainder.count {
      line: string;
      line, remainder = string_next_line(remainder);

      if !line.count  continue;
      if begins_with(line, "--- ") {
         array_add(*scanners, scanner);
         new_scanner: Scanner;
         scanner = new_scanner;
         continue;
      }

      beacon := make_beacon_from_csv(line);
      array_add(*scanner.beacons, beacon);
   }
   array_add(*scanners, scanner);

   return scanners;
}

part1 :: (scanners: []Scanner) {

   x_positions: [..]int;

   for scanner: scanners {
      print("Scanner #% (% beacons)\n", it_index, scanner.beacons.count);
      ref_beacon := scanner.beacons[0];

      for beacon: scanner.beacons {
         rel_beacon := beacon - ref_beacon;
         if !it_index  continue;

         array_add(*x_positions, rel_beacon.r1);

         // print("(%, %, %) --> (%, %, %)\n",
         //       beacon.r1, beacon.r2, beacon.r3,
         //       rel_beacon.r1, rel_beacon.r2, rel_beacon.r3);
      }

      sorted := quick_sort(x_positions, (a, b) => ifx (a < b) then -1 else 1);
      for x_positions {
         print("%\n", it);
      }
   }

   print("PART1: %\n", 0);
}

main :: () {
   // filename := "../input.txt";
   filename := "../test1.txt";
   file_contents, success := file_read_all_as_string(filename);
   if (!success) {
      print("ERROR - failed to read contents of file '%'\n", filename);
      return;
   }

   scanners := parse_contents(file_contents);
   print("Found % scanners\n", scanners.count);

   part1(scanners);
}
