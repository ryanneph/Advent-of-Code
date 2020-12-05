import sys
import numpy as np

def read_input_to_array(f):
    """Reads input file of . and # chars into a binary array

    . is given 0 - no tree
    # is given 1 - tree
    """
    rows = []
    with open(f, 'r') as fd:
        for line in fd:
            row = [int(c=='#') for c in line.strip(' \n')]
            rows.append(row)
    return np.array(rows)

def part1(topmap, slope):
    update_r, update_c = slope
    r = c = 0
    n_trees = 0
    while r < topmap.shape[0]:
        n_trees += int(topmap[r, c%topmap.shape[1]])
        r += update_r
        c += update_c
    return n_trees

def part2(topmap):
    prod = 1
    for slope in [(1,1), (1,3), (1,5), (1,7), (2,1)]:
        n_trees = part1(topmap, slope)
        prod *= n_trees
    return prod


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    topmap = read_input_to_array(f)

    print("PART1")
    print('num trees:', part1(topmap, (1, 3)))

    print("\nPART2")
    print('prod trees:', part2(topmap))
