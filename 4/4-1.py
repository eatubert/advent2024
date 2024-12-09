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

for row in range(numrows):
    for col in range(numcolumns):
        if lines[row][col] != 'X':
            continue

        if col <= numcolumns - 4 and \
                lines[row][col + 1] == 'M' and \
                lines[row][col + 2] == 'A' and \
                lines[row][col + 3] == 'S':
            total += 1

        if col >= 3 and \
                lines[row][col - 1] == 'M' and \
                lines[row][col - 2] == 'A' and \
                lines[row][col - 3] == 'S':
            total += 1

        if row <= numrows - 4 and \
                lines[row + 1][col] == 'M' and \
                lines[row + 2][col] == 'A' and \
                lines[row + 3][col] == 'S':
            total += 1

        if row >= 3 and \
                lines[row - 1][col] == 'M' and \
                lines[row - 2][col] == 'A' and \
                lines[row - 3][col] == 'S':
            total += 1

        if col <= numcolumns - 4 and \
                row <= numrows - 4 and \
                lines[row + 1][col + 1] == 'M' and \
                lines[row + 2][col + 2] == 'A' and \
                lines[row + 3][col + 3] == 'S':
            total += 1

        if col >= 3 and \
                row >= 3 and \
                lines[row - 1][col - 1] == 'M' and \
                lines[row - 2][col - 2] == 'A' and \
                lines[row - 3][col - 3] == 'S':
            total += 1

        if col <= numcolumns - 4 and \
                row >= 3 and \
                lines[row - 1][col + 1] == 'M' and \
                lines[row - 2][col + 2] == 'A' and \
                lines[row - 3][col + 3] == 'S':
            total += 1

        if col >= 3 and \
                row <= numrows - 4 and \
                lines[row + 1][col - 1] == 'M' and \
                lines[row + 2][col - 2] == 'A' and \
                lines[row + 3][col - 3] == 'S':
            total += 1

print(total)
