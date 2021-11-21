import sys

verbose = True
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    with open(f, 'r') as fd:
        return fd.read().strip().split('\n')

def part1(l):
    pass

def part2(l):
    pass

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
