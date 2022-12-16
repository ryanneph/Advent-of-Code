// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Hash";
#import "Hash_Table";

// from ../../../jai-common
#import "file";
#import "string";


Vec2s :: struct { x, y: s64; }
operator == :: (a: Vec2s, b: Vec2s) -> bool {
    return a.x == b.x && a.y == b.y;
}
get_hash :: (v: Vec2s) -> u32 {
    arr: [2]s64;
    arr[0] = v.x;
    arr[1] = v.y;
    return get_hash(arr);
}

Map :: struct {
    depth: [..]s64;
    width, height: s64;

    begin, end: Vec2s;
}

print_map :: (map: *Map) {
    for r: 0..map.height-1 {
        for c: 0..map.width-1 {
            if r == map.begin.y && c == map.begin.x
                print("S");
            else if r == map.end.y && c == map.end.x
                print("E");
            else
                print_character(cast(u8)map.depth[r * map.width + c] + #char "a");
        }
        print("\n");
    }
}

parse_map :: (contents: File_Contents) -> Map {
    map: Map;
    for line: contents {
        if it_index == 0
            map.width = line.count;
        map.height += 1;
    }

    array_resize(*map.depth, map.width * map.height);

    index := 0;
    row := 0;
    for line: contents {
        defer row += 1;
        for col: 0..line.count-1 {
            defer index +=1;

            char := line[col];
            if char == #char "S" {
                map.depth[index] = 0;
                map.begin.x = col;
                map.begin.y = row;
            } else if char == #char "E" {
                map.depth[index] = 25;
                map.end.x = col;
                map.end.y = row;
            } else {
                assert(char >= #char "a" && char <= #char "z");
                map.depth[index] = char - #char "a";
            }
        }
    }

    return map;
}

// Path :: struct {
//     min_length: s64;
//     location: Vec2s;
//     visited: bool;
// }

get_index :: inline (map: *Map, x: s64, y: s64) -> s64 {
    index := y * map.width + x;
    return index;
}

get_depth :: inline (map: *Map, x: s64, y: s64) -> (valid: bool #must, depth: s64, index: s64) {
    index := get_index(map, x, y);
    if x >= 0 && x < map.width && y >= 0 && y < map.height {
        depth := map.depth[index];
        return (true, depth, index);
    }
    return (false, -1, -1);
}

Location :: struct {
    position: Vec2s;
    distance: s64;
}

INFINITE_DISTANCE :: 9999;

valid_neighbors :: (map: *Map, current: Location) -> [..]Location {
    valid_neighbors: [..]Location;

    Delta :: struct { x, y: s64; };
    _, depth, index := get_depth(map, current.position.x, current.position.y);
    for delta: Delta.[ .{-1, 0}, .{1, 0}, .{0, -1}, .{0, 1} ] {
        next_valid, next_depth, _ :=
            get_depth(map, current.position.x + delta.x, current.position.y + delta.y);
        if next_valid && next_depth - depth <= 1 {
            loc: Location;
            loc.distance = current.distance + 1;
            loc.position.x = current.position.x + delta.x;
            loc.position.y = current.position.y + delta.y;

            array_add(*valid_neighbors, loc);
        }
    }

    return valid_neighbors;
}

pop_min_length :: (locations: *[..]Location) -> Location {
    min_index := -1;
    min_location: Location;
    min_location.distance = INFINITE_DISTANCE;
    for <<locations {
        if it.distance < min_location.distance {
            min_location = it;
            min_index = it_index;
        }
    }

    assert(min_index >= 0);
    array_unordered_remove_by_index(locations, min_index);
    return min_location;
}

part_1 :: (map: *Map) {
    start_location: Location;
    start_location.position = map.begin;
    start_location.distance = 0;

    visited_locations: [..]Location;
    array_add(*visited_locations, start_location);

    candidates: [..]Location;
    neighbors := valid_neighbors(map, start_location);
    for neighbors {
        array_add(*visited_locations, it);
        array_add(*candidates, it);
    }
    array_free(neighbors);

    while candidates {
        current := pop_min_length(*candidates);

        if current.position == map.end {
            print("part_1: %\n", current.distance);
            break;
        }

        // min distance update in here
        neighbors := valid_neighbors(map, current);
        for neighbor: neighbors {
            already_visited := false;
            for *visited: visited_locations {
                if visited.position == neighbor.position {
                    if neighbor.distance < visited.distance {
                        (<<visited).distance = neighbor.distance;
                    }
                    already_visited = true;
                    break;
                }
            }

            if !already_visited {
                array_add(*visited_locations, neighbor);
                array_add(*candidates, neighbor);
            }
        }
        array_free(neighbors);
    }
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    map := parse_map(file_contents);

    part_1(*map);
}
