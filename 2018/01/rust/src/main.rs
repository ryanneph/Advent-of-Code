use std::fs;
use std::collections::HashSet;

fn main() {
    part1();
    part2();
}

fn part1() {
    let contents = fs::read_to_string("./input.txt")
        .expect("Failed to read the file");

    let mut accumulator : i32 = 0;
    for line in contents.lines() {
        // println!("{}", line);
        
        let numeric_chars: String = line.chars().skip(1).collect();
        let num: i32 = str::parse::<i32>(&numeric_chars).unwrap();
        // println!("{}: {}", numeric_chars, num);
        if line.chars().nth(0) == Some('+') {
            // println!("ADD");
            accumulator += num;
        }
        else if line.chars().nth(0) == Some('-') {
            // println!("SUB");
            accumulator -= num;
        }
    }

    println!("part1 solution: {}", accumulator);
}

fn part2() {
    let contents = fs::read_to_string("./input.txt")
        .expect("Failed to read the file");

    let mut accumulator : i32 = 0;
    let mut set: HashSet<i32> = HashSet::with_capacity(0);
    let mut done: bool = false;
    loop {
        for line in contents.lines() {
            // println!("{}", line);
            
            let numeric_chars: String = line.chars().skip(1).collect();
            let num: i32 = str::parse::<i32>(&numeric_chars).unwrap();
            // println!("{}: {}", numeric_chars, num);
            if line.chars().nth(0) == Some('+') {
                // println!("ADD");
                accumulator += num;
            }
            else if line.chars().nth(0) == Some('-') {
                // println!("SUB");
                accumulator -= num;
            }

            if set.contains(&accumulator) {
                // println!("Already has {}", accumulator);
                done = true;
                break;
            }
            else {
                // println!("Inserting {}", accumulator);
                set.insert(accumulator);
            }
        }

        if done {
            break;
        }
    }
    println!("part2 solution: {}", accumulator);
}
