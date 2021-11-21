import sys

verbose = False
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

def parse_line(line):
    raw_policy, password = line.strip(' \n').split(': ')
    raw_policy_bounds, policy_char = raw_policy.split(' ')
    policy_bounds = tuple([int(x) for x in raw_policy_bounds.split('-')])
    policy = (policy_char, policy_bounds)
    return (policy, password)

def load_input(f):
    l = []
    with open(f, 'r') as fd:
        for line in fd:
            l.append(parse_line(line.strip(' \n')))
    return l

first_char = 'a'
last_char = 'z'
nchars = ord(last_char) - ord(first_char)+1
def is_valid_part1(policy, password):
    freq = [0]*nchars
    for c in password:
        if ord(c)<ord(first_char) or ord(c)>ord(last_char):
            raise ValueError("character {} not in valid range".format(c))
        freq[ord(c)-ord(first_char)] += 1

    printv(policy, password)
    printv(' '.join([chr(ii) for ii in range(ord(first_char), ord(last_char)+1)]))
    printv(' '.join([str(freq[ii]) for ii in range(nchars)]))

    policy_char, policy_bounds = policy
    pchar_count = freq[ord(policy_char)-ord(first_char)]
    if policy_bounds[0] <= pchar_count <= policy_bounds[1]:
        return True
    return False

def is_valid_part2(policy, password):
    printv(policy, password)
    policy_char, policy_slots = policy
    return bool(password[policy_slots[0]-1] == policy_char) ^ bool(password[policy_slots[1]-1] == policy_char)

def get_num_valid(l, validator):
    n_valid = 0
    for ii in range(len(l)):
        valid = validator(*l[ii])
        printv(ii, valid)
        n_valid += int(valid)
        printv()
    print('{:d} valid of {:d}'.format(n_valid, len(l)))


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    get_num_valid(l, is_valid_part1)
    print()

    print('PART2')
    get_num_valid(l, is_valid_part2)
