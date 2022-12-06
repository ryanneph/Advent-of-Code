// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Hash_Table";

// from ../../../jai-common
#import "file";
#import "string";

table_insert_or_increment :: (table: *Table($K, $V), key: K, val: V) -> s8 {
    entry := table_find_pointer(table, key);
    if entry {
        (<<entry) += val;
        return (<<entry);
    } else {
        table_add(table, key, val);
        return 1;
    }
}

table_remove_or_decrement :: (table: *Table($K, $V), key: K, val: V) -> s8 {
    entry := table_find_pointer(table, key);
    if ((<<entry) > val) {
        (<<entry -= val);
        return (<<entry);
    } else {
        table_remove(table, key);
        return 0;
    }
}

part_all :: (contents: string) {
    header_table:  Table(u8, s8);
    message_table: Table(u8, s8);
    first_header_index  := -1;
    first_message_index := -1;
    for i: 0..contents.count-1 {
        if (first_header_index < 0) {
            if i >= 4  table_remove_or_decrement(*header_table, contents[i - 4], 1);
            table_insert_or_increment(*header_table, contents[i], 1);
        }

        if (first_message_index < 0) {
            if i >= 14 table_remove_or_decrement(*message_table, contents[i - 14], 1);
            table_insert_or_increment(*message_table, contents[i], 1);
        }

        if first_header_index < 0 && header_table.count == 4 {
            first_header_index = i + 1;
        }

        if first_message_index < 0 && message_table.count == 14 {
            first_message_index = i + 1;
        }

        if first_header_index >= 0 && first_message_index >= 0
            break;
    }

    print("part1: %\n", first_header_index);
    print("part2: %\n", first_message_index);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all_as_string(filename);

    part_all(file_contents);
}
