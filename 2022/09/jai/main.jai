// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";
#import "Hash_Table";
#import "Hash";

// from ../../../jai-common
#import "file";
#import "string";

Direction :: enum { Up; Down; Left; Right; }
Move :: struct {
    dir: Direction;
    count: s64;
}

Vector2s :: struct { x, y: s64; }
operator == :: (a: Vector2s, b: Vector2s) -> bool {
    return a.x == b.x && a.y == b.y;
}
get_hash :: (v: Vector2s) -> u32 {
    arr: [2]s64;
    arr[0] = v.x;
    arr[1] = v.y;
    return get_hash(arr);
}


parse_moves :: (contents: File_Contents) -> [..]Move {
    moves: [..]Move;

    for line: contents {
        _, direction, count_string := split_from_left(line, " ");

        move: Move;
        move.count = to_integer(count_string);
        if direction == {
            case "U"; move.dir = .Up;
            case "D"; move.dir = .Down;
            case "L"; move.dir = .Left;
            case "R"; move.dir = .Right;
            case; assert(false);
        }

        array_add(*moves, move);
    }

    return moves;
}

abs :: inline (val: s64) -> s64 {
    return ifx val >= 0 then val else -val;
}
sign :: inline (val: s64) -> s64 {
    if      val > 0  return 1;
    else if val == 0 return 0;
    else             return -1;
}

simulate_head :: (head: *Vector2s, move: Move) {
    if move.dir == {
        case .Right;
            head.x += 1;
        case .Left;
            head.x -= 1;
        case .Up;
            head.y += 1;
        case .Down;
            head.y -= 1;
    }
}

simulate_tail :: (head: Vector2s, tail: *Vector2s) {
    diff, adiff: Vector2s;
    diff.x = head.x - tail.x;
    diff.y = head.y - tail.y;

    adiff.x = abs(diff.x);
    adiff.y = abs(diff.y);

    if (adiff.x + adiff.y <= 1) || (adiff.x == 1 && adiff.y == 1)
        return;

    tail.x += sign(diff.x);
    tail.y += sign(diff.y);
}

part_1 :: (moves: []Move) {
    head, tail: Vector2s;
    visited: Table(Vector2s, bool, given_hash_function = get_hash, given_compare_function = (a, b) => a==b);

    for moves {
        move := it;
        print("Move: %\n", move);
        while move.count > 0 {
            simulate_head(*head, move);
            simulate_tail(head, *tail);
            move.count -= 1;

            table_set(*visited, tail, true);

            print("  HEAD at %\n", head);
            print("  TAIL at %\n", tail);
        }
    }

    print("part1: %\n", visited.count);
}

part_2 :: (moves: []Move) {
    knots: [10]Vector2s;
    head := *knots[0];
    visited: Table(Vector2s, bool, given_hash_function = get_hash, given_compare_function = (a, b) => a==b);

    for moves {
        move := it;
        print("Move: %\n", move);
        while move.count > 0 {
            simulate_head(head, move);
            print("  HEAD at %\n", <<head);
            for i: 1..knots.count-1 {
                simulate_tail(knots[i-1], *knots[i]);
                print("  KNOT[%] at %\n", i, knots[i]);
            }
            table_set(*visited, knots[9], true);

            move.count -= 1;
        }
    }

    print("part2: %\n", visited.count);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    moves := parse_moves(file_contents);

    part_1(moves);
    part_2(moves);
}
