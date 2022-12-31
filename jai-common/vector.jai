#import "Hash";

Vec2s :: struct {
    x, y: s64;
}

operator == :: (a: Vec2s, b: Vec2s) -> bool {
    return a.x == b.x && a.y == b.y;
}

get_hash :: (v: Vec2s) -> u32 {
    arr: [2]s64;
    arr[0] = v.x;
    arr[1] = v.y;
    return get_hash(arr);
}
