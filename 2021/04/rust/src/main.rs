use std::fs;

#[derive(Debug, Default, Copy, Clone)]
struct BoardCell {
    number: u8,
    marked: bool,
}

#[derive(Debug, Default, Copy, Clone)]
struct Board {
    cells: [BoardCell; 25],
}

// FOR DEBUG USE
#[allow(dead_code)]
fn board_print_numbers(board: &Board) {
    for row in 0..5 {
        for col in 0..5 {
            let cell = &board.cells[row * 5 + col];
            if cell.marked {
                print!("[{:02}] ", cell.number);
            } else {
                print!(" {:02}  ", cell.number);
            }
        }
        print!("\n");
    }
    print!("\n");
}

fn board_mark_number(board: &mut Board, number: u8) -> bool {
    for cell in &mut board.cells {
        if cell.number == number {
            cell.marked = true;
            return true;
        }
    }
    return false;
}

fn board_check_winning(board: &Board) -> bool {
    // any full rows?
    for row in 0..5 {
        let mut all_marked = true;
        for col in 0..5 {
            let cell = &board.cells[row * 5 + col];
            if !cell.marked {
                all_marked = false;
                break;
            }
        }

        if all_marked {
            return true;
        }
    }

    // any full columns?
    for col in 0..5 {
        let mut all_marked = true;
        for row in 0..5 {
            let cell = &board.cells[row * 5 + col];
            if !cell.marked {
                all_marked = false;
                break;
            }
        }

        if all_marked {
            return true;
        }
    }

    return false;
}

fn board_mark_and_check_winning(board: &mut Board, number: u8) -> bool {
    if board_mark_number(board, number) {
        return board_check_winning(&board);
    }
    return false;
}

fn board_sum_unmarked(board: &Board) -> u32 {
    let mut sum: u32 = 0;
    for cell in &board.cells {
        if !cell.marked {
            sum += cell.number as u32;
        }
    }
    return sum;
}

fn parse_lines_to_board<'a>(lines: &mut std::iter::Peekable<std::str::Lines>) -> Board {
    let mut board = Board::default();

    for row in 0..5 {
        let line = lines.next().unwrap();
        for (col, number_string) in line.split_whitespace().enumerate() {
            let number: u8 = number_string.parse().unwrap();
            board.cells[row * 5 + col].number = number;
        }
    }
    lines.next(); // skip empty line

    return board;
}

fn parse_lines_to_boards<'a>(mut lines: &mut std::iter::Peekable<std::str::Lines>) -> Vec<Board> {
    let mut boards = Vec::<Board>::new();
    let mut next_line = lines.peek();
    while next_line.is_some() {
        boards.push(parse_lines_to_board(&mut lines));
        next_line = lines.peek();
    }

    return boards;
}

fn parse_line_to_numbers<'a>(lines: &mut std::iter::Peekable<std::str::Lines>) -> Vec<u8> {
    let mut numbers = Vec::<u8>::new();
    let first_line = lines.next().unwrap();
    for number_string in first_line.split(",") {
        numbers.push(number_string.parse().unwrap());
    }

    return numbers;
}

fn part1(numbers: &Vec<u8>, mut boards: Vec<Board>) {
    let mut first_winning_board_score = 0;
    'number_loop: for number in numbers {
        for mut board in &mut boards {
            let winning = board_mark_and_check_winning(&mut board, *number);
            if winning {
                first_winning_board_score = board_sum_unmarked(board) * *number as u32;
                break 'number_loop;
            }
        }
    }

    println!("PART1: {}", first_winning_board_score);
}

fn part2(numbers: &Vec<u8>, mut boards: Vec<Board>) {
    let mut last_winning_board_score: u32 = 0;
    'number_loop: for number in numbers {
        let mut board_index = 0;
        while board_index < boards.len() {
            let remaining_boards_count = boards.len();

            let mut board = &mut boards[board_index];
            if board_mark_and_check_winning(&mut board, *number) {
                if remaining_boards_count == 1 {
                    last_winning_board_score = board_sum_unmarked(&board) * *number as u32;
                    break 'number_loop;
                } else {
                    boards.swap_remove(board_index);
                    continue; // without incrementing board_index
                }
            }
            board_index += 1;
        }

    }
    println!("PART2: {}", last_winning_board_score);
}

fn main() {
    let filename = "../input.txt";
    // let filename = "../test1.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    let mut lines = contents.lines().peekable();

    // parse the first line
    let numbers: Vec<u8> = parse_line_to_numbers(&mut lines);
    lines.next(); // skip empty line

    // parse remainder of file
    let boards: Vec<Board> = parse_lines_to_boards(&mut lines);
    let boards_copy = boards.clone();

    part1(&numbers, boards);
    part2(&numbers, boards_copy);
}
