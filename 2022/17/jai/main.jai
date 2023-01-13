// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";
#import "vector";

#import,file "./ring.jai";

Char_Ring :: Ring(u8);
Rock_Ring :: Ring(Rock);

DEBUG_PRINT :: false;
debug :: inline (fmt: string, args: .. Any) {
    #if DEBUG_PRINT  print(fmt, ..args);
}
debug_character :: inline (char: u8) {
    #if DEBUG_PRINT  print_character(char);
}

Rock :: struct {
    // dimensions may be up to 4x4, but can be less (down to 1x1) to speed-up collision detection
    // The bottom left corner (data[0][0]) is always included.
    data: [4][4]bool;
    height, width: s64;
}

to_string :: (rock: Rock) -> string {
    allocator :: temporary_allocator;

    builder: String_Builder;
    builder.allocator = allocator;

    using rock;
    for < row: cast(s64)(height)-1 .. 0 {
        for col: cast(s64)0..width-1 {
            if data[row][col]  append(*builder, "#");
            else               append(*builder, ".");
        }
        append(*builder, "\n");
    }

    return builder_to_string(*builder, allocator=allocator);
}

make_rocks :: () -> []Rock {
    rocks := NewArray(5, Rock);

    {
        // ####
        using rock := *rocks[0];
        width  = 4;
        height = 1;
        for i: 0..3  data[0][i] = true;
    }
    {
        // .#.
        // ###
        // .#.
        using rock := *rocks[1];
        width  = 3;
        height = 3;
        data[2][1] = true;
        for i: 0..2  data[1][i] = true;
        data[0][1] = true;
    }
    {
        // ..#
        // ..#
        // ###
        using rock := *rocks[2];
        width  = 3;
        height = 3;
        data[2][2] = true;
        data[1][2] = true;
        for i: 0..2  data[0][i] = true;
    }
    {
        // #
        // #
        // #
        // #
        using rock := *rocks[3];
        width  = 1;
        height = 4;
        for i: 0..3  data[i][0] = true;
    }
    {
        // ##
        // ##
        using rock := *rocks[4];
        width  = 2;
        height = 2;
        data[0][0] = true;
        data[1][0] = true;
        data[0][1] = true;
        data[1][1] = true;
    }

    return rocks;
}

Landed_Rock :: struct {
    rock: *Rock;
    position: Vec2s;
}

Chamber :: struct {
    width :: 7;
    height: s64; // of the highest landed rock;

    landed: [..]Landed_Rock;
    highest_composite: *Composite_Rock;
}

does_collide_with_any_rock :: (chamber: Chamber, falling: Landed_Rock, new_position: Vec2s) -> bool {
    // hits floor
    if new_position.y <= 0
        return true;

    // landed rocks are sorted by height of top edge (position.y + rock.height - 1), so we can stop after we find a
    // landed rock with top edge lower than the falling rock's lower edge.
    for <landed: chamber.landed {
        // already tested all possible collisions (the rest are lower)
        if new_position.y > landed.position.y + landed.rock.height - 1 {
            debug("  (collision) early stop at landed rock % of % (rest are too low)\n",
                it_index + 1, chamber.landed.count);
            break;
        }

        bbox_min, bbox_max: Vec2s;
        bbox_min.x = max(new_position.x, landed.position.x);
        bbox_min.y = max(new_position.y, landed.position.y);
        bbox_max.x = min(new_position.x + falling.rock.width  - 1, landed.position.x + landed.rock.width - 1);
        bbox_max.y = min(new_position.y + falling.rock.height - 1, landed.position.y + landed.rock.height - 1);

        // no bounding box collision
        if bbox_min.x > bbox_max.x || bbox_min.y > bbox_max.y {
            debug("  (collision) no bounding box collision between falling and landed %\n", it_index + 1);
            continue;
        }

        debug("  (collision) testing % cells in overlap box (%, %) -> (%, %):\n",
            (bbox_max.x - bbox_min.x + 1) * (bbox_max.y - bbox_min.y + 1),
            bbox_min.x, bbox_min.y, bbox_max.x, bbox_max.y);

        for <y: bbox_max.y .. bbox_min.y {
            for x: bbox_min.x .. bbox_max.x {
                debug("    - testing (%, %): ", x, y);
                defer debug("\n");

                landed_cell  :=  landed.rock.data[y - landed.position.y][x - landed.position.x];
                falling_cell := falling.rock.data[y -    new_position.y][x -    new_position.x];
                debug("[landed=%, falling=%]", landed_cell, falling_cell);

                if landed_cell && falling_cell {
                    debug("...HIT");
                    return true;
                }
            }
        }
    }

    return false;
}

shift_sideways :: (chamber: Chamber, falling: *Landed_Rock, jet: u8) {
    assert(jet == #char "<" || jet == #char ">");
    shift := ifx (jet == #char "<") then -1 else 1;

    new_position: Vec2s;
    new_position.x = falling.position.x + shift;
    new_position.y = falling.position.y;

    debug("  ");
    debug_character(jet);

    if new_position.x >= 0 && new_position.x + falling.rock.width - 1 < chamber.width
        && !does_collide_with_any_rock(chamber, falling, new_position) {
        falling.position = new_position;

        debug(": shifted to %\n", new_position);
    } else {
        debug(": no shift (hit wall)\n");
    }
}

fall_one_unit :: (chamber: Chamber, falling: *Landed_Rock) -> (landed: bool) {
    new_position: Vec2s;
    new_position.x = falling.position.x;
    new_position.y = falling.position.y - 1;

    collides := does_collide_with_any_rock(chamber, falling, new_position);

    debug("  f: ");
    if !collides {
        falling.position = new_position;

        debug("fell to %\n", new_position);
    } else {
        debug("no fall (collided with rock or floor)\n");
    }

    return collides;
}

array_add_sorted :: (array: *[..]$T, item: T, compare_func: (a: T, b: T) -> s64 ) {
    insert_index := array.count;
    for <<array {
        if compare_func(item, it) < 0 {
            insert_index = it_index;
            break;
        }
    }
    array_insert_at(array, item, insert_index);
}

compare_by_upper_edge_height :: (a: Landed_Rock, b: Landed_Rock) -> s64 {
    height_a := a.position.y + a.rock.height - 1;
    height_b := b.position.y + b.rock.height - 1;
    return height_a - height_b;
}

greatest_common_divisor :: (a: s64, b: s64) -> s64 {
    if(b==0)  return a;
    return greatest_common_divisor(b, a % b);
}

least_common_multiple :: inline (a: s64, b: s64) -> s64 {
    return a * b / greatest_common_divisor(a, b);
}

Composite_Rock :: struct {
    landed: [..]Landed_Rock;
    height, width: s64;
    position: Vec2s;
}

make_composite_rock_from_sequence :: (rock_ring_original: Rock_Ring, jet_ring_original: Char_Ring, rock_count: s64)
    -> Composite_Rock
{
    // simulate a set of rocks assuming the jet sequence has just begin and no rocks have landed yet
    // returns a single Rock that encapsulates the state of all landed rocks;

    rock_ring := rock_ring_original;
    rock_ring.head = 0;

    jet_ring := jet_ring_original;
    jet_ring.head = 0;

    chamber: Chamber;
    falling: Landed_Rock;
    while chamber.landed.count < rock_count {
        falling.rock     = get_next_pointer(*rock_ring);
        falling.position = Vec2s.{ 2, chamber.height + 4 };

        debug("\nDropping Rock from %:\n", falling.position);
        debug("%\n", to_string(falling.rock));

        while true {
            shift_sideways(chamber, *falling, get_next(*jet_ring));

            landed := fall_one_unit(chamber, *falling);
            assert(falling.position.y >= 0);
            if landed {
                chamber.height = max(chamber.height, falling.position.y + falling.rock.height - 1);
                debug("  rock % landed at %, new chamber height is %\n",
                    chamber.landed.count + 1, falling.position, chamber.height);
                array_add_sorted(*chamber.landed, Landed_Rock.{ falling.rock, falling.position },
                    compare_by_upper_edge_height);
                break;
            }
        }
    }

    min_x :=  S64_MAX;
    max_x := -S64_MAX;
    for chamber.landed {
        min_x = min(min_x, it.position.x);
        max_x = max(max_x, it.position.x + it.rock.width - 1);
    }

    debug_show_chamber(chamber);

    composite: Composite_Rock;
    composite.landed = chamber.landed;
    composite.height = chamber.height;
    composite.width  = max_x - min_x + 1;
    composite.position = Vec2s.{min_x, 1};

    return composite;
}

debug_show_chamber :: (chamber: Chamber) {
    using,only(width, height) chamber;

    grid := NewArray(chamber.width * chamber.height, u8);
    for *char: grid {
        <<char = #char ".";
    }

    for landed: chamber.landed {
        for y: 0..landed.rock.height-1 {
            for x: 0..landed.rock.width-1 {
                index := width * (landed.position.y-1 + y) + landed.position.x + x;
                if landed.rock.data[y][x] then grid[index] = #char "#";
            }
        }
    }

    col := 0;
    row := height - 1;
    for < char: grid {
        if !col  print("\n%: ", formatInt(row + 1, minimum_digits=2));
        print_character(char);

        if col < width-1 {
            col += 1;
        } else {
            col = 0;
            row -= 1;
        }
    }

    print("\n00: ");
    for 1..width { print_character(#char "-"); }
    print_character(#char "\n");
}


part_all :: (contents: string, rock_count: s64) {
    jet_ring:  Char_Ring = make_ring(cast([]u8)contents);
    rock_ring: Rock_Ring = make_ring(make_rocks());

    period := least_common_multiple(rock_ring.count, jet_ring.count);
    print("Period of % and % is %\n", rock_ring.count, jet_ring.count, period); // XXX
    composite_rock := make_composite_rock_from_sequence(rock_ring, jet_ring, period);

    print("composite after % landed: %x%\n", period, composite_rock.width, composite_rock.height);

    // determine the overlap
    overlap_count := 0;

    landed_count := (rock_count / composite_rock.landed.count) - overlap_count;
    // falling = *composite_rock;
    // TODO drop several composite_rocks into chamber

    chamber: Chamber;
    chamber.height = composite_rock.height;
    chamber.highest_composite = *composite_rock;

    while landed_count < rock_count {
        landed_count += 1;
    }

    print("Height after % landed rocks: %\n", rock_count, chamber.height);
}

// After K rocks have fallen, we enter a repeating pattern where the rock sequence and jet sequence
// match exactly with a previous sequence.
//
// There are 5 types of rock and a variable number (N) of jet shift ops. If (N % 5 == 0), then we
// have a repeating pattern after K iterations (i.e. for every full iteration of the given jet shift
// sequence (K == N).
//
// In this case, we can determine the height of the set (how much it happens to overlap with the
// previously landed rocks), and extrapolate the total height from this information, simulating the
// remaining rocks on top to get to our total landed rock count.
//
// In the general case (where N may not be divisible by 5), K is instead determined by the least
// common multiple (K = lcm(5, N)).

main :: () {
    filename := "../test1.txt";
    file_contents := trim_right(file_read_all_as_string(filename), "\n");

    part_all(file_contents, rock_count=2022);
    // part_all(file_contents, rock_count=1000000000000);
}
