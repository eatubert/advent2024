import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

a = []
b = {}

for line in file:
    vals = line.split()
    a.append(int(vals[0]))
    bval = int(vals[1])
    b[bval] = b.get(bval,0) + 1

total = 0
for aa in a:
    total += aa * b.get(aa,0)

print(total)
