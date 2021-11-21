import sys

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def load_input(f):
    with open(f, 'r') as fd:
        return fd.read().strip().split('\n')

# map of global heading to (x, y) direction vector
heading_map = {'N': ( 0,  1),
               'E': ( 1,  0),
               'S': ( 0, -1),
               'W': (-1,  0)}
heading2index = {'N': 0,
                 'E': 1,
                 'S': 2,
                 'W': 3}
headings = ['N', 'E', 'S', 'W']
#      0  90  180  270
COS = [1,  0,  -1,   0]
SIN = [0,  1,   0,  -1]

class Ship():
    """I'm trying to weigh the appropriate uses of OOD vs functional dev lately,
    but this is a pretty simple use so OOD it is.
    """
    def __init__(self, heading='N', position=(0, 0), way_position=(0, 0)):
        self.heading = heading
        self.xpos = position[0]
        self.ypos = position[1]
        self.orig_xpos, self.orig_ypos = self.xpos, self.ypos
        self.way_xdelta = way_position[0]
        self.way_ydelta = way_position[1]

    def turn(self, degrees, CW=True):
        """turn in direction CW/CCW a number of degrees"""
        assert degrees%90 == 0
        degrees *= (1 if CW else -1)
        idx_update = degrees//90
        self.heading = headings[(heading2index[self.heading]+idx_update)%4]

    def rotate_waypoint(self, degrees, CW=True):
        """Rotate waypoint around ship a number of degrees"""
        assert degrees%90 == 0
        degrees *= (1 if CW else -1)
        rotidx = degrees // 90
        way_xdelta, way_ydelta = self.way_xdelta, self.way_ydelta
        self.way_xdelta =  way_xdelta*COS[rotidx] + way_ydelta*SIN[rotidx]
        self.way_ydelta = -way_xdelta*SIN[rotidx] + way_ydelta*COS[rotidx]

    def move_forward(self, dist):
        dvec = heading_map[self.heading]
        self.xpos += dist * dvec[0]
        self.ypos += dist * dvec[1]

    def move_toward_heading(self, heading, dist):
        old_heading = self.heading
        self.heading = heading
        self.move_forward(dist)
        self.heading = old_heading

    def move_waypoint_relative(self, heading, dist):
        dvecx, dvecy = heading_map[heading]
        self.way_xdelta += dist * dvecx
        self.way_ydelta += dist * dvecy

    def move_to_waypoint(self):
        self.xpos += self.way_xdelta
        self.ypos += self.way_ydelta

    def act(self, instruction):
        action, val = instruction[:1], int(instruction[1:])
        if action in ('L', 'R'):
            self.turn(val, CW=(action=='R'))
        elif action == 'F':
            self.move_forward(val)
        elif action in headings:
            self.move_toward_heading(action, val)
        else:
            raise ValueError('action "%s" is not recognized'%action)

    def act_by_waypoint(self, instruction):
        action, val = instruction[:1], int(instruction[1:])
        if action in ('L', 'R'):
            self.rotate_waypoint(val, CW=(action=='R'))
        elif action == 'F':
            for _ in range(val):
                self.move_to_waypoint()
        elif action in headings:
            self.move_waypoint_relative(action, val)
        else:
            raise ValueError('action "%s" is not recognized'%action)

    def manhattan_distance(self):
        return abs(self.ypos-self.orig_ypos) + abs(self.xpos-self.orig_xpos)


def part1(l):
    ship = Ship('E')
    printv('%4s'%'INST', '%2s'%'HD', '%5s'%'XPOS', '%5s'%'YPOS')
    for instruction in l:
        ship.act(instruction)
        printv('%4s'%instruction, '%2s'%ship.heading, '%5d'%ship.xpos, '%5d'%ship.ypos)
    return ship.manhattan_distance()

def part2(l):
    ship = Ship('E', way_position=(10, 1))
    printv('%4s'%'INST', '%2s'%'HD', '%5s'%'XPOS', '%5s'%'YPOS')
    for instruction in l:
        ship.act_by_waypoint(instruction)
        printv('%4s'%instruction, '%2s'%ship.heading, '%5d'%ship.xpos, '%5d'%ship.ypos)
    return ship.manhattan_distance()


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(part1(l))

    print('\nPART2')
    print(part2(l))
