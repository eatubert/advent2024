import sys

if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

safe = 0
for line in file:
    data = [int(x) for x in line.split()]
    sign = data[1] - data[0]
    if not sign:
        continue
    sign /= abs(sign)
    issafe = 1
    for index in range(len(data)-1):
        delta = (data[index+1] - data[index]) / sign
        if delta < 1 or delta > 3:
            issafe = 0
            break
    safe += issafe
    
print(safe)
