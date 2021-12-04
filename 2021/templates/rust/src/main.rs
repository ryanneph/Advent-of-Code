use std::fs;

fn main() {
    let filename = "../input.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    part1(&contents);
    part2(&contents);
}

fn part1(contents: &String) {
    for line in contents.lines() {
        println!("{}", line);
    }

    println!("PART1: {}", 0);
}

fn part2(contents: &String) {
    for line in contents.lines() {
        println!("{}", line);
    }

    println!("PART2: {}", 0);
}
