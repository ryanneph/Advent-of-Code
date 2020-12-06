import sys
import re

verbose = True
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            l.append(line.strip())
    return l

def str2int1(s):
    """String builder method"""
    binary_str = ''.join(
        ['1' if c=='B' else '0' for c in s[:7]] +
        ['1' if c=='R' else '0' for c in s[7:]])
    return int(binary_str, 2)

def str2int2(s):
    """Bit-bashing method"""
    sz = len(s)
    n = 0
    for i, c in enumerate(s):
        if c in ('B', 'R'):
            n += (1<<(sz-i-1))
    return n

def part1(l):
    ls = sorted(l, key=lambda s: str2int2(s))
    return str2int2(ls[-1])

def part2(l):
    seat_ids = sorted([str2int2(s) for s in l])
    for ii in range(len(seat_ids)-1):
        if seat_ids[ii+1]-seat_ids[ii] > 1:
            return seat_ids[ii] + 1
    return None

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
