use std::fs;

fn part1() {
   println!("PART1: {}", 0);
}

fn main() {
   // let filename = "../input.txt";
   let filename = "../test1.txt";
   let contents = fs::read_to_string(filename)
      .expect("Failed to read the file");

   for line in contents.lines() {
      println!("{}", line);
   }

    part1();
}
