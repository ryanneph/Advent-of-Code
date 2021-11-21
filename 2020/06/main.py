import sys

def load_input(f):
    l = []
    with open(f, 'r') as fd:
        answers = []
        for line in fd:
            answers.append(line.strip())
            if line == '\n':
                l.append(answers[:-1])
                answers = []
                continue
        l.append(answers)
    return l

def part1(l):
    tot = 0
    for grp in l:
        q = set()
        for c in ''.join(grp):
            q.add(c)
        tot += len(q)
    return tot

def part2(l):
    tot = 0
    for grp in l:
        arr = [0]*26
        npeople = len(grp)
        for c in ''.join(grp):
            arr[ord(c)-ord('a')] += 1
        for q in arr:
            tot += int(q == npeople)
    return tot

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
