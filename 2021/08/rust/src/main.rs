use std::collections::HashMap;
use std::fs;

type SignalArray<'a> = [&'a str; 10];
type OutputArray<'a> = [&'a str; 4];

#[derive(Debug)]
struct Sample<'a> {
   signals: SignalArray<'a>,
   outputs: OutputArray<'a>,
}

fn part1(samples: &Vec<Sample>) {
   let mut count = 0;
   for sample in samples {
      for output in sample.outputs {
         if [2, 4, 3, 7].iter().any(|v| *v == output.len()) { count += 1; }
      }
   }

   println!("PART1: count of ouputs in [1, 4, 7, 8]: {}", count);
}

fn hash_signal(signal: &str) -> u64 {
   // TODO(ryan): should use an order-invariant hash function
   // instead of sorting every time...
   let mut sorted_chars: Vec<char> = signal.chars().collect();
   sorted_chars.sort_by(|a, b| b.cmp(a));

   // just implement djb2-hash
   let mut hash: u64 = 5381;
   for c in sorted_chars {
      hash = ((hash << 5) + hash) + c as u64;
   }
   return hash;
}

fn encode_wires_as_bits(signal: &str) -> u8 {
   let mut bits: u8 = 0;
   for c in signal.chars() {
      let shift = c as u32 - 'a' as u32;
      assert!(shift < 8);
      bits |= 1 << shift;
   }
   return bits & 0xFF;
}

fn count_high_bits(mut bits: u8) -> u8 {
   let mut high_count = 0;
   for _i in 1..8 {
      high_count += 1 & bits;
      bits = bits >> 1;
   }
   return high_count;
}

fn deduce_signals_and_build_hash_map(signals: &SignalArray) -> HashMap<u64, i32> {
   let mut map = HashMap::<u64, i32>::with_capacity(10);
   let mut unknown_signals = signals.to_vec();

   let mut bits_for_digit_1: u8 = 0;
   let mut bits_for_digit_4: u8 = 0;
   let mut bits_for_digit_9: u8 = 0;

   // The first four are based solely on the count of active wires
   unknown_signals.retain(|signal| {
      let len = signal.len();
      if len == 2 {
         map.insert(hash_signal(signal), 1);
         bits_for_digit_1 = encode_wires_as_bits(signal);
      } else if len == 3 {
         map.insert(hash_signal(signal), 7);
      } else if len == 4 {
         map.insert(hash_signal(signal), 4);
         bits_for_digit_4 = encode_wires_as_bits(signal);
      } else if len == 7 {
         map.insert(hash_signal(signal), 8);
      } else {
         return true; // keep in vec
      }
      return false; // remove from vec
   });

   // The next three are based on clever bitwise-and followed by counting the
   // number of active bits for specific combinations of signals encoded as
   // bitstrings.
   unknown_signals.retain(|signal| {
      let len = signal.len();
      let signal_bits = encode_wires_as_bits(signal);

      if len == 6 {
         // NOTE(ryan): the order of these conditions matters.
         // For example, digit '6' matches both the '6' & '1' == 1
         // and the '6' & '4' == 3 rules, but we rely on the latter
         // rule for deducing digit '0'.
         if count_high_bits(signal_bits & bits_for_digit_1) == 1 {
            map.insert(hash_signal(signal), 6);
         } else if count_high_bits(signal_bits & bits_for_digit_4) == 4 {
            map.insert(hash_signal(signal), 9);
            bits_for_digit_9 = signal_bits;
         } else if count_high_bits(signal_bits & bits_for_digit_4) == 3 {
            map.insert(hash_signal(signal), 0);
         } else {
            panic!("Unhandled case: {}", signal);
         }
         return false; // remove from vec
      } else {
         return true; // keep in vec
      }
   });

   // The final thre are also based on clever bitwise-and, but rely on knowing
   // the bitstring for the 9-digit already (discovered in the previous block).
   unknown_signals.retain(|signal| {
      let len = signal.len();
      let signal_bits = encode_wires_as_bits(signal);

      if len == 5 {
         if count_high_bits(signal_bits & bits_for_digit_1) == 2 {
            map.insert(hash_signal(signal), 3);
         } else if count_high_bits(signal_bits & bits_for_digit_9) == 4 {
            map.insert(hash_signal(signal), 2);
         } else if count_high_bits(signal_bits & bits_for_digit_9) == 5 {
            map.insert(hash_signal(signal), 5);
         } else {
            panic!("Unhandled case: {}", signal);
         }
         return false; // remove from vec
      } else {
         return true; // keep in vec
      }
   });
   assert!(unknown_signals.len() == 0);
   return map;
}

fn part2(samples: &Vec<Sample>) {
   let mut total = 0;
   for sample in samples {
      // For each sample, need to deduce the correct mapping from signals to digits,
      // then use that to decode the output and sum them across samples.
      // So fill the hash table for fast mapping between wire-set and output digit
      let output_hash = deduce_signals_and_build_hash_map(&sample.signals);

      let mut digit_factor = 1000;
      for output in sample.outputs {
         let hash = hash_signal(output);
         let value = output_hash.get(&hash);
         if value.is_some() {
            total += digit_factor * value.unwrap();
            digit_factor /= 10;
         } else {
            panic!("Couldn't find value for output '{}' with hash {}", output, hash);
         }
      }
   }

   println!("PART2: sum of decoded outputs: {}", total);
}

fn parse_contents_to_samples(contents: &String) -> Vec<Sample> {
   let mut samples = Vec::<Sample>::new();
   for line in contents.lines() {
      let (signal_str, output_str) = line.trim().split_once(" | ").unwrap();

      let mut signal_iter = signal_str.split(" ");
      // TODO(ryan): yuck, replace with macro?
      let signal: [&str; 10] = [
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
         signal_iter.next().unwrap(),
      ];

      let mut output_iter = output_str.split(" ");
      // TODO(ryan): yuck, replace with macro?
      let output: [&str; 4] = [
         output_iter.next().unwrap(),
         output_iter.next().unwrap(),
         output_iter.next().unwrap(),
         output_iter.next().unwrap(),
      ];

      let sample = Sample {
         signals: signal,
         outputs: output,
      };
      samples.push(sample);
   }

   return samples;
}

fn main() {
   let filename = "../input.txt";
   // let filename = "../test1.txt";
   // let filename = "../test2.txt";
   let contents = fs::read_to_string(filename)
      .expect("Failed to read the file");
    let samples = parse_contents_to_samples(&contents);

    part1(&samples);
    part2(&samples);
}
