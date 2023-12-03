#import "Basic";
#import "String";

#import,file "../../../jai-common/string.jai";
#import,file "../../../jai-common/file.jai";

DEBUG_PRINT :: false;
debug :: inline (fmt: string, args: .. Any) {
    #if DEBUG_PRINT  print(fmt, ..args);
}
debug_character :: inline (char: u8) {
    #if DEBUG_PRINT  print_character(char);
}

// returns string with requested prefix removed, validating that prefix was found
strip_left :: inline (full: string, to_remove: string) -> string {
    if !starts_with(full, to_remove)  return "";
    return slice(full, to_remove.count, full.count - to_remove.count);
}

// for_expansion for tokenizing around a char-delimiter
make_tokenizer :: (s: *string, body: Code, flags: For_Flags, $delimiters: string) #expand {
    #assert(!(flags & .REVERSE));
    if s.count == 0  return;

    i := 0;
    while tokenizing := true {
        token, success := parse_token(s, delimiters=delimiters, spaces="");
        if !success  break;

        // don't emit delimiters
        #assert(delimiters.count >= 1);
        #if delimiters.count == 1 {
            if token[0] == delimiters[0]  continue tokenizing;
        } else {
            for :chars c: delimiters {
                if token[0] == c  continue tokenizing;
            }
        }

        token = trim(token); // leading/trailing whitespace
        `it_index := i;
        `it := token;

        #insert body;
        i += 1;
    }
}
semicolons :: #bake_arguments make_tokenizer(delimiters=";");
commas     :: #bake_arguments make_tokenizer(delimiters=",");

Color :: enum {
    INVALID :: -1;

    RED   :: 0;
    GREEN :: 1;
    BLUE  :: 2;

    MAX_INDEX;
}

Game :: struct {
    id: s64;
    max_counts: [Color.MAX_INDEX]s64;
}

Results :: struct {
    games: [..]Game;
};

get_color :: (name: string) -> Color {
    if name == {
        case "red";   return .RED;
        case "green"; return .GREEN;
        case "blue";  return .BLUE;
        case;
            print("Unknown color name '%'", name);
            return .INVALID;
    }
}

update_max_cube_count :: (game: *Game, count: s64, color: Color) {
    index := cast(s64)color;
    if index >= game.max_counts.count {
        print("Error: tried to add % to color at index %, but index must be < %",
            count, index, game.max_counts.count);
        return;
    }
    game.max_counts[index] = max(game.max_counts[index], count);
}

parse :: (file_contents: File_Contents) -> Results {
    results: Results;

    for line, lineno: file_contents {
        return_error :: ($msg: string) #expand {
            print("Error parsing line #%: %\n", lineno, msg);
            `return .{};
        }

        success: bool;
        remaining := line;
        debug("%: %\n", lineno, line);

        game: Game;

        // game id
        remaining = strip_left(remaining, "Game ");
        game.id, success, remaining = to_integer(remaining);
        if !success  return_error("failed to parse game id");
        debug("  id: %\n", game.id);

        remaining = strip_left(remaining, ": ");
        if !remaining.count  return_error("expected remainder to begin with ': '");

        // cube colors and counts
        for :semicolons set: remaining {
             debug("  Set %: '%'\n", it_index, set);
             for :commas cube_desc: set {
                 count:, success, rest: = to_integer(cube_desc);
                 if !success  return_error("failed to parse cube count");

                 color := get_color(strip_left(rest, " "));
                 if color == .INVALID  return_error("failed to parse color");

                 update_max_cube_count(*game, count, color);
                 debug("    count: % of %\n", count, color);
             }
        }

        array_add(*results.games, game);
    }

    return results;
}

part_1 :: (results: *Results) {
    possible_count := 0;
    id_sum := 0;
    for game: results.games {
        if game.max_counts[cast(s64)Color.RED] <= 12 &&
            game.max_counts[cast(s64)Color.GREEN] <= 13 &&
            game.max_counts[cast(s64)Color.BLUE] <= 14 {
            possible_count += 1;
            id_sum += game.id;
        }
    }
    print("Part1: %\n", id_sum);
}

main :: () {
    filename := "../input.txt";

    file_contents := file_read_all(filename);
    results := parse(file_contents);
    if results.games.count <= 0 {
        print("Error parsing contents of file '%'\n", filename);
        exit(1);
    }

    part_1(*results);
}
