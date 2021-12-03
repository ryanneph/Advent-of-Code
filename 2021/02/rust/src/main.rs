use std::fs;

fn main() {
    let filename = "../input.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    part1(&contents);
    part2(&contents);
}

struct Command<'a> {
    direction: &'a str,
    distance: i32,
}

fn parse_line(line: &str) -> Result<Command, &'static str > {
    let mut tokens = line.split_whitespace();
    let direction = tokens.next().unwrap();
    let distance_str = tokens.next().unwrap();
    let distance: i32 = str::parse(distance_str).unwrap();

    let command = Command {
        direction: direction,
        distance: distance,
    };
    return Result::Ok(command);
}

fn part1(contents: &String) {
    let mut position: i32 = 0;
    let mut depth:    i32 = 0;

    for line in contents.lines() {
        let command = parse_line(line).unwrap();
        // println!("distance: {}, direction: {}", command.distance, command.direction);
        match command.direction {
            "forward"  => position += command.distance,
            "backward" => position -= command.distance,
            "down"     => depth += command.distance,
            "up"       => depth -= command.distance,
            _ => panic!("Unexpected direction '{}'", command.direction)
        }
    }

    println!("PART1: Final position: {}, depth: {}, product: {}", position, depth, position * depth);
}

fn part2(contents: &String) {
    let mut position: i32 = 0;
    let mut depth:    i32 = 0;
    let mut aim:      i32 = 0;

    for line in contents.lines() {
        let command = parse_line(line).unwrap();
        // println!("distance: {}, direction: {}", command.distance, command.direction);
        match command.direction {
            "forward"  => {
                position += command.distance;
                depth += aim * command.distance;
            },
            "backward"  => {
                position -= command.distance;
                depth -= aim * command.distance;
            },
            "down"     => aim += command.distance,
            "up"       => aim -= command.distance,
            _ => panic!("Unexpected command.direction '{}'", command.direction)
        }
    }

    println!("PART2: Final position: {}, depth: {}, product: {}", position, depth, position * depth);
}
