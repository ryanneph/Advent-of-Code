// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

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

Sequence :: struct {
    time_remaining: s64;
    current: *Valve;

    done: bool;
}

SequenceSet :: struct($N: s64) {
    score: s64;
    closed: [..]*Valve;

    seqs: [N]Sequence;
}

part_1 :: (graph: Graph, shortest: Square_Matrix) {
    set: SequenceSet(1);
    seq := *set.seqs[0];
    seq.time_remaining = 30;
    seq.current = graph.first;

    for *valve: graph.valves {
        if valve.flow_rate
            array_add(*set.closed, valve);
    }

    sets: [..]SequenceSet(1);
    array_add(*sets, set);

    best_set: SequenceSet(1);
    while sets {
        set := pop(*sets);
        seq := *set.seqs[0];

        if set.score > best_set.score
            best_set = set;

        for next_valve: set.closed {
            distance := shortest.data[next_valve.index * shortest.size + seq.current.index];

            // insufficient time to get there and open next
            if distance + 1 >= seq.time_remaining
                continue;

            benefit := next_valve.flow_rate * (seq.time_remaining - distance - 1);

            next_set: SequenceSet(1);
            next_set.score = set.score + benefit;

            for set.closed {
                if it != next_valve  array_add(*next_set.closed, it);
            }

            next_seq := *next_set.seqs[0];
            next_seq.time_remaining = seq.time_remaining - distance - 1;
            next_seq.current = next_valve;

            array_add(*sets, next_set);
        }
    }

    print("part_1: %\n", best_set.score);
}

part_2 :: (graph: Graph, shortest: Square_Matrix) {
    // for each "closed", iterate permutations of each combination, keeping only the most optimal
    //   for each "optimal" combination, iterate participants, counting number of valid moves for each
    // If any participant has valid_count == 0, it cannot continue, and should be excluded from further moves
    // Otherwise, no partial moves are allowed.


    set: SequenceSet(2);
    for *seq: set.seqs {
        seq.time_remaining = 26;
        seq.current = graph.first;
    }
    for *valve: graph.valves {
        if valve.flow_rate
            array_add(*set.closed, valve);
    }

    sets: [..]SequenceSet(2);
    array_add(*sets, set);

    best_set: SequenceSet(2);
    while sets {
        set := pop(*sets);

        if set.score > best_set.score
            best_set = set;

        Permutation :: [2]s64;
        make_permutation :: (x: s64, y: s64) -> Permutation {
            perm: Permutation;
            perm[0] = x;
            perm[1] = y;
            return perm;
        }

        Move_Result :: struct {
            distance:       s64;
            score:          s64;
            time_remaining: s64;
        };

        get_move_result :: (seq: Sequence, next_valve: *Valve, shortest: Square_Matrix) -> (valid: bool #must, result: Move_Result) {
            using result: Move_Result;

            distance = shortest.data[next_valve.index * shortest.size + seq.current.index];
            if distance + 1 >= seq.time_remaining
                return false, .{};

            score += next_valve.flow_rate * (seq.time_remaining - distance - 1);
            time_remaining = seq.time_remaining - distance - 1;

            return true, result;
        };

        // if a sequence is "done", all other sequences may continue making moves alone
        next_set: SequenceSet(2);
        for seq: set.seqs {
            next_seq := *next_set.seqs[it_index];
            <<next_seq = seq;
            next_seq.done = true;

            for next_valve: set.closed {
                valid, _ := get_move_result(seq, next_valve, shortest);
                if valid {
                    next_seq.done = false;
                    break;
                }
            }
        }

        for next_seq: next_set.seqs {
            if next_seq.done  continue;
            print("%: %, (is_done: %)\n", next_seq, to_string(next_seq.current), next_seq.done);
        }

        #if 0 {
        // a new set for each unique pair of closed valves
        for k: 0 .. set.closed.count-1 {
            for j: k+1 .. set.closed.count-1 {
                assert(k != j);

                next_set_1: SequenceSet(2);
                next_set_1.seqs[0].current = set.closed[k];
                next_set_1.seqs[1].current = set.closed[j];

                for *next_seq: next_set_1.seqs {
                    seq := set.seqs[it_index];
                    next_valve := next_seq.current;

                    distance := shortest.data[next_valve.index * shortest.size + seq.current.index];
                    if distance + 1 >= seq.time_remaining {
                        next_seq.current = seq.current;
                        continue;
                    }

                    next_set_1.score += next_valve.flow_rate * (seq.time_remaining - distance - 1);
                    next_seq.time_remaining = seq.time_remaining - distance - 1;
                }

                next_set_2: SequenceSet(2);
                next_set_2.seqs[0].current = set.closed[j];
                next_set_2.seqs[1].current = set.closed[k];

                for *next_seq: next_set_2.seqs {
                    seq := set.seqs[it_index];
                    next_valve := next_seq.current;

                    distance := shortest.data[next_valve.index * shortest.size + seq.current.index];
                    if distance + 1 >= seq.time_remaining {
                        next_seq.current = seq.current;
                        continue;
                    }

                    next_set_2.score += next_valve.flow_rate * (seq.time_remaining - distance - 1);
                    next_seq.time_remaining = seq.time_remaining - distance - 1;
                }

                next_set: SequenceSet(2);
                if !next_set_1.score && !next_set_2.score  continue;

                next_set = ifx next_set_1.score > next_set_2.score then next_set_1 else next_set_2;
                next_set.score += set.score;

                for set.closed {
                    if it != next_set.seqs[0].current && it != next_set.seqs[1].current {
                        array_add(*next_set.closed, it);
                    }
                }

                array_add(*sets, next_set);
            }
        }
        } // #if
    }

    print("part_2: %\n", best_set.score);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    graph := parse_valves(file_contents);
    shortest := get_shortest_matrix(graph);
    // print_shortest_matrix(shortest, graph);

    part_1(graph, shortest);
    part_2(graph, shortest);
}
