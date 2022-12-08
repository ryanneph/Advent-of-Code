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
        if (row < 0 || row >= grid.height || col < 0 || col >= grid.width)
            break;
    }

    return visible_count;
}

part_1 :: (contents: File_Contents) {
    grid: Grid;
    grid.height = 0;
    for line: contents {
        grid.width = line.count;
        grid.height += 1;

        for i: 0..line.count-1
            array_add(*grid.data, line[i] - #char "0");
    }
    array_resize(*grid.seen, grid.width * grid.height);

    print_grid(grid);

    // begin at each non-corner edge location and step inward. If a tree is taller than the tallest
    // seen so far in the line and it hasn't been marked seen in another search, count as visible.
    // Add the four corners as visible, since they aren't iterated by the algorithm.
    visible_count := 4; // 4 corners are never counted by sub-routine

    row := 0;
    for col: 1..grid.width-2 {
        temp := count_visible_in_line(grid, row, col, 1, 0);
        print("checking (%,%: down) %\n", row, col, temp);
        visible_count += temp;
    }

    row = grid.height-1;
    for col: 1..grid.width-2 {
        temp := count_visible_in_line(grid, row, col, -1, 0);
        print("checking (%,%: up) %\n", row, col, temp);
        visible_count += temp;
    }

    col := 0;
    for row: 1..grid.height-2 {
        temp := count_visible_in_line(grid, row, col, 0, 1);
        print("checking (%,%: right) %\n", row, col, temp);
        visible_count += temp;
    }

    col = grid.width-1;
    for row: 1..grid.height-2 {
        temp := count_visible_in_line(grid, row, col, 0, -1);
        print("checking (%,%: left) %\n", row, col, temp);
        visible_count += temp;
    }

    print("part1: %\n", visible_count);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);

    part_1(file_contents);
}
