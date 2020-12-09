import sys
import re
import functools

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            l.append(int(line.strip()))
    return l

pre_size = 25
def part1(l):
    printv(l)
    for offset in range(len(l)-pre_size):
        found = False
        window = l[offset:offset+pre_size]
        cur_val = l[offset+pre_size]
        printv(window, cur_val)
        for i in range(pre_size-1):
            for j in range(i, pre_size):
                printv(i, j, window[i]+window[j])
                if window[i] + window[j] == cur_val \
                and window[i] != window[j]:
                    found = True
                    break
            if found:
                printv('found: i={}, j={}, {}+{}={}'.format(
                    i, j, window[i], window[j], cur_val))
                break
        if not found:
            printv('Found: idx={}, val={}'.format(offset, cur_val))
            return cur_val

def part2(l):
    target = part1(l)
    b, f = 0, 2
    tot = l[0]+l[1]
    while f<len(l) and f-b>1:
        printv(b,f, tot)
        if tot < target:
            f += 1
            tot += l[f-1]
        elif tot > target and f-b>2:
            tot -= l[b]
            b += 1
        else:
            printv("Found set: {}".format(l[b:f]))
            def fxn(ls):
                return ls[0]+ls[-1]
            return fxn(sorted(l[b:f]))


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
