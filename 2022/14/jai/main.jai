// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Vec2s :: struct { x, y: s64; }
operator== :: inline (a: Vec2s, b: Vec2s) -> bool {
    return a.x == b.x && a.y == b.y;
}

Path :: [..]Vec2s;

Item_Type :: enum u8 {
    Air  :: 0;
    Rock :: 1;
    Sand :: 2;
}

Grid :: struct {
    data: [..]Item_Type;
    start: Vec2s;
    sand_source: Vec2s;
    width, height: s64;
}

parse_paths :: (contents: File_Contents) -> [..]Path {
    paths: [..]Path;
    for line: contents {
        path: Path;

        tokens := split(line, " -> ");
        for tokens {
            _, left, right := split_from_left(it, ",");

            node: Vec2s;
            node.x = to_integer(left);
            node.y = to_integer(right);

            array_add(*path, node);
        }
        array_add(*paths, path);
    }

    return paths;
}

get_index_offset :: inline (grid: Grid, x: s64, y: s64) -> (valid: bool #must, index: s64) {
    if x >= grid.start.x && x < grid.start.x + grid.width
        && y >= grid.start.y && y < grid.start.y + grid.height {
        return true, grid.width * (y - grid.start.y) + (x - grid.start.x);
    }
    return false, -1;
}

print_grid :: (grid: Grid) {
    print("GRID: %x% from %\n", grid.width, grid.height, grid.start);

    for row: grid.start.y .. grid.start.y + grid.height - 1 {
        print("%|", formatInt(grid.start.y + row, minimum_digits=3));
        for col: grid.start.x .. grid.start.x + grid.width - 1 {
            print(" ");
            if Vec2s.{col, row} == grid.sand_source {
                print("+");
            } else {
                valid, index := get_index_offset(grid, col, row);
                assert(valid);
                item := grid.data[index];
                if item == {
                    case .Air;  print(".");
                    case .Rock; print("#");
                    case .Sand; print("o");
                }
            }
            print("  ");
        }
        print("\n");
    }
    print("    ");
    for _: 0..grid.width-1
        print("--- ");
    print("\n    ");
    for i: 0..grid.width-1 {
        print("% ", formatInt(grid.start.x + i));
    }
    print("\n");
}

generate_rocks_for_path :: (grid: *Grid, path: Path) {
    for i: 1..path.count-1 {
        first := path[i-1];
        last  := path[i];

        // ensure first comes before last
        temp := first;
        first.x = min(temp.x, last.x);
        first.y = min(temp.y, last.y);
        last.x  = max(temp.x, last.x);
        last.y  = max(temp.y, last.y);

        for row: first.y..last.y {
            for col: first.x..last.x {
                valid, index := get_index_offset(grid, col, row);
                assert(valid);
                grid.data[index] = .Rock;
            }
        }
    }
}

generate_grid :: (paths: [..]Path, with_floor: bool = false) -> Grid {
    min_coord, max_coord: Vec2s;
    min_coord.x = 9999;
    min_coord.y = 9999;
    max_coord.x = -9999;
    max_coord.y = -9999;
    for path: paths {
        for node: path {
            min_coord.x = min(min_coord.x, node.x);
            min_coord.y = min(min_coord.y, node.y);
            max_coord.x = max(max_coord.x, node.x);
            max_coord.y = max(max_coord.y, node.y);
        }
    }

    sand_source := Vec2s.{500, 0};
    min_coord.x = min(min_coord.x, sand_source.x);
    min_coord.y = min(min_coord.y, sand_source.y);
    max_coord.x = max(max_coord.x, sand_source.x);
    max_coord.y = max(max_coord.y, sand_source.y);

    if with_floor {
        // make the floor twice as wide as the initial grid
        floor_half_width := (max_coord.x - min_coord.x + 1) * 4;
        min_coord.x -= floor_half_width;
        max_coord.x += floor_half_width;
        max_coord.y += 2;
    }

    grid: Grid;
    grid.sand_source = sand_source;
    grid.start = min_coord;
    grid.width = max_coord.x - min_coord.x + 1;
    grid.height = max_coord.y - min_coord.y + 1;
    array_resize(*grid.data, grid.width * grid.height);

    for path: paths
        generate_rocks_for_path(*grid, path);

    if with_floor {
        floor: Path;
        array_add(*floor, Vec2s.{min_coord.x, max_coord.y});
        array_add(*floor, Vec2s.{max_coord.x, max_coord.y});
        generate_rocks_for_path(*grid, floor);
    }

    return grid;
}

simulate_one_sand :: (grid: Grid) -> (at_rest: bool, rest_at: Vec2s) {
    sand: Vec2s;
    sand.x = grid.sand_source.x;
    sand.y = grid.sand_source.y;

    falling := true;
    while falling {
        falling = false;
        for delta: Vec2s.[ .{0, 1}, .{-1, 1}, .{1, 1} ] {
            next: Vec2s;
            next.x = sand.x + delta.x;
            next.y = sand.y + delta.y;

            valid, next_index := get_index_offset(grid, next.x, next.y);
            if !valid  return false, .{}; // fell into the abyss

            if grid.data[next_index] != .Air  continue;

            sand = next;
            falling = true;
            break;
        }
    }

    valid, rest_index := get_index_offset(grid, sand.x, sand.y);
    assert(valid);
    grid.data[rest_index] = .Sand;

    return true, sand;
}

part_1 :: (paths: [..]Path) {
    grid := generate_grid(paths, with_floor = false);

    total_sand := 0;
    iteration := 0;
    while true {
        iteration += 1;
        // print("\nITERATION %\n", iteration);
        // print("==============\n");

        keep_going := simulate_one_sand(grid);
        total_sand += cast(s64)keep_going;

        // print_grid(grid);
        // sleep_milliseconds(20);

        if !keep_going  break;
    }

    print_grid(grid);
    print("part_1: %\n", total_sand);
}

part_2 :: (paths: [..]Path) {
    grid := generate_grid(paths, with_floor = true);

    total_sand := 0;
    iteration := 0;
    while true {
        iteration += 1;
        // print("\nITERATION %\n", iteration);
        // print("==============\n");

        keep_going, rest_at := simulate_one_sand(grid);
        total_sand += cast(s64)keep_going;

        // print_grid(grid);
        // sleep_milliseconds(20);

        // reaching the abyss in part2 means our floor isn't wide enough...
        if !keep_going print_grid(grid);
        assert(keep_going);

        if rest_at == grid.sand_source  break;
    }

    print_grid(grid);
    print("part_2: %\n", total_sand);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    paths := parse_paths(file_contents);

    part_1(paths);
    part_2(paths);
}
