import re
import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

state = 1
total = 0
for line in file:
    for match in re.findall(r"(mul\(\d+,\d+\)|do\(\)|don't\(\))", line):
        if match == 'do()':
            state = 1
        if match == "don't()":
            state = 0
        if state:
            mul = re.match(r'mul\((\d+),(\d+)\)', match)
            if mul:
                total += int(mul.group(1)) * int(mul.group(2))

print(total)
