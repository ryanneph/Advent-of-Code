use std::fs;
use std::cmp::{min, max};

fn decode_hex_to_bytes(hex_string: &str) -> Vec<u8> {
    assert!(hex_string.len() % 2 == 0);
    let mut bytes = Vec::<u8>::new();

    for i in (0..hex_string.len()).step_by(2) {
        let hex = &hex_string[i..i+2];
        let byte = u8::from_str_radix(hex, 16).unwrap();
        // println!("{}: {} :: {:3} :: {:08b}", i / 2, hex, byte, byte);
        bytes.push(byte);
    }

    return bytes;
}

#[derive(Default)]
struct ScanState {
    index: usize,
    bit_offset: u8,
}

#[inline(always)]
fn mask_lsb(count: u8) -> u8 {
    assert!(count > 0 && count <= 8);
    let mask: u16 = (1 << count) - 1;
    return mask as u8;
}

fn scan_get_next_bits(bytes: &Vec<u8>, state: &mut ScanState, mut count: u8) -> u32 {
    assert!(count < 32);
    let mut out: u32 = 0;

    assert!(state.bit_offset < 8);
    while count > 0 && state.index < bytes.len() {
        if state.bit_offset == 0 {
            // println!("Start at beginning of byte {}", state.index);
            if count >= 8 {
                // println!("A: count={}, index={}, bit_offset={}", count, state.index, state.bit_offset);
                out <<= 8;
                out |= bytes[state.index] as u32;
                state.index += 1;
                count -= 8;
            } else {
                // println!("B: count={}, index={}, bit_offset={}", count, state.index, state.bit_offset);
                let bits = bytes[state.index] >> (8 - count);
                out <<= count;
                out |= (bits & mask_lsb(count)) as u32;
                state.bit_offset += count;
                count = 0;
            }
        } else {
            let bits_available = 8 - state.bit_offset;
            let bits_to_take = min(bits_available, count);
            out <<= bits_to_take;
            out |= ((bytes[state.index] >> (8 - state.bit_offset - bits_to_take)) & mask_lsb(bits_to_take)) as u32;
            if bits_to_take == bits_available {
                // println!("C: count={}, index={}, bit_offset={}, bits_to_take={}", count, state.index, state.bit_offset, bits_to_take);
                state.index += 1;
                state.bit_offset = 0;
            } else {
                // println!("D: count={}, index={}, bit_offset={}", count, state.index, state.bit_offset);
                assert!(bits_to_take < bits_available);
                state.bit_offset += bits_to_take;
            }
            count -= bits_to_take;
        }
    }

    return out;
}

#[inline(always)]
fn scan_seek_to_next_byte(state: &mut ScanState) {
    if state.bit_offset > 0 {
        state.bit_offset = 0;
        state.index += 1;
    }
}

#[derive(Debug)]
enum OpType {
    Sum,
    Product,
    Minimum,
    Maximum,
    GreaterThan,
    LessThan,
    EqualTo,
    Unknown,
}

enum PacketContents {
    Value(u64),
    Operator{ op_type: OpType, subpackets: Vec<Packet> },
}

struct PacketHeader {
    version: u8,
}

struct Packet {
    header: PacketHeader,
    contents: PacketContents,
}

fn parse_value_packet(bytes: &Vec<u8>, state: &mut ScanState) -> (PacketContents, u64) {
    // println!("  parsing value packet");
    let mut value: u64 = 0;
    let mut total_bits_consumed: u64 = 0;

    let mut i = 0;
    loop {
        // pack next 5 bits into LSBs of a u8 then process
        let segment = scan_get_next_bits(bytes, state, 5);
        let last_group = (segment & 0b10000) == 0;
        let literal = segment as u8 & mask_lsb(4);
        value <<= 4;
        value |= literal as u64;
        // println!("  segment {:#07b} :: {}", segment, literal);
        i += 1;

        total_bits_consumed += 5;
        if last_group { break; }

        assert!(i < 16, "ERROR: Value has too many data segments for 64-bit storage (#segments ({}) >= 16)", i);
    }

    return (PacketContents::Value(value), total_bits_consumed);
}

fn parse_operator_packet(bytes: &Vec<u8>, state: &mut ScanState, packet_type: u8) -> (PacketContents, u64) {
    // println!("  parsing operator packet");

    let op_type = match packet_type {
        0 => OpType::Sum,
        1 => OpType::Product,
        2 => OpType::Minimum,
        3 => OpType::Maximum,
        5 => OpType::GreaterThan,
        6 => OpType::LessThan,
        7 => OpType::EqualTo,
        _ => OpType::Unknown,
    };
    // println!("  op type: {:?}", op_type);

    let mut subpackets = Vec::<Packet>::new();
    let mut total_bits_consumed: u64 = 0;

    let length_type_id = scan_get_next_bits(bytes, state, 1);
    if length_type_id == 0 {
        let sub_packet_len = scan_get_next_bits(bytes, state, 15);
        total_bits_consumed += 16;
        // println!("  type 0: subpacket length (bits) = {}", sub_packet_len);

        let mut remaining_bits = sub_packet_len as u64;
        while remaining_bits > 0 {
            let (subpacket, bits_consumed) = parse_next_packet(bytes, state);

            remaining_bits -= bits_consumed;
            total_bits_consumed += bits_consumed;
            // if let PacketContents::Value(value) = subpacket.contents {
            //     println!("value packet (version: {0}): {1:011b} :: {1}", subpacket.header.version, value);
            // }

            subpackets.push(subpacket);
        }
    } else {
        let sub_packet_count = scan_get_next_bits(bytes, state, 11);
        total_bits_consumed += 12;
        // println!("  type 1: subpacket count = {}", sub_packet_count);

        for _ in 0..sub_packet_count {
            let (subpacket, bits_consumed) = parse_next_packet(bytes, state);

            total_bits_consumed += bits_consumed;
            // if let PacketContents::Value(value) = subpacket.contents {
            //     println!("value packet (version: {0}): {1:011b} :: {1}", subpacket.header.version, value);
            // }

            subpackets.push(subpacket);
        }
    }

    return (PacketContents::Operator{ op_type: op_type, subpackets: subpackets }, total_bits_consumed);
}

fn parse_next_packet(bytes: &Vec<u8>, state: &mut ScanState) -> (Packet, u64) {
    // println!("===");
    let pversion: u8 = scan_get_next_bits(&bytes, state, 3) as u8;
    // println!("packet version: {0} :: {0:03b}", pversion);
    let ptype = scan_get_next_bits(&bytes, state, 3) as u8;
    // println!("packet type: {0} :: {0:03b}", ptype);
    let header = PacketHeader { version: pversion };

    let (contents, bits_consumed) = match ptype {
        4 => parse_value_packet(&bytes, state),
        _ => parse_operator_packet(&bytes, state, ptype),
    };

    let packet = Packet {
        header: header,
        contents: contents,
    };
    return (packet, bits_consumed + 6);
}

fn parse_all_packets(bytes: &Vec<u8>) -> Vec<Packet> {
    let mut state = ScanState::default();
    let mut packets = Vec::<Packet>::new();

    while state.index < bytes.len() {
        let (packet, _) = parse_next_packet(&bytes, &mut state);
        packets.push(packet);
        scan_seek_to_next_byte(&mut state);
    }

    return packets;
}

fn packet_version_sum(packet: &Packet) -> u64 {
    let mut version_sum: u64 = packet.header.version as u64;
    match &packet.contents {
        PacketContents::Operator{ op_type: _, subpackets } => {
            for sub in subpackets.iter() {
                version_sum += packet_version_sum(sub);
            }
        },
        _ => {},
    };
    return version_sum;
}

fn part1(packets: &Vec<Packet>) {
    let mut version_sum = 0;
    for packet in packets.iter() {
        version_sum += packet_version_sum(packet);
    }
    println!("PART1: version sum: {}", version_sum);
}

fn evaluate_packet(packet: &Packet) -> u64 {
    match &packet.contents {
        PacketContents::Value(value) => { return *value; },
        PacketContents::Operator{ op_type, subpackets } => {
            match op_type {
                OpType::Sum => {
                    let mut total: u64 = 0;
                    for sub in subpackets { total += evaluate_packet(sub); }
                    return total;
                },
                OpType::Product => {
                    let mut total: u64 = 1;
                    for sub in subpackets { total *= evaluate_packet(sub); }
                    return total;
                },
                OpType::Minimum => {
                    let mut minimum: u64 = u64::MAX;
                    for sub in subpackets { minimum = min(minimum, evaluate_packet(sub)); }
                    return minimum;
                },
                OpType::Maximum => {
                    let mut maximum: u64 = u64::MIN;
                    for sub in subpackets { maximum = max(maximum, evaluate_packet(sub)); }
                    return maximum;
                },
                OpType::GreaterThan => {
                    assert!(subpackets.len() == 2);
                    return (evaluate_packet(&subpackets[0]) > evaluate_packet(&subpackets[1])) as u64;
                },
                OpType::LessThan => {
                    assert!(subpackets.len() == 2);
                    return (evaluate_packet(&subpackets[0]) < evaluate_packet(&subpackets[1])) as u64;
                },
                OpType::EqualTo => {
                    assert!(subpackets.len() == 2);
                    return (evaluate_packet(&subpackets[0]) == evaluate_packet(&subpackets[1])) as u64;
                },
                _ => { assert!(false, "Unhandled op type {:?}", op_type); return 0; },
            };
        }
    }
}

fn part2(packets: &Vec<Packet>) {
    let mut result: u64 = 0;
    for packet in packets.iter() {
        result = evaluate_packet(packet);
    }

    println!("PART2: result: {}", result);
}

fn main() {
    let filename = "../input.txt";
    // let filename = "../test12.txt";
    let contents = fs::read_to_string(filename)
        .expect("Failed to read the file");

    let mut bytes = Vec::<u8>::new();
    for line in contents.lines() {
        bytes.append(&mut decode_hex_to_bytes(line));
    }

    let packets = parse_all_packets(&bytes);

    part1(&packets);
    part2(&packets);
}
