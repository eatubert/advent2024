import sys


def issafe(data):
    sign = data[1] - data[0]
    if not sign:
        return 0
    sign /= abs(sign)
    for index in range(len(data) - 1):
        delta = (data[index + 1] - data[index]) / sign
        if delta < 1 or delta > 3:
            return 0
    return 1


if len(sys.argv) < 2:
    file = sys.stdin
else:
    file = open(sys.argv[1], 'rt')

safe = 0
for line in file:
    data = [int(x) for x in line.split()]
    if issafe(data):
        safe += 1
    else:
        for index in range(len(data)):
            temp = [x for x in data]
            temp.pop(index)
            if issafe(temp):
                safe += 1
                break

print(safe)
