// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";

// from ../../../jai-common
#import "file";
#import "string";

Grid :: struct {
    width, height: s64;
    data: [..]s64;
    seen: [..]bool;
}

tree_height :: inline (grid: *Grid, row: s64, col: s64) -> s64 {
    return grid.data[row * grid.width + col];
}

out_of_bounds :: inline (grid: *Grid, row: s64, col: s64) -> bool {
    return row < 0 || row >= grid.height || col < 0 || col >= grid.width;
}

print_grid :: (grid: Grid) {
    for r: 0..grid.height-1 {
        for c: 0..grid.width-1 {
            print("%", grid.data[r * grid.width + c]);
        }
        print("\n");
    }
}

count_visible_in_line :: (grid: Grid, start_row: s64, start_col: s64, update_row: s64, update_col: s64)
                         -> (visible_count: s64)
{
    row := start_row;
    col := start_col;
    tallest := -1;
    visible_count := 0;
    while true {
        index := row * grid.width + col;
        tree := grid.data[index];
        seen := *grid.seen[index];
        if (tree > tallest) {
            tallest = tree;
            if !(<<seen) {
                visible_count += 1;
                <<seen = true;
            }
        }

        row += update_row;
        col += update_col;
        if out_of_bounds(*grid, row, col)
            break;
    }

    return visible_count;
}

part_1 :: (grid: *Grid) {
    // begin at each non-corner edge location and step inward. If a tree is taller than the tallest
    // seen so far in the line and it hasn't been marked seen in another search, count as visible.
    // Add the four corners as visible, since they aren't iterated by the algorithm.
    visible_count := 4; // 4 corners are never counted by sub-routine

    row := 0;
    for col: 1..grid.width-2 {
        visible_count += count_visible_in_line(grid, row, col, 1, 0);
    }

    row = grid.height-1;
    for col: 1..grid.width-2 {
        visible_count += count_visible_in_line(grid, row, col, -1, 0);
    }

    col := 0;
    for row: 1..grid.height-2 {
        visible_count += count_visible_in_line(grid, row, col, 0, 1);
    }

    col = grid.width-1;
    for row: 1..grid.height-2 {
        visible_count += count_visible_in_line(grid, row, col, 0, -1);
    }

    print("part1: %\n", visible_count);
}

calculate_scenic_score :: (grid: *Grid, start_row: s64, start_col: s64) -> s64 {
    treehouse := tree_height(grid, start_row, start_col);
    score := 1;

    Update :: struct { row, col: s64; };
    updates :: Update.[Update.{1, 0}, Update.{-1, 0}, Update.{0, 1}, Update.{0, -1}];
    for update: updates {
        view_distance := 0;
        row := start_row + update.row;
        col := start_col + update.col;
        while !out_of_bounds(grid, row, col) {
            view_distance += 1;

            tree := tree_height(grid, row, col);
            if tree >= treehouse break;

            row += update.row;
            col += update.col;
        }
        score *= view_distance;
    }

    return score;
}

part_2 :: (grid: *Grid) {
    highest_score := 0;
    for row: 0..grid.height-1 {
        for col: 0..grid.width-1 {
            score := calculate_scenic_score(grid, row, col);
            if score > highest_score
                highest_score = score;
        }
    }
    print("part2: %\n", highest_score);
}

parse_to_grid :: (file_contents: File_Contents) -> Grid {
    grid: Grid;
    grid.height = 0;
    for line: file_contents {
        grid.width = line.count;
        grid.height += 1;

        for i: 0..line.count-1
            array_add(*grid.data, line[i] - #char "0");
    }
    array_resize(*grid.seen, grid.width * grid.height);

    return grid;
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    grid := parse_to_grid(file_contents);

    part_1(*grid);
    part_2(*grid);
}
