import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

a = []
b = []

for line in file:
    vals = line.split()
    a.append(int(vals[0]))
    b.append(int(vals[1]))

a.sort()
b.sort()
total = 0
for aa in a:
    total += abs(aa - b.pop(0))

print(total)
