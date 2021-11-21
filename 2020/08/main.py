import sys

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            ins, arg = line.strip().split(' ')
            l.append((ins, int(arg)))
    return l

def part1(l):
    printv(l)
    acc = 0
    eip = 0
    visited = set()
    while eip < len(l):
        ins, arg = l[eip]
        printv('[eip=%d]'%eip)
        printv(ins, arg)
        if eip in visited:
            printv("Already visited eip=%d"%eip)
            return acc

        visited.add(eip)
        if ins == 'jmp':
            eip += arg - 1
        elif ins == 'acc':
            acc += arg
        printv('[acc=%d]'%acc)
        printv()
        eip += 1
    return acc

def part2(l):
    printv(l)
    acc = 0
    eip = 0
    btidx = None
    visited = set()
    stack = []

    def flip_ins(eip, ins, arg):
        if ins == 'nop':
            ins = 'jmp'
        elif ins == 'jmp':
            ins = 'nop'
        l[eip] = (ins, arg)
        return ins

    while eip < len(l):
        ins, arg = l[eip]
        stack.append(eip)
        def report_state():
            printv('[eip=%d]'%eip)
            printv('[acc=%d]'%acc)
            printv(ins, arg)
            printv('stack=%s'%stack)
            printv('visited', visited)
        report_state()

        if eip in visited:
            # backtrack
            printv("Already visited eip=%d"%eip)
            stack.pop()
            if btidx is None:
                btidx = len(stack)-1

            # undo previous backtrack attempt
            while len(stack) and len(stack) > btidx+1:
                ueip = stack.pop()
                uins, uarg = l[ueip]
                if uins == 'acc':
                    acc -= uarg
            while True:
                eip = stack.pop()
                visited.remove(eip)
                ins, arg = l[eip]
                if ins == 'acc':
                    acc -= arg
                else:
                    ins = flip_ins(eip, ins, arg)
                    break
            btidx = len(stack)-1

        # evaluate instruction
        visited.add(eip)
        if ins == 'jmp':
            eip += arg - 1
        elif ins == 'acc':
            acc += arg
        printv('[acc=%d]'%acc)
        printv()
        eip += 1
    return acc

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
