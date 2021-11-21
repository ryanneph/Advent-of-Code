import sys
from functools import lru_cache

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    with open(f, 'r') as fd:
        return sorted([int(x) for x in fd.read().strip().split('\n')])

def part1(l):
    diffcounts = [0]*5
    for ii in range(len(l)-1):
        diff = max(0, min(4, l[ii+1]-l[ii]))
        assert 1<=diff<=3
        diffcounts[diff] += 1
    printv(diffcounts)
    return diffcounts[1]*diffcounts[3]

def part2(l):
    """each trial iterates over the list and either keeps an indexed value in or takes it out (if possible)
    The new state of the list is recursively processed in the same way and the leaves are counted throughout
    """
    @lru_cache(maxsize=None)
    def topdown_iterate(prev_val, start_idx):
        count = 0
        if start_idx >= len(l)-1:
            return 1
        if l[start_idx+1] - prev_val <= 3:
            # "remove" value from the sequence
            count += topdown_iterate(prev_val, start_idx + 1)
        # "keep" value in the sequence
        count += topdown_iterate(l[start_idx], start_idx + 1)
        return count
    return topdown_iterate(0, 1)


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)
    l = [0] + l + [max(l)+3]

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
