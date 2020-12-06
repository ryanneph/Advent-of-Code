import sys
import re

verbose = True
def printv(*args, **kwargs):
    if verbose:
        print(*args, **kwargs)

class Passport():
    def __init__(self, sbuf):
        """parse key/val pairs from string buffer"""
        #  ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid', 'cid']
        for k, v in (x.split(':') for x in sbuf.split()):
            setattr(self, k, v)

    def __str__(self):
        return str(vars(self))

def load_input(f):
    passports = []
    with open(f, 'r') as fd:
        sbuf = fd.read()
    for sgroup in sbuf.split('\n\n'):
        passports.append(Passport(sgroup))
    return passports

def is_valid_part1(pport):
    for k in ('byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid'):
        if not getattr(pport, k, None):
            return False
    return True

def validate_height(s):
    m = re.fullmatch(r'(\d+)(in|cm)', s)
    try:
        hgt, unit = m.groups()
    except:
        return False

    if unit == 'in':
        return 59<=int(hgt)<=76
    elif unit == 'cm':
        return 150<=int(hgt)<=193
    return False

validators = {
    'byr': lambda s: len(s)==4 and 1920<=int(s)<=2002,
    'iyr': lambda s: len(s)==4 and 2010<=int(s)<=2020,
    'eyr': lambda s: len(s)==4 and 2020<=int(s)<=2030,
    'hgt': validate_height,
    'hcl': lambda s: bool(re.fullmatch(r'#[\da-f]{6}', s)),
    'ecl': lambda s: s in ('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'),
    'pid': lambda s: bool(re.fullmatch(r'\d{9}', s)),
}
def is_valid_part2(pport):
    for k, f in validators.items():
        try:
            if not f(getattr(pport, k)):
                return False
        except:
            return False
    return True

def get_num_valid(l, validator):
    n_valid = 0
    for pport in l:
        n_valid += int(validator(pport))
    return n_valid


if __name__ == '__main__':
    f = 'input.txt'
    if len(sys.argv) > 1:
        f = sys.argv[1]
    l = load_input(f)

    print('PART1')
    print(get_num_valid(l, is_valid_part1))

    print('\nPART2')
    print(get_num_valid(l, is_valid_part2))
