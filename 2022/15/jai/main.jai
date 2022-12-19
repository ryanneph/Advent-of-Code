// Compile with "jai -import_dir '<AoC-repo-dir>/jai-common' main.jai"

#import "Basic";
#import "Math";
#import "String";

// from ../../../jai-common
#import "file";
#import "string";

Vec2s :: struct { x, y: s64; }
operator== :: inline (a: Vec2s, b: Vec2s) -> bool {
    return a.x == b.x && a.y == b.y;
}

Sensor :: struct {
    position: Vec2s;
    nearest_becon: Vec2s;
    distance_to_beacon: s64; // @Cached
    diff_to_beacon: Vec2s;   // @Cached
}

distance :: (a: Vec2s, b: Vec2s) -> s64 {
    return abs(a.x - b.x) + abs(a.y - b.y);
}

parse_integer :: inline (s: string, after: string, strip: string) -> s64 {
    found, _, value := split_from_left(trim_right(s, strip), after);
    assert(found);
    return to_integer(value);
}

parse_sensors :: (contents: File_Contents) -> [..]Sensor {
    sensors: [..]Sensor;
    for line: contents {
        tokens := split(line, " ");

        sensor: Sensor;
        sensor.position.x         = parse_integer(tokens[2], after="x=", strip=",");
        sensor.position.y         = parse_integer(tokens[3], after="y=", strip=":");
        sensor.nearest_becon.x    = parse_integer(tokens[8], after="x=", strip=",");
        sensor.nearest_becon.y    = parse_integer(tokens[9], after="y=", strip=":");
        sensor.distance_to_beacon = distance(sensor.nearest_becon, sensor.position);
        sensor.diff_to_beacon.x   = sensor.nearest_becon.x - sensor.position.x;
        sensor.diff_to_beacon.y   = sensor.nearest_becon.y - sensor.position.y;

        array_add(*sensors, sensor);
    }
    return sensors;
}

part_1 :: (sensors: [..]Sensor) {
    no_beacon_count := 0;

    // determine bounds of observed space
    min_coord, max_coord: Vec2s;
    min_coord.x = S64_MAX;
    min_coord.y = S64_MAX;
    max_coord.x = -S64_MAX;
    max_coord.y = -S64_MAX;
    for sensor: sensors {
        min_coord.x = min(min_coord.x, sensor.position.x - abs(sensor.diff_to_beacon.x));
        min_coord.y = min(min_coord.y, sensor.position.y - abs(sensor.diff_to_beacon.y));
        max_coord.x = max(max_coord.x, sensor.position.x + abs(sensor.diff_to_beacon.x));
        max_coord.y = max(max_coord.y, sensor.position.y + abs(sensor.diff_to_beacon.y));
    }

    for col: min_coord.x .. max_coord.x {
        can_contain_beacon := true;
        contains_beacon := false;
        for sensor: sensors {
            position := Vec2s.{col, 2000000};

            if sensor.nearest_becon == position {
                contains_beacon = true;
            } else if distance(position, sensor.position) <= sensor.distance_to_beacon {
                can_contain_beacon = false;
            }
        }

        if !contains_beacon && !can_contain_beacon
            no_beacon_count += 1;
    }

    print("part_1: %\n", no_beacon_count);
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    sensors := parse_sensors(file_contents);

    part_1(sensors);
}
