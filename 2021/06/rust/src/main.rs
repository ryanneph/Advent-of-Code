use std::fs;

// Counts the number of additions to vec during the next update
fn count_new_members(counters: &Vec<i8>) -> usize {
    let mut addition_count = 0;
    counters.iter().for_each(|c| {
        if *c == 0 { addition_count += 1; }
    });
    return addition_count;
}

fn part1(mut counters: Vec<i8>) {
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
    for count in counters {
        println!("{}", count);
    }

    println!("PART2: {}", 0);
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
    // part2(counters);
}
