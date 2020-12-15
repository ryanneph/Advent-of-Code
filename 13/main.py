import sys
import functools

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    with open(f, 'r') as fd:
        time_depart = int(fd.readline().strip())
        ids = fd.readline().strip().split(',')
    return time_depart, ids

def part1(time_depart, ids):
    sids = sorted((int(id)-(time_depart%int(id)) if id!='x' else float('inf'), id) for id in ids)
    return int(sids[0][1])*sids[0][0]

@functools.lru_cache(maxsize=None)
def gcd(x, y):
    """Finds greatest common denominator among a two integers"""
    if x == 0:
        return y, 0, 1
    g, x1, y1 = gcd(y%x, x)
    x = y1 - (y//x) * x1
    y = x1
    return g, x, y

def part2(ids):
    """Using Extended Euclidean Algorithm"""
    if len(ids) <= 1:
        return 0

    intervals = [int(id) for id in ids if id!='x']
    offsets = [ii for ii in range(len(ids)) if ids[ii]!='x']
    printv('intervals', intervals)
    printv('offsets', offsets)

    period = intervals[0]
    phase = 0
    for ii, (interval, offset) in enumerate(zip(intervals[1:], offsets[1:])):
        g, s, _ = gcd(period, interval)
        m = (((phase-offset)//g) * s)

        old_period = period
        period = (period * interval) // g
        phase = (-m*old_period + phase)%period
        printv('F_%d(t) = %d * t - %d' % (ii+1, period, phase))
    first_timestep = -phase % period
    printv("First convergence at k=1: timestep=%d"%first_timestep)
    return first_timestep


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    t = load_input(f)

    print('PART1')
    print(part1(*t))

    print('\nPART2')
    print(part2(t[1]))
