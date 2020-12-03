import sys
def load_file(f):
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            l.append(int(line.strip(' \n')))
    return l

def part1(f):
    l = load_file(f)
    ls = sorted(l)

    goal = 2020
    ff = 0
    bb = len(ls)-1

    while ff<bb:
        tot = ls[ff] + ls[bb]
        if tot < goal:
            ff += 1
        elif tot > goal:
            bb -= 1
        elif tot == goal:
            print(ls[ff], ls[bb])
            print('prod:', ls[ff] * ls[bb])
            return True
    print("Not found")
    return False


def part2(f):
    goal = 2020
    l = sorted(load_file(f), reverse=True)
    s = len(l)
    mh, mm, ml = 0, 1, 2
    while mh<s:
        if mm >= s:
            mh += 1
            mm = mh+1
            ml = mm+1
            continue
        elif ml >= s:
            mm += 1
            ml = mm+1
            continue

        subtot = l[mh] + l[mm]
        tot = subtot + l[ml]
        print(mh, mm, ml, s, tot, subtot)

        if l[mh] > goal:
            # prune l1 branch
            mh += 1
            continue
        elif subtot > goal:
            # prune l2 branch
            mm += 1
            ml = mm+1
            continue
        elif tot == goal:
            print('Found', l[mh], l[mm], l[ml])
            print('prod', l[mh]*l[mm]*l[ml])
            return True

        ml += 1

    print("Not found")
    return False

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv)>1:
        f = sys.argv[1]

    print('part1')
    part1(f)
    print('\npart2')
    part2(f)
