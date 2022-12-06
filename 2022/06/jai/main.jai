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

part_1 :: (contents: string) {
    print("datastream: %\n", contents);
    header_table: Table(u8, s8);
    for i: 0..contents.count-1 {
        if i >= 4  table_remove_or_decrement(*header_table, contents[i - 4], 1);
        table_insert_or_increment(*header_table, contents[i], 1);

        // DEBUG
        print("TABLE(%; +", i+1);
        print_character(contents[i]);
        if (i >= 4) {
            print(", -");
            print_character(contents[i-4]);
        }
        print("): ");

        for val, key: header_table {
            print_character(key);
            print(":%, ", val);
        }
        print("]\n");

        if header_table.count == 4 {
            print("FOUND IT: %\n", i + 1);
            break;
        }
        // if (i >= 4) {
        //     unique := true;
        //     for val, key: header_table {
        //         if val > 1 {
        //             unique = false;
        //             break;
        //         }
        //     }
        //     if (unique) {
        //         print("FOUND IT: %\n", i + 1);
        //         break;
        //     }
        // }
    }
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all_as_string(filename);

    part_1(file_contents);
}
