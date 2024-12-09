import re
import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

total = 0
for line in file:
    for match in re.findall(r'mul\((\d+),(\d+)\)', line):
        total += int(match[0]) * int(match[1])

print(total)
