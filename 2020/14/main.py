import sys
from collections import namedtuple, defaultdict

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

MemAssign = namedtuple('MemAssign', ('addr', 'val'))
BitMask   = namedtuple('BitMask',   ('zeromask', 'onemask'))

NBITS = 36 # length of bitmask

def load_input(f):
    inst = []
    with open(f, 'r') as fd:
        lines = fd.read().strip().split('\n')
        for line in lines:
            if line.startswith('mem'):
                addr = int(line[4:line.find(']', 4)])
                val = int(line[line.find('=', 4)+2:])
                inst.append(MemAssign(addr, val))
            else:
                zeromask = onemask = 0
                for ii, c in enumerate(line[::-1]):
                    zeromask |= ((c=='0')<<ii)
                    onemask  |= ((c=='1')<<ii)
                inst.append(BitMask(zeromask, onemask))
    return inst

def count_set_bits(bitmask):
    count = 0
    for ii in range(NBITS):
        count += int(bitmask & (1<<ii))>>ii
    return count


def part1(l):
    mem = defaultdict(lambda: 0)
    bitmask = None
    for inst in l:
        if isinstance(inst, BitMask):
            bitmask = inst
        else:
            val = inst.val
            if bitmask:
                val |=  bitmask.onemask
                val &= ~bitmask.zeromask
            mem[inst.addr] = val

    tot = 0
    for val in mem.values():
        tot += val
    return tot

def part2(l):
    def iterate_addresses(addr, floating_bitmask, high_bit_index):
        if high_bit_index < 0:
            yield addr
            return
        while not (floating_bitmask & (1<<high_bit_index)):
            high_bit_index -= 1
            if high_bit_index < 0:
                yield addr
                return
        yield from iterate_addresses(addr | (1<<high_bit_index), floating_bitmask, high_bit_index-1)
        yield from iterate_addresses(addr & ~(1<<high_bit_index), floating_bitmask, high_bit_index-1)


    mem = defaultdict(lambda: 0)
    bitmask = None
    fltmask = None
    for inst in l:
        if isinstance(inst, BitMask):
            bitmask = inst
            fltmask = ~(bitmask.zeromask | bitmask.onemask) & ((1<<NBITS)-1)
            nfloatbits = count_set_bits(fltmask)
            printv('\nSetting float bitmask: ', bin(fltmask)[2:].replace('1','X').replace('0','_'), nfloatbits, 2**nfloatbits)
        else:
            val = inst.val
            if bitmask:
                addr = inst.addr | bitmask.onemask
                for iaddr in iterate_addresses(addr, fltmask, NBITS):
                    printv('mem[%s] = %d'%(bin(iaddr)[2:], val))
                    mem[iaddr] = val
            printv()

    tot = 0
    for val in mem.values():
        tot += val
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
