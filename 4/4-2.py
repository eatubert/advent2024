import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

lines = []
for line in file:
    lines.append([x for x in line.rstrip()])

total = 0
numrows = len(lines)
numcolumns = len(lines[0])

for row in range(1, numrows - 1):
    for col in range(1, numcolumns - 1):
        if lines[row][col] != 'A':
            continue

        s1 = lines[row - 1][col - 1] + lines[row + 1][col + 1]
        s2 = lines[row - 1][col + 1] + lines[row + 1][col - 1]

        if (s1 == 'MS' or s1 == 'SM') and (s2 == 'MS' or s2 == 'SM'):
            total += 1

print(total)
