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

fn board_set_cell_number(board: &mut Board, row: usize, column: usize, number: u8) {
    let cell_index = (row * 5 + column) as usize;
    board.cells[cell_index].number = number;
}

fn board_mark_cell(board: &mut Board, row: usize, column: usize) {
    let cell_index = (row * 5 + column) as usize;
    board.cells[cell_index].marked = true;
}

fn board_find_number(board: &Board, number: u8) -> (bool, usize, usize) {
    for row in 0..5 {
        for col in 0..5 {
            let cell = &board.cells[row * 5 + col];
            if cell.number == number {
                return (true, row, col);
            }
        }
    }

    return (false, 0, 0);
}

fn parse_lines_to_board<'a>(lines: &mut std::iter::Peekable<std::str::Lines>) -> Board {
    let mut board = Board::default();

    for row in 0..5 {
        let line = lines.next().unwrap();
        for (col, number_string) in line.split_whitespace().enumerate() {
            let number: u8 = number_string.parse().unwrap();
            board_set_cell_number(&mut board, row, col, number);
        }
    }
    lines.next(); // skip empty line

    return board;
}

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

fn board_sum_unmarked(board: &Board) -> u32 {
    let mut sum: u32 = 0;
    for cell in &board.cells {
        if !cell.marked {
            sum += cell.number as u32;
        }
    }
    return sum;
}

fn part1(contents: &String) {
    let mut lines = contents.lines().peekable();

    // parse the first line
    let mut numbers = Vec::<u8>::new();
    let first_line = lines.next().unwrap();
    lines.next(); // skip empty line
    for number_string in first_line.split(",") {
        numbers.push(number_string.parse().unwrap());
    }

    // parse the boards
    let mut boards = Vec::<Board>::new();
    let mut next_line = lines.peek();
    while next_line.is_some() {
        boards.push(parse_lines_to_board(&mut lines));
        next_line = lines.peek();
    }

    // println!("Read in {} boards", boards.len());
    // for board in &boards {
    //     board_print_numbers(&board);
    // }

    let mut current_number: u8 = 0;
    let mut found_winner = false;
    let mut winning_board = Board::default();
    for number in numbers {
        if found_winner {
            break;
        }
        current_number = number;

        for mut board in &mut boards {
            if found_winner {
                break;
            }

            let (found, row, col) = board_find_number(&board, number);
            if found {
                board_mark_cell(&mut board, row, col);
                if board_check_winning(&board) {
                    winning_board = *board;
                    found_winner = true;
                }
            }
        }
    }

    assert!(found_winner);
    // board_print_numbers(&winning_board);
    let sum = board_sum_unmarked(&winning_board);

    println!("PART1: {}", sum * current_number as u32);
}

fn part2(contents: &String) {
    println!("PART2: {}", 0);
}

fn main() {
    let filename = "../input.txt";
    // let filename = "../test1.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    part1(&contents);
    part2(&contents);
}
