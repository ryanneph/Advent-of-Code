use std::fs;

fn is_opening(c: char) -> bool {
   return c == '(' || c == '[' || c == '{' || c == '<';
}

fn are_complementary(opener: char, closer: char) -> bool {
   return opener == '(' && closer == ')' ||
          opener == '[' && closer == ']' ||
          opener == '{' && closer == '}' ||
          opener == '<' && closer == '>';
}

fn get_complement(opener: char) -> char {
   match opener {
      '(' => ')',
      '[' => ']',
      '{' => '}',
      '<' => '>',
      _ => { panic!("Unexpected char '{}'", opener); },
   }
}

fn parse_and_filter_lines(contents: &String) -> (Vec<&str>, Vec<char>) {
   let mut incompletes = Vec::<&str>::new();
   let mut corruptions = Vec::<char>::new();

   for (_k, line) in contents.lines().enumerate() {
      incompletes.push(line);

      let mut stack = Vec::<char>::new();
      for (_i, c) in line.chars().enumerate() {
         if is_opening(c) { stack.push(c); }
         else if stack.len() == 0 || !are_complementary(*stack.last().unwrap(), c)  {
            incompletes.pop();
            corruptions.push(c);
            break;
         } else { stack.pop(); }
      }
   }

   return (incompletes, corruptions);
}

fn part1(contents: &String) {
   let (_, corruptions) = parse_and_filter_lines(contents);

   let mut total_points = 0;
   for c in corruptions {
      let points = match c {
         ')' => 3,
         ']' => 57,
         '}' => 1197,
         '>' => 25137,
         _ => { panic!("Unexpected char '{}'", c); },
      };
      total_points += points;
   }

   println!("PART1: {}", total_points);
}

fn part2(contents: &String) {
   let (incompletes, _) = parse_and_filter_lines(contents);

   let mut points_per_line = Vec::<u64>::new();
   for line in incompletes {
      let mut completion = Vec::<char>::new();
      for c in line.chars() {
         if is_opening(c) {
            completion.push(get_complement(c));
         } else if completion.len() > 0 && c == *completion.last().unwrap() {
            completion.pop();
         } else { panic!("We are not supposed to have any corruption!"); }
      }

      completion.reverse();
      let mut line_points: u64 = 0;
      for c in &completion {
         let points = match c {
            ')' => 1,
            ']' => 2,
            '}' => 3,
            '>' => 4,
            _ => { panic!("Unexpected char '{}'", c); },
         };
         line_points = line_points * 5 + points;
      }
      points_per_line.push(line_points);
   }

   points_per_line.sort();
   assert!(points_per_line.len() % 2 == 1);
   let median_points = points_per_line[points_per_line.len() / 2];

   println!("PART1: {}", median_points);
}

fn main() {
   let filename = "../input.txt";
   // let filename = "../test1.txt";
   let contents = fs::read_to_string(filename)
      .expect("Failed to read the file");

    part1(&contents);
    part2(&contents);
}
