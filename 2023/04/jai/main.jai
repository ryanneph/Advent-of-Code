#import "Basic";
#import "String";
#import "Hash_Table";

#import,file "../../../jai-common/string.jai";
#import,file "../../../jai-common/file.jai";

DEBUG_PRINT :: false;
debug :: inline (fmt: string, args: .. Any) {
    #if DEBUG_PRINT  print(fmt, ..args);
}
debug_character :: inline (char: u8) {
    #if DEBUG_PRINT  print_character(char);
}

Card :: struct {
    match_count: s64;
    copy_count: s64;
}
Pile :: struct {
    cards: [..]Card;
}

parse :: (file_contents: File_Contents) -> Pile {
    map :: (array: []$T, op: (T) -> (value: $S, keep: bool)) -> [..]S {
        out: [..]S;
        array_reserve(*out, array.count);
        for array {
            value, keep := op(it);
            if keep  array_add(*out, value);
        }
        return out;
    }
    string_to_s64 :: (s: string) -> (value: s64, keep: bool) {
        if !s.count  return 0, false;
        value, success := to_integer(s);
        if !success  print("Failed to convert '%' to integer\n", s);
        return value, true;
    }

    pile: Pile;
    winners_table: Table(s64, s8);
    for line: file_contents {
        debug("%\n", line);

        found, left, right := split_from_left(line, #char ":");
        if !found {
            print("Failed to parse line % '%'", it_index, line);
            return .{};
        }

        found, left, right = split_from_left(right, #char "|");
        if !found {
            print("Failed to parse line % '%'", it_index, line);
            return .{};
        }

        winners := map(split(trim(left),  separator=" "), string_to_s64);
        numbers := map(split(trim(right), separator=" "), string_to_s64);

        // find match count
        match_count := 0;
        table_reset(*winners_table);
        for winners  table_add(*winners_table, it, 0);
        for numbers {
            if table_contains(*winners_table, it) {
                match_count += 1;
            }
        }
        debug("  winners: %\n", winners);
        debug("  numbers: %\n", numbers);

        card := Card.{
            match_count = match_count,
            copy_count = 1,
        };
        array_add(*pile.cards, card);
    }
    deinit(*winners_table);

    return pile;
}

part1 :: (pile: Pile) {
    points := 0;
    for card: pile.cards {
        if card.match_count  points += 1 << (card.match_count - 1);
    }

    print("Part1: %\n", points);
}

part2 :: (pile: Pile) {
    card_count := 0;
    for card, index: pile.cards {
        card_count += card.copy_count;
        debug("card %: matches=%, copies=%\n", index, card.match_count, card.copy_count);

        for i: index+1..index+card.match_count {
            assert(i < pile.cards.count);
            card2 := *pile.cards[i];
            card2.copy_count += card.copy_count;
        }
    }

    print("Part2: %\n", card_count);
}

main :: () {
    filename := "../input.txt";
    // filename = "../test1.txt";

    file_contents, success := file_read_all(filename);
    if !success {
        print("Failed to read file '%s'", filename);
        exit(1);
    }

    pile := parse(file_contents);
    part1(pile);
    part2(pile);
}
