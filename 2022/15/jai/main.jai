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
    nearest_beacon: Vec2s;
    distance_to_beacon: s64; // @Cached
    diff_to_beacon: Vec2s;   // @Cached
}

Bounds :: struct {
    min, max: Vec2s;
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
        sensor.nearest_beacon.x    = parse_integer(tokens[8], after="x=", strip=",");
        sensor.nearest_beacon.y    = parse_integer(tokens[9], after="y=", strip=":");
        sensor.distance_to_beacon = distance(sensor.nearest_beacon, sensor.position);
        sensor.diff_to_beacon.x   = sensor.nearest_beacon.x - sensor.position.x;
        sensor.diff_to_beacon.y   = sensor.nearest_beacon.y - sensor.position.y;

        array_add(*sensors, sensor);
    }
    return sensors;
}

get_search_bounds :: (sensors: [..]Sensor) -> Bounds {
    // determine bounds of observed space
    bounds: Bounds;
    bounds.min.x = S64_MAX;
    bounds.min.y = S64_MAX;
    bounds.max.x = -S64_MAX;
    bounds.max.y = -S64_MAX;
    for sensor: sensors {
        bounds.min.x = min(bounds.min.x, sensor.position.x - abs(sensor.diff_to_beacon.x));
        bounds.min.y = min(bounds.min.y, sensor.position.y - abs(sensor.diff_to_beacon.y));
        bounds.max.x = max(bounds.max.x, sensor.position.x + abs(sensor.diff_to_beacon.x));
        bounds.max.y = max(bounds.max.y, sensor.position.y + abs(sensor.diff_to_beacon.y));
    }

    return bounds;
}


part_1 :: (sensors: [..]Sensor, bounds: Bounds) {
    no_beacon_count := 0;
    for col: bounds.min.x .. bounds.max.x {
        can_contain_beacon := true;
        contains_beacon := false;
        for sensor: sensors {
            position := Vec2s.{col, 2000000};

            if sensor.nearest_beacon == position {
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

part_2 :: (sensors: [..]Sensor, bounds: Bounds) {
    space := bounds;
    space.min.x = max(bounds.min.x, 0);
    space.min.y = max(bounds.min.y, 0);
    space.max.x = min(bounds.max.x, 4000000);
    space.max.y = min(bounds.max.y, 4000000);

    // Scan perimeter of each sensor region from North->East->South->West
    // The one position that may contain a beacon MUST be directly adjacent to at least one
    // sensor's detection region
    for sensor: sensors {
        position: Vec2s;
        position.x = sensor.position.x + sensor.distance_to_beacon + 1;
        position.y = sensor.position.y;

        check_position :: () #expand {
            if position.x < space.min.x || position.y < space.min.y ||
                position.x > space.max.x || position.y > space.max.y
                return;

            contains_beacon := false;
            cannot_contain_beacon := false;
            for sensor: sensors {
                if position == sensor.nearest_beacon {
                    contains_beacon = true;
                    break;
                } else if distance(position, sensor.position) <= sensor.distance_to_beacon {
                    cannot_contain_beacon = true;
                    break;
                }
            }

            if !cannot_contain_beacon && !contains_beacon {
                print("part_2: %  %\n", position, 4000000 * position.x + position.y);
                break sensor; // break loop in macro caller's scope
            }
        }

        while position.x > sensor.position.x {
            check_position();
            position.x -= 1;
            position.y += 1;
        }
        while position.x > sensor.position.x - sensor.distance_to_beacon - 1 {
            check_position();
            position.x -= 1;
            position.y -= 1;
        }
        while position.x < sensor.position.x {
            check_position();
            position.x += 1;
            position.y -= 1;
        }
        while position.x < sensor.position.x + sensor.distance_to_beacon + 1 {
            check_position();
            position.x += 1;
            position.y += 1;
        }
    }
}

main :: () {
    filename := "../input.txt";
    file_contents := file_read_all(filename);
    sensors := parse_sensors(file_contents);
    bounds := get_search_bounds(sensors);

    part_1(sensors, bounds);
    part_2(sensors, bounds);
}
