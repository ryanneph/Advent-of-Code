// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";
#import "vector";

DEBUG_PRINT :: false;
debug :: inline (fmt: string, args: .. Any) {
    #if DEBUG_PRINT  print(fmt, ..args);
}
debug_character :: inline (char: u8) {
    #if DEBUG_PRINT  print_character(char);
}

Ring :: struct($T: Type) {
    data:  *T;
    count: s64;
    head:  s64;
}
Char_Ring :: Ring(u8);
Rock_Ring :: Ring(Rock);

get_next_pointer :: (using ring: *Ring($T)) -> *T {
    assert(head < count);
    next := *data[head];
    head = ifx head < count-1 then head + 1 else 0;
    return next;
}
get_next :: inline (ring: *Ring($T)) -> T {
    return <<get_next_pointer(ring);
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

    // falling rock properties
    falling: Landed_Rock;
}

does_collide_with_rock :: (chamber: Chamber, new_position: Vec2s) -> bool {
    using,only(falling) chamber;

    if new_position.y < 1
        return true;

    rock := falling.rock;
    for <landed_rock: chamber.landed {
        for <y: landed_rock.position.y + landed_rock.rock.height - 1 .. landed_rock.position.y {
            for x: min(landed_rock.position.x, new_position.x)
                .. max(landed_rock.position.x + landed_rock.rock.width, new_position.x + falling.rock.width)
            {
                debug("  (collision) testing (%, %): ", x, y);
                defer debug("\n");

                if x < landed_rock.position.x || y < landed_rock.position.y
                    || x >= landed_rock.position.x + landed_rock.rock.width || y >= landed_rock.position.y + landed_rock.rock.height
                {
                    debug("not in landed rock data");
                    continue;
                }

                if x < new_position.x || y < new_position.y
                    || x >= new_position.x + rock.width || y >= new_position.y + rock.height
                {
                    debug("not in falling rock data");
                    continue;
                }

                landed_cell  := landed_rock.rock.data[y - landed_rock.position.y][x - landed_rock.position.x];
                falling_cell :=             rock.data[y -         new_position.y][x -         new_position.x];
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

shift_sideways :: (chamber: *Chamber, jet: u8) {
    assert(jet == #char "<" || jet == #char ">");
    shift := ifx (jet == #char "<") then -1 else 1;

    new_position: Vec2s;
    new_position.x = chamber.falling.position.x + shift;
    new_position.y = chamber.falling.position.y;


    debug("  ");
    debug_character(jet);

    if new_position.x >= 0 && new_position.x + chamber.falling.rock.width - 1 < chamber.width
        && !does_collide_with_rock(chamber, new_position) {
        chamber.falling.position = new_position;


        debug(": shifted to %\n", new_position);
    } else {
        debug(": no shift (hit wall)\n");
    }
}

fall_one_unit :: (chamber: *Chamber) -> (landed: bool) {
    new_position: Vec2s;
    new_position.x = chamber.falling.position.x;
    new_position.y = chamber.falling.position.y - 1;


    collides := does_collide_with_rock(chamber, new_position);


    debug("  f: ");
    if !collides {
        chamber.falling.position = new_position;

        debug("fell to %\n", new_position);
    } else {
        debug("no fall (collided with rock or floor)\n");
    }

    return collides;
}

part_1 :: (contents: string) {
    jet_ring: Char_Ring;
    jet_ring.data  = contents.data;
    jet_ring.count = contents.count;

    rocks := make_rocks();
    rock_ring: Rock_Ring;
    rock_ring.data  = rocks.data;
    rock_ring.count = rocks.count;

    chamber: Chamber;
    while chamber.landed.count < 2022 {
        chamber.falling.rock     = get_next_pointer(*rock_ring);
        chamber.falling.position = Vec2s.{ 2, chamber.height + 4 };
        print("\nDropping Rock from %:\n", chamber.falling.position);
        debug("%\n", to_string(chamber.falling.rock));

        while true {
            shift_sideways(*chamber, get_next(*jet_ring));

            landed := fall_one_unit(*chamber);
            assert (chamber.falling.position.y >= 0);
            if landed {
                chamber.height = max(chamber.height, chamber.falling.position.y + chamber.falling.rock.height - 1);
                print("  rock % landed at %, new chamber height is %\n",
                    chamber.landed.count + 1, chamber.falling.position, chamber.height);
                array_add(*chamber.landed, Landed_Rock.{ chamber.falling.rock, chamber.falling.position });
                break;
            }
        }
    }

    print("part_1: %\n", chamber.height);
}

main :: () {
    filename := "../input.txt";
    file_contents := trim_right(file_read_all_as_string(filename), "\n");

    part_1(file_contents);
}
