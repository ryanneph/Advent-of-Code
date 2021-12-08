use std::fs;
use std::collections::HashMap;

// Counts the number of additions to vec during the next update
fn count_new_members(counters: &Vec<i8>) -> usize {
   let mut addition_count = 0;
   counters.iter().for_each(|c| {
      if *c == 0 { addition_count += 1; }
   });
   return addition_count;
}

// Memoized procedure for counting the total number of fish originating
// from a single fish with a specific number of days remaining
fn calculate_final_count_from_one(days_remaining: i32, cache: &mut HashMap::<i32, u64>) -> u64 {
   if days_remaining <= 0 { return 1; } // base case

   let cached_value = cache.get(&days_remaining);
   if cached_value.is_some() {
      // println!("Found cached value for (key: {}, value: {})", days_remaining, *cached_value.unwrap());
      return *cached_value.unwrap();
   }

   let total_count = calculate_final_count_from_one(days_remaining - 7, cache) +
      calculate_final_count_from_one(days_remaining - 9, cache);

   cache.insert(days_remaining, total_count);
   return total_count;
}

fn part1(mut counters: Vec<i8>) {
   // NOTE(ryan): This can be updated to use the memoization approach
   // of part2, but I'm leaving it as the naive approach becuase that's
   // how I originally solved part1.

   for _day in 0..80 {
      // extend the vec with new counters,
      // but only iterate over the original length for updates
      let original_len = counters.len();
      let addition_count = count_new_members(&counters);
      counters.resize(original_len + addition_count, 8);

      for count in &mut counters[..original_len] {
         if *count == 0 { *count = 6; }
         else           { *count -= 1; }
      }
   }

   println!("PART1: fish after 80 days: {}", counters.len());
}

fn part2(mut counters: Vec<i8>) {
   let total_days = 256;
   let mut cache = HashMap::<i32, u64>::new();

   let mut total_count = 0;
   for count in &mut counters {
      // BEWARE, this is a recursive form of dynamic programming
      // To avoid stack overflow from excessive recursion, it _could_
      // be converted to a looping form instead. Looping form is almost
      // always a better idea but often isn't as clear and instructive.
      total_count += calculate_final_count_from_one(total_days - *count as i32, &mut cache);
   }

   println!("PART2: fish after {} days: {}", total_days, total_count);
}


fn main() {
   let filename = "../input.txt";
   // let filename = "../test1.txt";
   let contents = fs::read_to_string(filename)
      .expect("Failed to read the file");

    let counters: Vec<i8> = contents
       .trim()
       .split(',')
       .map(|string| string.parse::<i8>().unwrap())
       .collect();

    part1(counters.clone());
    part2(counters);
}
