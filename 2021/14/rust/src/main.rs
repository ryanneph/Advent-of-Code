use std::fs;
use std::collections::HashMap;
use std::cmp::{min, max};

#[derive(Debug, Clone)]
struct InsertRule<'a> {
    pattern: &'a str,
    insert: char,
}

fn parse_contents_to_rules<'a>(contents: &'a String) -> (&'a str, Vec<InsertRule>) {
    let mut rules = Vec::<InsertRule>::new();

    let template: &str = contents.lines().nth(0).unwrap();

    for line in contents.lines().skip(2) {
        let (pattern, insert_char) = line.split_once(" -> ").unwrap();
        let rule = InsertRule {
            pattern: pattern,
            insert: insert_char.chars().nth(0).unwrap(),
        };
        rules.push(rule);
    }

    return (template, rules);
}

fn do_insertion_step_explicit(polymer: &mut String, rules: &Vec<InsertRule>) {
    let mut polymer_len = polymer.len();
    let mut i = 0;
    while i < polymer_len - 1 { // len - 1 since we need to match against a two char substring
        let substring = polymer[i..i+2].to_string();
        for rule in rules {
            if substring == rule.pattern {
                polymer.insert(i+1, rule.insert);
                polymer_len += 1;
                i += 1; // advance past the newly inserted char for the next loop iter
            }
        }
        i += 1;
    }
}

fn get_min_max_char_counts(char_counts: &[i64; 26]) -> (i64, i64) {
    // get most and least frequent char
    let mut min_count = i64::MAX;
    let mut max_count = i64::MIN;
    for count in char_counts.iter() {
        if *count == 0 { continue; }
        min_count = min(min_count, *count);
        max_count = max(max_count, *count);
    }

    // DEBUG OUTPUT
    // for (index, count) in char_counts.iter().enumerate() {
    //     println!("{}: {}", (index as u8 + 'A' as u8) as char,  count);
    // }
    return (min_count, max_count);
}

fn char_to_index(c: char) -> usize {
    return (c as u8 - 'A' as u8) as usize;
}

fn part1_explicit(template: &str, rules: &Vec<InsertRule>) {
    let mut polymer = template.to_string();
    for _i in 0..10 {
        do_insertion_step_explicit(&mut polymer, rules);
    }

    let mut char_counts = [0 as i64; 26];
    for c in polymer.chars() {
        char_counts[char_to_index(c)] += 1;
    }

    // get most and least frequent char
    let (min_count, max_count) = get_min_max_char_counts(&char_counts);

    println!("PART1 (explicit): max_count - min_count = {}", max_count - min_count);
}

fn add_pattern_count(pattern_counts: &mut HashMap<String, i64>, pattern: String, count: i64) {
    if pattern_counts.contains_key(&pattern) {
        let current_count = pattern_counts.get_mut(&pattern).unwrap();
        let new_count = *current_count + count;
        *current_count = new_count;
    } else {
        pattern_counts.insert(pattern, count);
    }
}

fn do_insertion_step_implicit(pattern_counts: &mut HashMap<String, i64>, char_counts: &mut [i64; 26], rules: &Vec<InsertRule>) {
    let mut new_counts = HashMap::<String, i64>::new();

    for rule in rules {
        if pattern_counts.contains_key(rule.pattern) {
            let count = pattern_counts.get(rule.pattern).unwrap();
            char_counts[char_to_index(rule.insert)] += *count;

            let mut new_pattern = String::new();
            new_pattern.push(rule.pattern.chars().nth(0).unwrap());
            new_pattern.push(rule.insert);
            add_pattern_count(&mut new_counts, new_pattern.clone(), *count as i64);

            new_pattern.clear();
            new_pattern.push(rule.insert);
            new_pattern.push(rule.pattern.chars().nth(1).unwrap());
            add_pattern_count(&mut new_counts, new_pattern.clone(), *count as i64);

            // the existing pattern is no longer present since it has been split by the
            // inserted char.
            add_pattern_count(&mut new_counts, rule.pattern.to_string(), -(*count as i64));
        }
    }

    // combine counts
    for (pattern, count) in new_counts {
        add_pattern_count(pattern_counts, pattern, count as i64);
    }
}

fn part2_implicit(template: &str, rules: &Vec<InsertRule>) {
    let mut pattern_counts = HashMap::<String, i64>::new();
    let mut char_counts = [0 as i64; 26];

    // convert explicit template string into an implicit representation
    // consisting of the count of each unique 2-char pattern string and
    // the count of each individual char.
    for i in 0..template.len()-1 {
        let pattern = template[i..i+2].to_string();
        add_pattern_count(&mut pattern_counts, pattern, 1);
    }
    for c in template.chars() {
        char_counts[char_to_index(c)] += 1;
    }

    for _i in 0..40 {
        do_insertion_step_implicit(&mut pattern_counts, &mut char_counts, rules);
    }

    let (min_count, max_count) = get_min_max_char_counts(&char_counts);

    println!("PART1 (implicit): max_count - min_count = {}", max_count - min_count);
}

fn main() {
    let filename = "../input.txt";
    // let filename = "../test1.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    let (template, rules) = parse_contents_to_rules(&contents);
    // println!("template: {}", template);
    // for rule in &rules {
    //     println!("{:?}", rule);
    // }

    // There are two obvious ways to solve this:
    // 1. Explicitly - where the string is mutated and grown with each insertion
    //    then the final string is processed to determine the highest and lowest
    //    character counts. This is naive and gets slower and bloats the storage
    //    requirements as the number of insertion steps increases.
    // 2. Implicitly - where the string is only represented implicitly as a mapping
    //    from each of the possible 2-character substrings to the count of that
    //    substring that exists in the string. Since we are only required to know
    //    how common each character is (for the final computation), and how many
    //    times a particular 2-character pattern occurs in the string at a given
    //    time (for performing a subsequent insertion step), we don't need to know
    //    the full character order of the string.

    part1_explicit(&template, &rules);
    part2_implicit(&template, &rules);
}
