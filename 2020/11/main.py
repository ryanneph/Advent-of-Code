import sys
from copy import deepcopy

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    """Loads 2D char grid of seating layout
    .  floor
    L  empty seat
    #  occupied seat
    """
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            l.append(list(line.strip()))
    return l

NR, NC = (None,)*2
def iterator(board, return_index=False):
    """Iterate over the whole board"""
    for ir in range(NR):
        for ic in range(NC):
            val = board[ir][ic]
            if return_index:
                yield val, (ir, ic)
            else:
                yield val

def print_board(board):
    printv('\n'.join([''.join(row) for row in board]))

def update(board, iter_neighborhood, n_occupied_limit):
    new_board = deepcopy(board)
    board_changed = False
    for cell, (rr, cc) in iterator(board, return_index=True):
        # rule 1
        if cell == 'L':
            occupy = True
            for nbr in iter_neighborhood(board, rr, cc):
                if nbr == '#':
                    occupy = False
                    break
            if occupy:
                new_board[rr][cc] = '#'
                board_changed = True
        # rule 2
        if cell == '#':
            n_occupied = 0
            unoccupy = False
            for nbr in iter_neighborhood(board, rr, cc):
                n_occupied += int(nbr=='#')
                if n_occupied>=n_occupied_limit:
                    unoccupy = True
                    break
            if unoccupy:
                new_board[rr][cc] = 'L'
                board_changed = True
    return new_board, board_changed

def stabilize(board, updater):
    printv('Initial State:')
    print_board(board)
    changed = True
    n_updates = 0
    while changed:
        board, changed = updater(board)
        if changed:
            n_updates += 1
            printv('\nAfter update #%d'%n_updates)
            print_board(board)
    printv('\nBoard Stabilized after %d updates'%n_updates)
    n_occupied = 0
    for cell in iterator(board):
        n_occupied += int(cell=="#")
    return n_occupied


def part1(l):
    """Rules
    1) if L and no adjacent # seats: becomes #
    2) if # and >=4 adjacent #: becomes L
    """
    def neighborhood(board, rr, cc, size=(1,1), return_index=False):
        """Iterate over a neighborhood centered at (rr, cc) with configurable size"""
        for rdelta in range(-size[0], size[0]+1):
            for cdelta in range(-size[1], size[1]+1):
                ir, ic = rr+rdelta, cc+cdelta
                if not (0<=ir<NR and 0<=ic<NC):
                    continue
                if rdelta == 0 and cdelta == 0:
                    continue
                val = board[ir][ic]
                if return_index:
                    yield val, (ir, ic)
                else:
                    yield val

    return stabilize(l, lambda l: update(l, neighborhood, n_occupied_limit=4))

def part2(l):
    def neighborhood(board, rr, cc, return_index=False):
        """Iterate over a neighborhood centered at (rr, cc) by raycasting"""
        def first_seat_seen(rr, cc, yvec, xvec, return_index=False):
            ir, ic = rr, cc
            val = '.'
            while val == '.':
                ir += yvec
                ic += xvec
                if not (0<=ir<NR and 0<=ic<NC):
                    return None
                val = board[ir][ic]
            if return_index:
                return val, (ir, ic)
            return val

        for yvec in range(-1, 2):
            for xvec in range(-1, 2):
                if xvec == 0 and yvec == 0:
                    continue
                result = first_seat_seen(rr, cc, yvec, xvec, return_index=return_index)
                if not result:
                    continue
                yield result

    return stabilize(l, lambda l: update(l, neighborhood, n_occupied_limit=5))

if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)
    NR, NC = len(l), len(l[0])
    print_board(l)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
