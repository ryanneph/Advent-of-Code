import sys
import re
import functools

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    d = {}
    with open(f, 'r') as fd:
        for line in fd:
            desc, remain = line.strip(' .\n').split(' bags contain ')
            printv(desc)
            contents = {}
            for s in remain.split(', '):
                printv('  ', s)
                n, idesc = s.split(' ', 1)
                try:
                    contents[idesc[:idesc.find(' bag')]] = int(n)
                except:
                    pass
            d[desc] = contents
    return d

def part1(d):
    @functools.lru_cache(maxsize=None)
    def can_contain_gold(desc):
        for k in d[desc].keys():
            if k == 'shiny gold':
                return True
            elif can_contain_gold(k):
                return True
        return False

    n_contain_gold = 0
    for desc in d.keys():
        if desc == 'shiny gold':
            continue
        elif can_contain_gold(desc):
            n_contain_gold += 1
    return n_contain_gold

def part2(d):
    @functools.lru_cache(maxsize=None)
    def count_bags(desc):
        count = 0
        printv('\n',d[desc])
        for k, v in d[desc].items():
            printv(k, v)
            count += v + v*count_bags(k)
        return count
    return count_bags('shiny gold')

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    d = load_input(f)

    print('PART1')
    print(part1(d))

    print('\nPART2')
    print(part2(d))
