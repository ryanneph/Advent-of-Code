#import "Basic";

Ring :: struct($T: Type) {
    data:  *T;
    count: s64;
    head:  s64;
}

make_ring :: (array: []$T) -> Ring(T) {
    ring: Ring(T);
    ring.data  = array.data;
    ring.count = array.count;

    return ring;
}

get_next_pointer :: (using ring: *Ring($T)) -> *T {
    assert(head < count);
    next := *data[head];
    head = ifx head < count-1 then head + 1 else 0;
    return next;
}

get_next :: inline (ring: *Ring($T)) -> T {
    return <<get_next_pointer(ring);
}
