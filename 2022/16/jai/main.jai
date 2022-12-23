// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

DEBUG :: true;

Valve :: struct {
    name: string;
    index: s64;
    flow_rate: s64;

    connected: [..]*Valve;
}

Graph :: struct {
    valves: []Valve;
    first: *Valve;
}

to_string :: (valve: Valve) -> string {
    builder: String_Builder;
    print_to_builder(*builder, "{index=%, name=%, flow=%, to=[",
        valve.index, valve.name, valve.flow_rate);
    for to: valve.connected {
        if it_index < valve.connected.count-1 {
            print_to_builder(*builder, "%, ", to.name);
        } else {
            print_to_builder(*builder, "%", to.name);
        }
    }
    append(*builder, "]}");
    return builder_to_string(*builder);
}

parse_valves :: (contents: File_Contents) -> Graph {
    valve_count := 0;
    for contents  valve_count += 1;

    graph: Graph;
    graph.valves = NewArray(valve_count, Valve);

    valve_count = 0;
    find_valve_or_get_new :: (name: string) -> *Valve #expand {
        for * graph.valves
            if it.name == name  return it;

        valve := *graph.valves[valve_count];
        valve.name  = name;
        valve.index = valve_count;

        valve_count += 1;
        return valve;
    }

    for line: contents {
        tokens := split(line, " ");

        valve := find_valve_or_get_new(tokens[1]);
        _, __, flow_rate_string := split_from_left(tokens[4], "=");
        valve.flow_rate = to_integer(trim_right(flow_rate_string, ";"));

        for i: 9..tokens.count-1 {
            to_name := trim_right(tokens[i], ",");
            assert(to_name.count == 2);
            to_valve := find_valve_or_get_new(to_name);
            array_add(*valve.connected, to_valve);
        }

        if valve.name == "AA"  graph.first = valve;
    }

    assert(valve_count == graph.valves.count);
    return graph;
}

Square_Matrix :: struct {
    size: s64;
    data: []s64;
}

print_shortest_matrix :: (matrix: Square_Matrix, graph: Graph) {
    dist := matrix.data;
    valve_count := matrix.size;

    for dst: 0..valve_count-1 {
        dst_valve := graph.valves[dst];
        assert(dst_valve.index == dst);

        print("dst % | %:  ", formatInt(dst, minimum_digits=2), dst_valve.name);
        for src: 0..valve_count-1 {
            if src >= dst  continue;
            d := *dist[dst * valve_count + src];
            if (<<d) == S32_MAX  print("#  ");
            else                 print("% ", formatInt(<<d, minimum_digits=2));
        }
        print("\n");
    }

    print("              ");
    for src: 0..valve_count-1 {
        print("-- ");
    }
    print("\n         src: ");
    for src: 0..valve_count-1 {
        print("% ", formatInt(src, minimum_digits=2));
    }
    print("\n              ");
    for src: 0..valve_count-1 {
        src_valve := graph.valves[src];
        assert(src == src_valve.index);
        print("% ", src_valve.name);
    }
    print("\n");
}

get_shortest_matrix :: (graph: Graph) -> Square_Matrix {
    // Floyd-Warshall algorithm

    valve_count := graph.valves.count;
    dist: []s64 = NewArray(valve_count * valve_count, s64);

    for *dist { <<it = S32_MAX; }
    for dst: graph.valves {
        dist[dst.index * valve_count + dst.index] = 0;
        for src: dst.connected {
            dist[dst.index * valve_count + src.index] = 1;
        }
    }

    for sub_index: 0..valve_count-1 {
        min_distance :: (dst: s64, src: s64) #expand {
            sub_a :=  dist[sub_index * valve_count + src      ];
            sub_b :=  dist[dst       * valve_count + sub_index];
            path  := *dist[dst       * valve_count + src      ];
            if (<<path) > sub_a + sub_b {
                (<<path) = sub_a + sub_b;
            }
        }

        for dst: 0..valve_count-1 {
            for src: 0..valve_count-1 {
                min_distance(dst, src);
            }
        }
    }

    matrix: Square_Matrix;
    matrix.size = valve_count;
    matrix.data = dist;

    return matrix;
}

Debug_Data :: struct {
    from_valve, to_valve: *Valve;
    benefit: s64;
    time_remaining_before: s64;
    time_remaining_after: s64;
}

Sequence :: struct {
    time_remaining: s64;
    score: s64;

    closed: [..]*Valve;
    current: *Valve;

    #if DEBUG  debug: [..]Debug_Data;
}

make_next_sequence :: (seq: *Sequence, next_valve: *Valve, time_used: s64, benefit: s64) -> Sequence {
    closed: [..]*Valve;
    for seq.closed {
        if it != next_valve  array_add(*closed, it);
    }

    next: Sequence;
    memcpy(*next, seq, size_of(type_of(next)));

    next.time_remaining = seq.time_remaining - time_used;
    next.score += benefit;
    next.closed = closed;
    next.current = next_valve;

#if DEBUG {
    debug: [..]Debug_Data;
    for seq.debug  array_add(*debug, it);

    debug_data: Debug_Data;
    debug_data.from_valve            = seq.current;
    debug_data.to_valve              = next_valve;
    debug_data.benefit               = benefit;
    debug_data.time_remaining_before = seq.time_remaining;
    debug_data.time_remaining_after  = seq.time_remaining - time_used;
    array_add(*debug, debug_data);

    next.debug = debug;
}

    return next;
}

part_1 :: (graph: Graph, shortest: Square_Matrix) {
    seq: Sequence;
    seq.time_remaining = 30;
    seq.current        = graph.first;

    for *valve: graph.valves {
        if valve.flow_rate
            array_add(*seq.closed, valve);
    }

    sequences: [..]Sequence;
    array_add(*sequences, seq);

    tested_count := 0;
    best_seq: Sequence;
    while sequences {
        seq := pop(*sequences);

        if seq.score > best_seq.score
            best_seq = seq;

        terminated := true;
        for next: seq.closed {
            distance := shortest.data[next.index * shortest.size + seq.current.index];

            // insufficient time to get there and open next
            if distance + 1 > seq.time_remaining
                continue;

            benefit  := next.flow_rate * (seq.time_remaining - distance - 1);
            next_seq := make_next_sequence(*seq, next, distance + 1, benefit);
            array_add(*sequences, next_seq);

            terminated = false;
        }

        if terminated
            tested_count += 1;
    }


#if DEBUG {
    print("\nDEBUG OUTPUT for best sequence:\n");
    print("Tried % sequences\n", tested_count);
    for best_seq.debug {
        print("  %: % -> % (time_before=%, time_after=%, benefit=%)\n",
        it_index, it.from_valve.name, it.to_valve.name, it.time_remaining_before,
        it.time_remaining_after, it.benefit);
    }
}

    print("part_1: %\n", best_seq.score);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    graph := parse_valves(file_contents);
    shortest := get_shortest_matrix(graph);
    // print_shortest_matrix(shortest, graph);

    part_1(graph, shortest);
}
